import Foundation

/// Zeka Odası mini oyunları (GDD §8).
enum GameKind: String, CaseIterable, Identifiable {
    case kelimelik
    case trivia
    case pasaparola
    case matematik

    var id: String { rawValue }

    var title: String {
        switch self {
        case .kelimelik: return "Kelimelik"
        case .trivia: return "TÜZ Trivia"
        case .pasaparola: return "Pasaparola"
        case .matematik: return "Matematik"
        }
    }

    var subtitle: String {
        switch self {
        case .kelimelik: return "Türkçe 5 harf · günlük kelime"
        case .trivia: return "Genel kültür + aile soruları"
        case .pasaparola: return "A–Z harf çarkı"
        case .matematik: return "Zihinden işlem ve örüntü"
        }
    }

    var systemImage: String {
        switch self {
        case .kelimelik: return "square.grid.3x3.fill"
        case .trivia: return "lightbulb.fill"
        case .pasaparola: return "circle.grid.cross.fill"
        case .matematik: return "function"
        }
    }

    /// MVP Faz 1'de yalnızca Kelimelik tam çalışır; diğerleri "Yakında".
    var isAvailable: Bool {
        self == .kelimelik
    }
}
