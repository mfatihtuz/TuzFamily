import SwiftUI

/// Kelimelik tahmin ızgarası (6 satır × 5 kutu).
struct KelimelikGridView: View {
    let rows: [[LetterTile]]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(rows.indices, id: \.self) { rowIndex in
                HStack(spacing: 8) {
                    ForEach(rows[rowIndex].indices, id: \.self) { colIndex in
                        TileView(tile: rows[rowIndex][colIndex])
                    }
                }
            }
        }
    }
}

/// Tek bir harf kutusu.
private struct TileView: View {
    let tile: LetterTile

    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(fillColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 1.5)
            )
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                Text(tile.letter)
                    .font(TUZFont.tile)
                    .minimumScaleFactor(0.5)
                    .foregroundStyle(textColor)
            )
    }

    private var fillColor: Color {
        switch tile.feedback {
        case .correct: return TUZColor.correct
        case .present: return TUZColor.present
        case .absent: return TUZColor.absent
        case .empty: return TUZColor.cream
        }
    }

    private var borderColor: Color {
        switch tile.feedback {
        case .empty: return tile.letter.isEmpty ? TUZColor.stone : TUZColor.inkSoft
        default: return .clear
        }
    }

    private var textColor: Color {
        tile.feedback == .empty ? TUZColor.ink : .white
    }
}

#Preview {
    KelimelikGridView(rows: [
        [.init(letter: "K", feedback: .correct),
         .init(letter: "A", feedback: .present),
         .init(letter: "L", feedback: .absent),
         .init(letter: "E", feedback: .correct),
         .init(letter: "M", feedback: .absent)],
        [.init(letter: "S", feedback: .empty),
         .init(letter: "", feedback: .empty),
         .init(letter: "", feedback: .empty),
         .init(letter: "", feedback: .empty),
         .init(letter: "", feedback: .empty)]
    ])
    .padding()
}
