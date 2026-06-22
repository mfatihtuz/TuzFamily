import SwiftUI
import SceneKit
import UIKit

/// SCNView'ı SwiftUI'a köprüleyen sarmalayıcı. Dokunmaları yakalayıp
/// denetleyiciye iletir (tap-to-move).
struct LevelSceneView: UIViewRepresentable {
    let controller: LevelSceneController

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = controller.scene
        view.pointOfView = controller.cameraNode
        view.backgroundColor = SceneArt.sky
        view.antialiasingMode = .multisampling4X
        view.isJitteringEnabled = true
        view.allowsCameraControl = false   // sabit izometrik açı (MV)
        view.autoenablesDefaultLighting = false

        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        view.addGestureRecognizer(tap)
        context.coordinator.scnView = view
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // Sahne içeriği denetleyici tarafından doğrudan güncellenir.
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(controller: controller)
    }

    final class Coordinator: NSObject {
        let controller: LevelSceneController
        weak var scnView: SCNView?

        init(controller: LevelSceneController) {
            self.controller = controller
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let scnView else { return }
            let point = gesture.location(in: scnView)
            let hits = scnView.hitTest(point, options: [:])
            controller.handleTap(hitResults: hits)
        }
    }
}
