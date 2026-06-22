import SceneKit
import UIKit
import Observation

/// Bir bölümün SceneKit sahnesini kuran ve oynanışı yöneten denetleyici.
///
/// - **Kamera:** ortografik + eğik izometrik (MV açısı). Ortografik projeksiyon
///   şarttır: perspektif kısalması olmadığı için ileride "imkânsız geometri"
///   (perspektif hizalama) mümkün olur (GDD §4, §10).
/// - **Ortam:** yol grafiğindeki her noktaya modüler bir blok (SCNBox) yerleştirilir;
///   harici 3D dosya yok (placeholder, GDD §11).
/// - **Tap-to-move:** dokunulan karoya BFS ile en kısa yoldan yürünür.
/// - **Yol Gösteren:** hedefe giden doğru karoları parlatır (GDD §6).
@Observable
final class LevelSceneController {
    let scene = SCNScene()
    let cameraNode = SCNNode()

    // HUD'un izlediği durum
    private(set) var movesCount = 0
    private(set) var reachedGoal = false
    var powerActive = false {
        didSet { applyPowerHighlight() }
    }

    private let level: LevelData
    private let graph: PathGraph
    private let rig: CharacterRig

    private var nodeWorldPos: [String: SCNVector3] = [:]
    private var tileMaterials: [String: SCNMaterial] = [:]
    private var currentNodeID: String
    private var isMoving = false

    private var sceneCenter = SCNVector3(0, 0, 0)
    private var sceneRadius: Float = 6

    init(level: LevelData, characterName: String, characterColor: UIColor) {
        self.level = level
        self.graph = PathGraph(nodes: level.nodes, edges: level.edges)
        self.currentNodeID = level.startID
        self.rig = CharacterRig(name: characterName, color: characterColor)

        for node in level.nodes {
            nodeWorldPos[node.id] = worldPosition(node.point)
        }
        computeFraming()
        scene.background.contents = SceneArt.sky
        setupCamera()
        setupLights()
        buildTiles()
        addGoalMarker()
        placeCharacterAtStart()
    }

    // MARK: - Grid → dünya

    private func worldPosition(_ p: LevelGridPoint) -> SCNVector3 {
        SCNVector3(
            Float(p.x) * SceneArt.unit,
            Float(p.y) * SceneArt.unitHeight,
            Float(p.z) * SceneArt.unit
        )
    }

    private func computeFraming() {
        let positions = Array(nodeWorldPos.values)
        guard let first = positions.first else { return }
        var minX = first.x, maxX = first.x
        var minY = first.y, maxY = first.y
        var minZ = first.z, maxZ = first.z
        for p in positions {
            minX = min(minX, p.x); maxX = max(maxX, p.x)
            minY = min(minY, p.y); maxY = max(maxY, p.y)
            minZ = min(minZ, p.z); maxZ = max(maxZ, p.z)
        }
        sceneCenter = SCNVector3((minX + maxX) / 2, (minY + maxY) / 2, (minZ + maxZ) / 2)
        let extent = max(maxX - minX, maxZ - minZ, maxY - minY)
        sceneRadius = max(3, extent)
    }

    // MARK: - Kamera (ortografik izometrik)

    private func setupCamera() {
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = Double(sceneRadius) * 0.85 + 1.8
        camera.zNear = 0.1
        camera.zFar = 500
        cameraNode.camera = camera

        let distance: Float = 40
        cameraNode.position = SCNVector3(
            sceneCenter.x + distance,
            sceneCenter.y + distance,
            sceneCenter.z + distance
        )
        cameraNode.look(at: sceneCenter)
        scene.rootNode.addChildNode(cameraNode)
    }

    // MARK: - Işık

    private func setupLights() {
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 360
        ambient.light?.color = UIColor(white: 1.0, alpha: 1.0)
        scene.rootNode.addChildNode(ambient)

        let sun = SCNNode()
        sun.light = SCNLight()
        sun.light?.type = .directional
        sun.light?.intensity = 820
        sun.light?.color = UIColor(hex: "#FFF4DE")
        sun.light?.castsShadow = true
        sun.light?.shadowColor = UIColor(white: 0, alpha: 0.22)
        sun.light?.shadowRadius = 5
        sun.light?.shadowSampleCount = 16
        sun.position = SCNVector3(sceneCenter.x + 12, sceneCenter.y + 24, sceneCenter.z + 8)
        sun.look(at: sceneCenter)
        scene.rootNode.addChildNode(sun)
    }

    // MARK: - Ortam blokları

    private func buildTiles() {
        let tileSize = CGFloat(SceneArt.unit * 0.9)
        for node in level.nodes {
            guard let pos = nodeWorldPos[node.id] else { continue }

            let box = SCNBox(
                width: tileSize,
                height: SceneArt.blockHeight,
                length: tileSize,
                chamferRadius: 0.05
            )
            let material = SCNMaterial()
            material.lightingModel = .physicallyBased
            material.diffuse.contents = baseColor(for: node.id)
            material.roughness.contents = 0.85
            box.materials = [material]

            let tile = SCNNode(geometry: box)
            tile.name = "tile:\(node.id)"
            tile.position = SCNVector3(pos.x, pos.y - Float(SceneArt.blockHeight) / 2, pos.z)
            tile.castsShadow = true
            scene.rootNode.addChildNode(tile)

            tileMaterials[node.id] = material
        }
    }

    private func baseColor(for id: String) -> UIColor {
        if id == level.startID { return SceneArt.start }
        if id == level.goalID { return SceneArt.goal }
        return SceneArt.stone
    }

    private func addGoalMarker() {
        guard let pos = nodeWorldPos[level.goalID] else { return }
        let pyramid = SCNPyramid(width: 0.34, height: 0.46, length: 0.34)
        pyramid.firstMaterial?.lightingModel = .physicallyBased
        pyramid.firstMaterial?.diffuse.contents = SceneArt.goal
        pyramid.firstMaterial?.emission.contents = SceneArt.glow

        let marker = SCNNode(geometry: pyramid)
        marker.position = SCNVector3(pos.x, pos.y + 0.5, pos.z)
        marker.runAction(.repeatForever(.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 6)))
        scene.rootNode.addChildNode(marker)
    }

    private func placeCharacterAtStart() {
        guard let pos = nodeWorldPos[level.startID] else { return }
        rig.root.position = pos
        scene.rootNode.addChildNode(rig.root)
    }

    // MARK: - Tap-to-move

    /// SCNView'dan gelen hit-test sonuçlarını işler.
    func handleTap(hitResults: [SCNHitTestResult]) {
        guard !isMoving, !reachedGoal else { return }
        guard let tappedID = hitResults.lazy.compactMap({ self.tileID(from: $0.node) }).first else { return }
        guard tappedID != currentNodeID else { return }
        guard let path = graph.shortestPath(from: currentNodeID, to: tappedID) else { return }
        move(along: path)
    }

    private func tileID(from node: SCNNode) -> String? {
        var current: SCNNode? = node
        while let n = current {
            if let name = n.name, name.hasPrefix("tile:") {
                return String(name.dropFirst("tile:".count))
            }
            current = n.parent
        }
        return nil
    }

    private func move(along path: [String]) {
        guard path.count > 1 else { return }
        isMoving = true
        rig.walk()

        var actions: [SCNAction] = []
        for id in path.dropFirst() {
            guard let target = nodeWorldPos[id] else { continue }
            let turn = SCNAction.run { [weak self] node in
                let from = node.presentation.position
                self?.rig.face(dx: target.x - from.x, dz: target.z - from.z)
            }
            let step = SCNAction.move(to: target, duration: 0.34)
            step.timingMode = .easeInEaseOut
            actions.append(.sequence([turn, step]))
        }

        let walkSequence = SCNAction.sequence(actions)
        rig.root.runAction(walkSequence) { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.currentNodeID = path.last ?? self.currentNodeID
                self.movesCount += 1
                self.isMoving = false
                self.rig.idle()
                if self.currentNodeID == self.level.goalID {
                    self.reachedGoal = true
                    self.rig.power()
                }
                if self.powerActive {
                    self.applyPowerHighlight()
                }
            }
        }
    }

    // MARK: - Yol Gösteren gücü

    func togglePower() {
        powerActive.toggle()
    }

    /// Doğru yolu (mevcut konumdan hedefe) parlatır; kapalıyken parıltıyı temizler.
    private func applyPowerHighlight() {
        for material in tileMaterials.values {
            material.emission.contents = SceneArt.none
        }
        guard powerActive else { return }
        guard let path = graph.shortestPath(from: currentNodeID, to: level.goalID) else { return }
        for id in path {
            tileMaterials[id]?.emission.contents = SceneArt.glow
        }
    }
}
