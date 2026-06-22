import SceneKit
import UIKit

/// Riglenmiş placeholder figür (GDD §6, §11 sözleşmesi).
///
/// Kök node `Character_<Ad>` adını taşır; hareketler `idle()/walk()/power()`
/// metotlarıyla tetiklenir. Meshy'den gelen gerçek USDZ (aynı node adı + aynı
/// `Idle/Walk/Power_<GüçAdı>` klipleri) tek satır değişimle yerine konabilir:
/// placeholder'ı `loadUSDZ(named:)` ile değiştirip aynı API korunur.
///
/// Şimdilik animasyonlar `SCNAnimationPlayer` yerine `SCNAction` ile yapılır
/// (placeholder primitive iskelet taşımaz); çağrı yerleri değişmeden kalır.
final class CharacterRig {
    /// Sahneye eklenen, hareket ettirilen kök node ("Character_<Ad>").
    let root: SCNNode

    /// Animasyonların uygulandığı görsel alt node (kök, konum için temiz kalır).
    private let visual: SCNNode

    init(name: String, color: UIColor) {
        root = SCNNode()
        root.name = "Character_\(name)"

        visual = SCNNode()
        visual.name = "Visual"

        // Gövde (kapsül) + baş (küre) — sade, renk-kodlu placeholder.
        let bodyGeometry = SCNCapsule(capRadius: 0.16, height: 0.5)
        bodyGeometry.firstMaterial?.lightingModel = .physicallyBased
        bodyGeometry.firstMaterial?.diffuse.contents = color
        let body = SCNNode(geometry: bodyGeometry)
        body.position = SCNVector3(0, 0.25, 0)

        let headGeometry = SCNSphere(radius: 0.14)
        headGeometry.firstMaterial?.lightingModel = .physicallyBased
        headGeometry.firstMaterial?.diffuse.contents = color.withAlphaComponent(0.92)
        let head = SCNNode(geometry: headGeometry)
        head.position = SCNVector3(0, 0.6, 0)

        visual.addChildNode(body)
        visual.addChildNode(head)
        root.addChildNode(visual)

        idle()
    }

    /// "Idle" karşılığı: yumuşak nefes/bekleme salınımı.
    func idle() {
        visual.removeAction(forKey: "anim")
        let up = SCNAction.moveBy(x: 0, y: 0.03, z: 0, duration: 0.9)
        up.timingMode = .easeInEaseOut
        let cycle = SCNAction.sequence([up, up.reversed()])
        visual.runAction(.repeatForever(cycle), forKey: "anim")
    }

    /// "Walk" karşılığı: daha hızlı adım salınımı.
    func walk() {
        visual.removeAction(forKey: "anim")
        let up = SCNAction.moveBy(x: 0, y: 0.06, z: 0, duration: 0.18)
        up.timingMode = .easeInEaseOut
        let cycle = SCNAction.sequence([up, up.reversed()])
        visual.runAction(.repeatForever(cycle), forKey: "anim")
    }

    /// "Power_<GüçAdı>" karşılığı: kısa bir vurgu (ölçek darbesi).
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
