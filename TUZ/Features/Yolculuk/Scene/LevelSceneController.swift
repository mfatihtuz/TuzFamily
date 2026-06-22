import SceneKit
import UIKit
import Observation
import simd

/// Bir bölümün SceneKit sahnesini kuran ve oynanışı yöneten denetleyici.
///
/// Monument Valley görünümü için **flat gölgeleme** (`.constant` lighting):
/// gerçekçi ışık/gölge yok; her küp yüzüne yönüne göre düz ton verilir (üst
/// aydınlık, iki yan iki ton). Kamera ortografik + eğik izometrik (perspektif
/// kısalması olmadığından "imkânsız geometri" mümkün — GDD §4, §10).
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

    private var nodeWorldPos: [String: SCNVector3] = [:]
    private var tileNodes: [String: SCNNode] = [:]
    private var tileTopMaterials: [String: SCNMaterial] = [:]
    private var tileTopBaseColor: [String: UIColor] = [:]
    private var rotatorNodes: [String: SCNNode] = [:]
    private var activeSeams: [LevelEdge] = []
    private var currentNodeID: String
    private var isBusy = false

    private var sceneCenter = SCNVector3(0, 0, 0)
    private var sceneRadius: Float = 6
    private var baseY: Float = -1.4

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
        camera.orthographicScale = Double(sceneRadius) * 0.62 + 2.0
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

    // MARK: - Flat malzeme yardımcıları

    private func flatMaterial(_ color: UIColor) -> SCNMaterial {
        let m = SCNMaterial()
        m.lightingModel = .constant   // ışıktan etkilenmez → düz, grafiksel MV görünümü
        m.diffuse.contents = color
        m.isDoubleSided = false
        return m
    }

    /// Küpün yüzlerine yönüne göre düz ton verir (üst aydınlık, iki yan iki ton).
    /// SCNBox yüz sırası: front(+Z), right(+X), back(−Z), left(−X), top(+Y), bottom(−Y).
    private func faceMaterials(top: UIColor) -> [SCNMaterial] {
        [
            flatMaterial(SceneArt.stoneSideDark),   // front (+Z) — kameraya bakan koyu yan
            flatMaterial(SceneArt.stoneSideLight),  // right (+X) — kameraya bakan açık yan
            flatMaterial(SceneArt.stoneSideDark),   // back
            flatMaterial(SceneArt.stoneSideLight),  // left
            flatMaterial(top),                      // top (+Y) — yürüme yüzeyi
            flatMaterial(SceneArt.stoneSideDark)    // bottom
        ]
    }

    // MARK: - Zemin

    private func buildGround() {
        let size = CGFloat(sceneRadius * 2.6 + 8)
        let ground = SCNBox(width: size, height: 0.6, length: size, chamferRadius: 0)
        ground.materials = [flatMaterial(SceneArt.ground)]
        let node = SCNNode(geometry: ground)
        node.position = SCNVector3(sceneCenter.x, baseY - 0.3, sceneCenter.z)
        scene.rootNode.addChildNode(node)
    }

    // MARK: - Döndürücüler + karolar

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

            let tile = SCNNode()
            tile.name = "tile:\(node.id)"

            let height = isRotator ? CGFloat(1.0) : CGFloat(max(0.8, top.y - baseY))
            let box = SCNBox(width: SceneArt.columnWidth, height: height,
                             length: SceneArt.columnWidth, chamferRadius: 0.0)
            let materials = faceMaterials(top: topColor(for: node.id))
            box.materials = materials
            let boxNode = SCNNode(geometry: box)
            boxNode.position = SCNVector3(0, -Float(height) / 2, 0)
            tile.addChildNode(boxNode)

            tileTopMaterials[node.id] = materials[4]
            tileTopBaseColor[node.id] = topColor(for: node.id)

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

    private func topColor(for id: String) -> UIColor {
        if id == level.startID { return SceneArt.startTop }
        if id == level.goalID { return SceneArt.goalTop }
        return SceneArt.stoneTop
    }

    private func addGoalMarker() {
        guard let goalTile = tileNodes[level.goalID] else { return }
        let pyramid = SCNPyramid(width: 0.32, height: 0.44, length: 0.32)
        pyramid.materials = [flatMaterial(SceneArt.glow)]
        let marker = SCNNode(geometry: pyramid)
        marker.position = SCNVector3(0, 0.5, 0)
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
        for (id, material) in tileTopMaterials {
            material.diffuse.contents = tileTopBaseColor[id]
        }
        guard powerActive else { return }
        guard let path = graph.shortestPath(from: currentNodeID, to: level.goalID) else { return }
        for id in path {
            tileTopMaterials[id]?.diffuse.contents = SceneArt.glow
        }
    }
}
