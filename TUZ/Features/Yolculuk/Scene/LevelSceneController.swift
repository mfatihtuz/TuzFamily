import SceneKit
import UIKit
import Observation
import simd

/// Bir bölümün SceneKit sahnesini kuran ve oynanışı yöneten denetleyici.
///
/// - **Kamera:** ortografik + eğik izometrik (MV açısı). Ortografik şarttır:
///   perspektif kısalması olmadığı için "imkânsız geometri" mümkün olur (GDD §4, §10).
/// - **Ortam:** her yürünebilir nokta, zemine kadar inen içi dolu bir taş sütun +
///   aydınlık üst yüzey olarak kurulur (uçuşan blok değil, mimari kütle). Harici
///   3D dosya yok (placeholder, GDD §11).
/// - **Tap-to-move / döndürme / perspektif hizalama / Yol Gösteren** (GDD §5, §6).
@Observable
final class LevelSceneController {
    let scene = SCNScene()
    let cameraNode = SCNNode()

    private(set) var movesCount = 0
    private(set) var reachedGoal = false
    var powerActive = false {
        didSet { applyPowerHighlight() }
    }

    var canRotate: Bool { !level.rotators.isEmpty }

    private let level: LevelData
    private var graph: PathGraph
    private let rig: CharacterRig

    private var nodeWorldPos: [String: SCNVector3] = [:]   // yürüme yüzeyi (başlangıç)
    private var tileNodes: [String: SCNNode] = [:]         // origin = yürüme yüzeyi
    private var tileMaterials: [String: SCNMaterial] = [:] // üst kapak malzemesi
    private var rotatorNodes: [String: SCNNode] = [:]
    private var activeSeams: [LevelEdge] = []
    private var currentNodeID: String
    private var isBusy = false

    private var sceneCenter = SCNVector3(0, 0, 0)
    private var sceneRadius: Float = 6
    private var baseY: Float = -1.6

    private let alignmentThreshold: Float = 0.45

    init(level: LevelData, characterName: String, characterColor: UIColor) {
        self.level = level
        self.graph = PathGraph(nodes: level.nodes, edges: level.edges)
        self.currentNodeID = level.startID
        self.rig = CharacterRig(name: characterName, color: characterColor)

        for node in level.nodes {
            nodeWorldPos[node.id] = worldPosition(node.point)
        }
        let tops = level.nodes.map { worldPosition($0.point).y }
        baseY = (tops.min() ?? 0) - SceneArt.baseDrop

        computeFraming()
        scene.background.contents = SceneArt.sky
        setupCamera()
        setupLights()
        buildGround()
        buildRotators()
        buildTiles()
        addGoalMarker()
        placeCharacterAtStart()
        recomputeSeams()
    }

    // MARK: - Grid → dünya

    private func worldPosition(_ p: LevelGridPoint) -> SCNVector3 {
        SCNVector3(
            Float(p.x) * SceneArt.unit,
            Float(p.y) * SceneArt.unitHeight,
            Float(p.z) * SceneArt.unit
        )
    }

    /// Karonun üst (yürüme) yüzeyinin güncel dünya konumu (döndürme sonrası dahil).
    private func walkWorldPosition(_ id: String) -> SCNVector3 {
        tileNodes[id]?.worldPosition ?? nodeWorldPos[id] ?? SCNVector3(0, 0, 0)
    }

    private func computeFraming() {
        var positions = level.nodes.map { worldPosition($0.point) }
        for rotator in level.rotators {
            let pivot = worldPosition(rotator.pivot)
            for id in rotator.nodeIDs {
                guard let node = level.nodes.first(where: { $0.id == id }) else { continue }
                let w = worldPosition(node.point)
                let local = SCNVector3(w.x - pivot.x, w.y - pivot.y, w.z - pivot.z)
                for k in 0..<4 {
                    let theta = Double(k) * .pi / 2
                    let cosT = Float(cos(theta)), sinT = Float(sin(theta))
                    let rx = local.x * cosT + local.z * sinT
                    let rz = -local.x * sinT + local.z * cosT
                    positions.append(SCNVector3(pivot.x + rx, w.y, pivot.z + rz))
                }
            }
        }

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
        sceneRadius = max(3, max(maxX - minX, max(maxZ - minZ, maxY - minY)))
    }

    // MARK: - Kamera (ortografik izometrik)

    private func setupCamera() {
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = Double(sceneRadius) * 0.62 + 2.2
        camera.zNear = 0.1
        camera.zFar = 500
        cameraNode.camera = camera

        let distance: Float = 60
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
        ambient.light?.intensity = 420
        ambient.light?.color = UIColor(hex: "#FBF3E0")
        scene.rootNode.addChildNode(ambient)

        let sun = SCNNode()
        sun.light = SCNLight()
        sun.light?.type = .directional
        sun.light?.intensity = 900
        sun.light?.color = UIColor(hex: "#FFF1D6")
        sun.light?.castsShadow = true
        sun.light?.shadowColor = UIColor(white: 0, alpha: 0.28)
        sun.light?.shadowRadius = 6
        sun.light?.shadowSampleCount = 16
        sun.position = SCNVector3(sceneCenter.x + 14, sceneCenter.y + 26, sceneCenter.z + 6)
        sun.look(at: sceneCenter)
        scene.rootNode.addChildNode(sun)
    }

    // MARK: - Zemin platosu

    private func buildGround() {
        let size = CGFloat(sceneRadius * 2.6 + 8)
        let ground = SCNBox(width: size, height: 0.8, length: size, chamferRadius: 0)
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = SceneArt.base
        material.roughness.contents = 0.95
        ground.materials = [material]
        let node = SCNNode(geometry: ground)
        node.position = SCNVector3(sceneCenter.x, baseY - 0.4, sceneCenter.z)
        scene.rootNode.addChildNode(node)
    }

    // MARK: - Döndürücü gruplar + karolar

    private func buildRotators() {
        for rotator in level.rotators {
            let node = SCNNode()
            node.name = "rotator:\(rotator.id)"
            node.position = worldPosition(rotator.pivot)
            scene.rootNode.addChildNode(node)
            rotatorNodes[rotator.id] = node
        }
    }

    private func buildTiles() {
        for node in level.nodes {
            let top = worldPosition(node.point)
            let isRotator = level.rotators.contains { $0.nodeIDs.contains(node.id) }

            // Karo kökü: origin = yürüme yüzeyi. Geometri aşağıya asılır.
            let tile = SCNNode()
            tile.name = "tile:\(node.id)"

            // Gövde sütunu: statik → zemine kadar dolu; dönen → küp blok.
            let columnHeight = isRotator ? CGFloat(1.0) : CGFloat(max(0.6, top.y - baseY))
            let column = SCNBox(width: SceneArt.columnWidth, height: columnHeight,
                                length: SceneArt.columnWidth, chamferRadius: 0.03)
            let sideMaterial = SCNMaterial()
            sideMaterial.lightingModel = .physicallyBased
            sideMaterial.diffuse.contents = SceneArt.stoneSide
            sideMaterial.roughness.contents = 0.9
            column.materials = [sideMaterial]
            let columnNode = SCNNode(geometry: column)
            columnNode.position = SCNVector3(0, -Float(columnHeight) / 2, 0)
            columnNode.castsShadow = true
            tile.addChildNode(columnNode)

            // Üst kapak: aydınlık yürüme yüzeyi (Yol Gösteren parıltısı buraya).
            let cap = SCNBox(width: SceneArt.capWidth, height: SceneArt.capHeight,
                             length: SceneArt.capWidth, chamferRadius: 0.03)
            let capMaterial = SCNMaterial()
            capMaterial.lightingModel = .physicallyBased
            capMaterial.diffuse.contents = capColor(for: node.id)
            capMaterial.roughness.contents = 0.75
            cap.materials = [capMaterial]
            let capNode = SCNNode(geometry: cap)
            capNode.position = SCNVector3(0, -Float(SceneArt.capHeight) / 2, 0)
            capNode.castsShadow = true
            tile.addChildNode(capNode)
            tileMaterials[node.id] = capMaterial

            if let rotatorID = level.rotators.first(where: { $0.nodeIDs.contains(node.id) })?.id,
               let parent = rotatorNodes[rotatorID] {
                let pivot = parent.position
                tile.position = SCNVector3(top.x - pivot.x, top.y - pivot.y, top.z - pivot.z)
                parent.addChildNode(tile)
            } else {
                tile.position = top
                scene.rootNode.addChildNode(tile)
            }
            tileNodes[node.id] = tile
        }
    }

    private func capColor(for id: String) -> UIColor {
        if id == level.startID { return SceneArt.startTop }
        if id == level.goalID { return SceneArt.goalTop }
        return SceneArt.stoneTop
    }

    private func addGoalMarker() {
        guard let goalTile = tileNodes[level.goalID] else { return }
        let pyramid = SCNPyramid(width: 0.34, height: 0.46, length: 0.34)
        pyramid.firstMaterial?.lightingModel = .physicallyBased
        pyramid.firstMaterial?.diffuse.contents = SceneArt.goalTop
        pyramid.firstMaterial?.emission.contents = SceneArt.glow

        let marker = SCNNode(geometry: pyramid)
        marker.position = SCNVector3(0, 0.5, 0)   // origin (yürüme yüzeyi) üzerinde
        marker.runAction(.repeatForever(.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 6)))
        goalTile.addChildNode(marker)
    }

    private func placeCharacterAtStart() {
        rig.root.position = walkWorldPosition(level.startID)
        scene.rootNode.addChildNode(rig.root)
    }

    // MARK: - Perspektif hizalama (ekran-uzayı)

    private func screenXY(of world: SCNVector3) -> SIMD2<Float> {
        let inverse = simd_inverse(cameraNode.simdWorldTransform)
        let p = inverse * SIMD4<Float>(world.x, world.y, world.z, 1)
        return SIMD2<Float>(p.x, p.y)
    }

    private func recomputeSeams() {
        var active: [LevelEdge] = []
        for seam in level.seams {
            let a = screenXY(of: walkWorldPosition(seam.a))
            let b = screenXY(of: walkWorldPosition(seam.b))
            let dx = a.x - b.x, dy = a.y - b.y
            if (dx * dx + dy * dy).squareRoot() < alignmentThreshold {
                active.append(LevelEdge(a: seam.a, b: seam.b))
            }
        }
        activeSeams = active
        rebuildGraph()
        if powerActive { applyPowerHighlight() }
    }

    private func rebuildGraph() {
        graph = PathGraph(nodes: level.nodes, edges: level.edges + activeSeams)
    }

    // MARK: - Döndürme

    func rotate() {
        guard !isBusy, !reachedGoal else { return }
        guard let rotator = level.rotators.first, let node = rotatorNodes[rotator.id] else { return }

        let radians = CGFloat(rotator.stepDegrees * .pi / 180)
        let action = SCNAction.rotateBy(x: 0, y: radians, z: 0, duration: 0.5)
        action.timingMode = .easeInEaseOut
        isBusy = true
        node.runAction(action) { [weak self] in
            DispatchQueue.main.async {
                self?.isBusy = false
                self?.recomputeSeams()
            }
        }
    }

    // MARK: - Tap-to-move

    func handleTap(hitResults: [SCNHitTestResult]) {
        guard !isBusy, !reachedGoal else { return }
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
        isBusy = true
        rig.walk()

        var actions: [SCNAction] = []
        for id in path.dropFirst() {
            let target = walkWorldPosition(id)
            let turn = SCNAction.run { [weak self] node in
                let from = node.presentation.position
                self?.rig.face(dx: target.x - from.x, dz: target.z - from.z)
            }
            let step = SCNAction.move(to: target, duration: 0.34)
            step.timingMode = .easeInEaseOut
            actions.append(.sequence([turn, step]))
        }

        rig.root.runAction(.sequence(actions)) { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.currentNodeID = path.last ?? self.currentNodeID
                self.movesCount += 1
                self.isBusy = false
                self.rig.idle()
                if self.currentNodeID == self.level.goalID {
                    self.reachedGoal = true
                    self.rig.power()
                }
                if self.powerActive { self.applyPowerHighlight() }
            }
        }
    }

    // MARK: - Yol Gösteren gücü

    func togglePower() {
        powerActive.toggle()
    }

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
