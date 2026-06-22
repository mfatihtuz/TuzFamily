import Foundation

/// Bir karakterin gücü (GDD §6).
///
/// - `main` (Ana Güç / Rare): kişiye özel, eşsiz, paylaşılmaz.
/// - `side` (Yan Güç): ortak havuz, kesişebilir.
struct Power: Identifiable, Hashable {
    enum Kind: String {
        case main
        case side

        var label: String {
            switch self {
            case .main: return "Ana Güç"
            case .side: return "Yan Güç"
            }
        }
    }

    let name: String
    let detail: String
    let kind: Kind

    var id: String { "\(kind.rawValue)-\(name)" }
}
