import Foundation

/// Kelimelik'te bir zorluk seviyesi. Izgara büyüdükçe zorlaşır (GDD §8, "seviye ölçekli").
///
/// İpucu sayısı, ızgaranın en fazla ~%12'si kadardır (kullanıcı isteği):
/// `hintCount = min(3, floor(0.12 × wordLength × attempts))`.
struct KelimelikLevel: Identifiable, Hashable {
    let index: Int          // 0 tabanlı
    let wordLength: Int
    let attempts: Int

    var id: Int { index }
    var number: Int { index + 1 }   // gösterim için 1 tabanlı

    var hintCount: Int {
        min(3, Int(0.12 * Double(wordLength * attempts)))
    }

    var gridLabel: String { "\(wordLength) harf · \(attempts) deneme" }
}

/// Kolaydan zora kademeli seviye dizisi (3 harf → 6 harf).
enum KelimelikProgression {
    /// (wordLength, attempts) — ızgara büyür, sona doğru deneme azalıp zorlaşır.
    private static let layout: [(Int, Int)] = [
        (3, 4),   // S1: kısa kelime, bol deneme
        (4, 5),   // S2
        (5, 6),   // S3 (klasik)
        (6, 6),   // S4
        (5, 5),   // S5
        (6, 5),   // S6
        (6, 4)    // S7: en zor
    ]

    static let levels: [KelimelikLevel] = layout.enumerated().map { i, pair in
        KelimelikLevel(index: i, wordLength: pair.0, attempts: pair.1)
    }

    static var count: Int { levels.count }

    /// İndeks taşarsa son seviyeye sabitlenir.
    static func level(at index: Int) -> KelimelikLevel {
        let clamped = max(0, min(index, levels.count - 1))
        return levels[clamped]
    }
}
