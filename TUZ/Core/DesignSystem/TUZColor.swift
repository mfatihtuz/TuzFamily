import SwiftUI

/// TÜZ renk paleti (GDD §4).
///
/// Sıcak taş/krem zemin, turkuaz–çini mavisi vurgular, pirinç/altın detaylar.
/// Premium ve ağırbaşlı; Candy-Crush parlaklığından ve low-poly çocuksuluktan
/// kaçınır. Renkler koddan hex ile üretilir (tek kaynak burası).
enum TUZColor {
    // Zemin & yüzeyler
    static let cream = Color(hex: "#F5ECD7")   // sıcak krem zemin
    static let sand = Color(hex: "#EADFC4")    // ikincil yüzey
    static let stone = Color(hex: "#D8C9A8")   // kenarlık / ayraç

    // Metin
    static let ink = Color(hex: "#3A3027")     // koyu sıcak kahve (ana metin)
    static let inkSoft = Color(hex: "#6E6253") // ikincil metin

    // Vurgular
    static let turquoise = Color(hex: "#1C6E8C") // turkuaz–çini (ana vurgu)
    static let cini = Color(hex: "#14546B")      // derin çini mavisi
    static let brass = Color(hex: "#C8A951")     // pirinç / altın

    // Kelimelik geri bildirim renkleri (mat, palet uyumlu)
    static let correct = Color(hex: "#5B8A5A") // doğru yer (yeşil)
    static let present = Color(hex: "#D2A24C") // kelimede var, yanlış yer (amber)
    static let absent = Color(hex: "#9C948A")  // kelimede yok (gri)

    // Klavye
    static let keyBackground = Color(hex: "#CBBE9E")
    static let keyText = Self.ink
}
