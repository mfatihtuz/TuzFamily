import SwiftUI

/// TÜZ tipografisi (GDD §4).
///
/// Başlıklarda serif tasarım (vakur, "premium" his); gövde metinlerde sistem
/// fontu. Dinamik tip ölçeğiyle uyumlu kalmak için sistem stilleri temel alınır.
enum TUZFont {
    static let largeTitle = Font.system(.largeTitle, design: .serif).weight(.semibold)
    static let title = Font.system(.title2, design: .serif).weight(.semibold)
    static let headline = Font.system(.headline, design: .serif)
    static let body = Font.system(.body, design: .default)
    static let callout = Font.system(.callout, design: .default)
    static let caption = Font.system(.caption, design: .default)

    /// Kelimelik kutuları için sabit, geniş harf görünümü.
    static let tile = Font.system(size: 30, weight: .bold, design: .rounded)
    static let key = Font.system(size: 18, weight: .semibold, design: .rounded)
}
