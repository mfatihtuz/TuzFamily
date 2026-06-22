import UIKit

/// Yolculuk sahnesinin malzeme/renk paleti (GDD §4 ile uyumlu, UIColor).
/// SceneKit tarafı SwiftUI `Color` değil `UIColor` kullandığı için ayrı tutulur.
enum SceneArt {
    static let sky = UIColor(hex: "#EFE6CF")        // sahne zemini (gökyüzü)

    // Taş kütle (sütun gövdeleri) ve yürüme yüzeyi (üst kapak)
    static let stoneSide = UIColor(hex: "#C7B187")  // sütun yan yüzü (gölgeli)
    static let stoneTop = UIColor(hex: "#EADDBC")   // yürüme yüzeyi (aydınlık)
    static let base = UIColor(hex: "#B19C75")       // zemin platosu

    // Özel karolar (üst yüzey rengi)
    static let startTop = UIColor(hex: "#3E9DB8")   // başlangıç (turkuaz)
    static let goalTop = UIColor(hex: "#D8B24C")    // hedef (pirinç)

    static let glow = UIColor(hex: "#F0D27A")       // Yol Gösteren parıltısı
    static let none = UIColor.black                 // emission kapalı

    // Sahne ölçüleri (grid → dünya birimi).
    // ÖNEMLİ: yatay ve dikey birim EŞİT olmalı. Kamera dünya (1,1,1) yönüne baktığı
    // için perspektif hizalama (imkânsız geometri) ancak ölçek tekdüze olduğunda
    // doğru çalışır: grid'de (k,k,k) farkı → dünyada (k,k,k) → ekranda çakışma.
    static let unit: Float = 1.0        // yatay karo aralığı
    static let unitHeight: Float = 1.0  // bir yükseklik kademesi (= unit)

    static let columnWidth: CGFloat = 0.98  // sütun gövde genişliği (neredeyse bitişik → kütle)
    static let capWidth: CGFloat = 0.9      // üst kapak (aralarda ince yiv → okunaklı)
    static let capHeight: CGFloat = 0.16    // üst kapak kalınlığı
    static let baseDrop: Float = 1.6        // sütunların zemine inme derinliği
}
