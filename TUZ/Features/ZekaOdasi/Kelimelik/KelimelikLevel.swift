import Foundation

/// Kelimelik'te bir zorluk seviyesi. Deneme sayısı harf sayısından türetilir:
/// 3-4 harf → 4 deneme, 5-6 harf → 5 deneme, 7-8 harf → 6 deneme.
struct KelimelikLevel: Identifiable, Hashable {
    let index: Int          // 0 tabanlı
    let wordLength: Int
    let hintCount: Int      // açık gelecek harf sayısı

    var id: Int { index }
    var number: Int { index + 1 }

    var attempts: Int {
        switch wordLength {
        case 3, 4: return 4
        case 5, 6: return 5
        default: return 6   // 7, 8
        }
    }

    var gridLabel: String { "\(wordLength) harf · \(attempts) deneme" }
}

/// Kullanıcı tanımlı 12 seviyelik akış: (harf sayısı, ipucu sayısı).
enum KelimelikProgression {
    private static let layout: [(length: Int, hints: Int)] = [
        (3, 1),   // 1
        (4, 1),   // 2
        (4, 1),   // 3
        (5, 2),   // 4
        (5, 1),   // 5
        (5, 1),   // 6
        (6, 2),   // 7
        (6, 1),   // 8
        (7, 2),   // 9
        (7, 1),   // 10
        (8, 3),   // 11
        (8, 2)    // 12
    ]

    static let levels: [KelimelikLevel] = layout.enumerated().map { i, pair in
        KelimelikLevel(index: i, wordLength: pair.length, hintCount: pair.hints)
    }

    static var count: Int { levels.count }

    static func level(at index: Int) -> KelimelikLevel {
        levels[max(0, min(index, levels.count - 1))]
    }
}
