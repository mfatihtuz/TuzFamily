import UIKit

/// Yolculuk sahnesinin malzeme/renk paleti (GDD §4 ile uyumlu, UIColor).
/// SceneKit tarafı SwiftUI `Color` değil `UIColor` kullandığı için ayrı tutulur.
enum SceneArt {
    static let sky = UIColor(hex: "#EADFC4")        // sahne zemini (gökyüzü)
    static let stone = UIColor(hex: "#D8C9A8")      // standart platform
    static let stoneEdge = UIColor(hex: "#C3B188")  // platform kenar tonu
    static let start = UIColor(hex: "#1C6E8C")      // başlangıç karosu (turkuaz)
    static let goal = UIColor(hex: "#C8A951")       // hedef karosu (pirinç)
    static let glow = UIColor(hex: "#E8C766")       // Yol Gösteren parıltısı
    static let none = UIColor.black                 // emission kapalı

    // Sahne ölçüleri (grid → dünya birimi)
    static let unit: Float = 1.25       // yatay karo aralığı
    static let unitHeight: Float = 0.7  // bir yükseklik kademesi
    static let blockHeight: CGFloat = 0.5
}
