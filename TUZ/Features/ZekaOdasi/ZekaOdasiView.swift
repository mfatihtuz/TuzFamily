import SwiftUI
import SwiftData

/// Zeka Odası — mini oyunların hub'ı (GDD §8).
///
/// MVP'de yalnızca Kelimelik tam çalışır; Trivia, Pasaparola ve Matematik
/// "Yakında" olarak görünür (Faz 1 devamı).
struct ZekaOdasiView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @AppStorage("activeMemberID") private var activeMemberID = "bilal"

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(GameKind.allCases) { game in
                    gameCard(for: game)
                }
            }
            .padding()
        }
        .tuzScreenBackground()
        .navigationTitle("Zeka Odası")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func gameCard(for game: GameKind) -> some View {
        let played = game.isAvailable && hasPlayedToday(game)

        Button {
            if game == .kelimelik {
                router.push(.kelimelik)
            }
        } label: {
            HStack(spacing: 16) {
                Image(systemName: game.systemImage)
                    .font(.system(size: 28))
                    .foregroundStyle(game.isAvailable ? TUZColor.turquoise : TUZColor.inkSoft)
                    .frame(width: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(game.title)
                        .font(TUZFont.headline)
                        .foregroundStyle(TUZColor.ink)
                    Text(game.subtitle)
                        .font(TUZFont.caption)
                        .foregroundStyle(TUZColor.inkSoft)
                }

                Spacer()

                if !game.isAvailable {
                    statusTag(text: "Yakında", color: TUZColor.inkSoft)
                } else if played {
                    statusTag(text: "Bugün ✓", color: TUZColor.correct)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(TUZColor.inkSoft)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .tuzCard()
            .opacity(game.isAvailable ? 1 : 0.6)
        }
        .buttonStyle(.plain)
        .disabled(!game.isAvailable)
    }

    private func statusTag(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }

    private func hasPlayedToday(_ game: GameKind) -> Bool {
        ScoreService(context: modelContext)
            .hasPlayed(memberID: activeMemberID, game: game, on: .now)
    }
}

#Preview {
    NavigationStack {
        ZekaOdasiView()
    }
    .environment(AppRouter())
    .modelContainer(PersistenceController.preview.container)
}
