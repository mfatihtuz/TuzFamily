import SwiftUI

/// Kelimelik kutu ızgarası. Sütun/satır sayısı seviyeye göre değişir; kutular
/// satır genişliğini eşit paylaşır (3 harfte büyük, 6 harfte küçük).
struct KelimelikGridView: View {
    let rows: [[LetterTile]]
    var spacing: CGFloat = 6

    var body: some View {
        VStack(spacing: spacing) {
            ForEach(rows.indices, id: \.self) { r in
                HStack(spacing: spacing) {
                    ForEach(rows[r].indices, id: \.self) { c in
                        TileView(tile: rows[r][c])
                    }
                }
            }
        }
    }
}

private struct TileView: View {
    let tile: LetterTile

    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(fillColor)
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 1.5)
            )
            .overlay(
                Text(tile.letter)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .foregroundStyle(textColor)
            )
    }

    private var fillColor: Color {
        switch tile.feedback {
        case .correct: return TUZColor.correct
        case .present: return TUZColor.present
        case .absent: return TUZColor.absent
        case .hint: return TUZColor.sand
        case .empty: return TUZColor.cream
        }
    }

    private var borderColor: Color {
        switch tile.feedback {
        case .hint: return TUZColor.brass
        case .empty: return tile.letter.isEmpty ? TUZColor.stone : TUZColor.inkSoft
        default: return .clear
        }
    }

    private var textColor: Color {
        switch tile.feedback {
        case .correct, .present, .absent: return .white
        case .hint: return TUZColor.cini
        case .empty: return TUZColor.ink
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        KelimelikGridView(rows: [[
            .init(letter: "K", feedback: .hint),
            .init(letter: "", feedback: .empty),
            .init(letter: "L", feedback: .hint)
        ]])
        KelimelikGridView(rows: [
            [.init(letter: "K", feedback: .correct),
             .init(letter: "O", feedback: .present),
             .init(letter: "L", feedback: .absent)],
            [.init(letter: "", feedback: .empty),
             .init(letter: "", feedback: .empty),
             .init(letter: "", feedback: .empty)]
        ])
    }
    .frame(maxWidth: 220)
    .padding()
}
