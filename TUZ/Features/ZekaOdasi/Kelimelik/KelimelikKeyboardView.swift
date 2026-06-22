import SwiftUI

/// Türkçe ekran klavyesi (29 harf) + Giriş ve Sil tuşları.
struct KelimelikKeyboardView: View {
    let letterStates: [String: LetterFeedback]
    var isEnabled: Bool = true
    let onLetter: (String) -> Void
    let onDelete: () -> Void
    let onEnter: () -> Void

    // Türk alfabesi düzeni (tüm 29 harf bu üç satırda yer alır).
    private let row1 = ["E", "R", "T", "Y", "U", "I", "O", "P", "Ğ", "Ü"]
    private let row2 = ["A", "S", "D", "F", "G", "H", "J", "K", "L", "Ş", "İ"]
    private let row3 = ["Z", "C", "V", "B", "N", "M", "Ö", "Ç"]

    var body: some View {
        VStack(spacing: 6) {
            keyRow(row1)
            keyRow(row2)
            HStack(spacing: 5) {
                specialKey(systemImage: "return", background: TUZColor.turquoise, foreground: .white, action: onEnter)
                ForEach(row3, id: \.self) { letter in
                    letterKey(letter)
                }
                specialKey(systemImage: "delete.left", background: TUZColor.stone, foreground: TUZColor.ink, action: onDelete)
            }
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.6)
    }

    private func keyRow(_ letters: [String]) -> some View {
        HStack(spacing: 5) {
            ForEach(letters, id: \.self) { letter in
                letterKey(letter)
            }
        }
    }

    private func letterKey(_ letter: String) -> some View {
        Button {
            onLetter(letter)
        } label: {
            Text(letter)
                .font(TUZFont.key)
                .foregroundStyle(foreground(for: letter))
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(background(for: letter))
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func specialKey(systemImage: String, background: Color, foreground: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(foreground)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func background(for letter: String) -> Color {
        switch letterStates[letter] {
        case .correct: return TUZColor.correct
        case .present: return TUZColor.present
        case .absent: return TUZColor.absent
        default: return TUZColor.keyBackground
        }
    }

    private func foreground(for letter: String) -> Color {
        switch letterStates[letter] {
        case .correct, .present, .absent: return .white
        default: return TUZColor.keyText
        }
    }
}

#Preview {
    KelimelikKeyboardView(
        letterStates: ["A": .correct, "S": .present, "D": .absent],
        onLetter: { _ in },
        onDelete: {},
        onEnter: {}
    )
    .padding()
}
