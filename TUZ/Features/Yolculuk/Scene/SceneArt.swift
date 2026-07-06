import UIKit

/// Yolculuk sahnesinin malzeme/renk paleti (GDD §4 ile uyumlu, UIColor).
///
/// Monument Valley görünümü için **flat (düz) gölgeleme** kullanılır: malzemeler
/// `.constant` lighting model'dir (ışıktan etkilenmez), küpün her yüzüne yönüne
/// göre farklı düz ton verilir (üst aydınlık, yan yüzler iki ton). Gerçekçi gölge
/// YOKtur; biçim, yüz tonlarından okunur.
enum SceneArt {
    static let sky = UIColor(hex: "#ECE3CB")          // düz, sıcak arka plan

    // Taş tonları (flat). Üst = aydınlık yürüme yüzeyi; yanlar = iki ton.
    static let stoneTop = UIColor(hex: "#F0E5C7")     // üst yüz (aydınlık)
    static let stoneSideLight = UIColor(hex: "#D9C59C")
    static let stoneSideDark = UIColor(hex: "#BCA47B")
    static let ground = UIColor(hex: "#B2A079")       // zemin platosu (biraz koyu)

    // Özel karoların üst yüzü
    static let startTop = UIColor(hex: "#3E9DB8")     // başlangıç (turkuaz)
    static let goalTop = UIColor(hex: "#D8B24C")      // hedef (pirinç)

    static let glow = UIColor(hex: "#F4D879")         // Yol Gösteren parıltısı

    // Sahne ölçüleri (grid → dünya birimi).
    // ÖNEMLİ: yatay ve dikey birim EŞİT olmalı. Kamera dünya (1,1,1) yönüne baktığı
    // için perspektif hizalama ancak ölçek tekdüze olduğunda doğru çalışır.
    static let unit: Float = 1.0
    static let unitHeight: Float = 1.0

    static let columnWidth: CGFloat = 1.0   // bitişik → kütle hissi
    static let baseDrop: Float = 1.4        // sütunların zemine inme derinliği
}
