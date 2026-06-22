import SwiftUI

/// Paylaşılan görünüm bileşenleri ve düzenleyiciler (tasarım token'ları, GDD §4).

/// Ekranların ortak sıcak gradyan zemini.
struct ScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [TUZColor.cream, TUZColor.sand],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
    }
}

/// Yumuşak gölgeli, ince kenarlıklı kart yüzeyi.
struct CardStyle: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(TUZColor.cream)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(TUZColor.stone, lineWidth: 1)
            )
            .shadow(color: TUZColor.ink.opacity(0.12), radius: 10, x: 0, y: 6)
    }
}

extension View {
    func tuzScreenBackground() -> some View { modifier(ScreenBackground()) }
    func tuzCard(padding: CGFloat = 16) -> some View { modifier(CardStyle(padding: padding)) }
}

/// Renkli, yuvarlak kimlik rozeti (aile üyeleri ve placeholder figürler için).
struct MemberBadge: View {
    let initial: String
    let color: Color
    var size: CGFloat = 44

    var body: some View {
        Circle()
            .fill(color.gradient)
            .frame(width: size, height: size)
            .overlay(
                Text(initial)
                    .font(.system(size: size * 0.42, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
            )
            .overlay(
                Circle().strokeBorder(.white.opacity(0.6), lineWidth: 1)
            )
            .shadow(color: color.opacity(0.35), radius: 4, x: 0, y: 2)
    }
}
