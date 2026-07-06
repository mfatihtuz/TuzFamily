import SceneKit
import UIKit

/// Riglenmiş placeholder figür (GDD §6, §11 sözleşmesi).
///
/// Kök node `Character_<Ad>` adını taşır; hareketler `idle()/walk()/power()`
/// metotlarıyla tetiklenir. Meshy'den gelen gerçek riglenmiş USDZ (aynı node adı +
/// aynı `Idle/Walk/Power_<GüçAdı>` klipleri) tek satır değişimle yerine konabilir;
/// çağrı yerleri değişmeden kalır. Şimdilik animasyon `SCNAction` ile yapılır.
///
/// Silüet: vakur bir cüppe (koni) + baş — aile temasına uygun, çocuksu değil.
final class CharacterRig {
    let root: SCNNode
    private let visual: SCNNode

    init(name: String, color: UIColor) {
        root = SCNNode()
        root.name = "Character_\(name)"

        visual = SCNNode()
        visual.name = "Visual"

        let robeGeometry = SCNCone(topRadius: 0.07, bottomRadius: 0.2, height: 0.52)
        robeGeometry.firstMaterial?.lightingModel = .constant
        robeGeometry.firstMaterial?.diffuse.contents = color
        let robe = SCNNode(geometry: robeGeometry)
        robe.position = SCNVector3(0, 0.26, 0)
        robe.castsShadow = false

        let headGeometry = SCNSphere(radius: 0.13)
        headGeometry.firstMaterial?.lightingModel = .constant
        headGeometry.firstMaterial?.diffuse.contents = color.withAlphaComponent(0.88)
        let head = SCNNode(geometry: headGeometry)
        head.position = SCNVector3(0, 0.6, 0)
        head.castsShadow = false

        visual.addChildNode(robe)
        visual.addChildNode(head)
        root.addChildNode(visual)

        idle()
    }

    /// "Idle": yumuşak nefes/bekleme salınımı.
    func idle() {
        visual.removeAction(forKey: "anim")
        let up = SCNAction.moveBy(x: 0, y: 0.025, z: 0, duration: 0.9)
        up.timingMode = .easeInEaseOut
        visual.runAction(.repeatForever(.sequence([up, up.reversed()])), forKey: "anim")
    }

    /// "Walk": daha hızlı adım salınımı.
    func walk() {
        visual.removeAction(forKey: "anim")
        let up = SCNAction.moveBy(x: 0, y: 0.06, z: 0, duration: 0.18)
        up.timingMode = .easeInEaseOut
        visual.runAction(.repeatForever(.sequence([up, up.reversed()])), forKey: "anim")
    }

    /// "Power_<GüçAdı>": kısa bir vurgu (ölçek darbesi).
    func power() {
        let pulse = SCNAction.sequence([
            SCNAction.scale(to: 1.12, duration: 0.15),
            SCNAction.scale(to: 1.0, duration: 0.15)
        ])
        visual.runAction(pulse)
    }

    /// Hareket yönüne döndürür (Y ekseni etrafında).
    func face(dx: Float, dz: Float) {
        guard abs(dx) > 0.0001 || abs(dz) > 0.0001 else { return }
        root.eulerAngles.y = Float(atan2(Double(dx), Double(dz)))
    }
}
