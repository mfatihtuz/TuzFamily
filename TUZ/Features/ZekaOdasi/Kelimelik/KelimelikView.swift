import SwiftUI
import SwiftData

/// Kelimelik ekranı — kademeli seviyeler, ipucu satırı, kullanıcı dostu akış.
/// Yeni seviye kazanınca skor aile havuzuna yazılır.
struct KelimelikView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FamilyMember.order) private var members: [FamilyMember]

    let memberID: String
    @State private var vm: KelimelikViewModel

    init(memberID: String) {
        self.memberID = memberID
        _vm = State(initialValue: KelimelikViewModel(memberID: memberID))
    }

    private var gridWidth: CGFloat {
        // 3 harfte büyük, 8 harfte sığacak şekilde küçük kutular
        min(360, CGFloat(vm.wordLength) * 46)
    }

    var body: some View {
        VStack(spacing: 12) {
            header

            if vm.hasHints {
                VStack(spacing: 4) {
                    Text("İpucu")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(TUZColor.inkSoft)
                    KelimelikGridView(rows: [vm.hintRow], spacing: 5)
                        .frame(width: gridWidth)
                }
            }

            KelimelikGridView(rows: vm.grid)
                .frame(width: gridWidth)

            statusArea

            Spacer(minLength: 0)

            KelimelikKeyboardView(
                letterStates: vm.letterStates,
                isEnabled: !vm.state.isFinished,
                onLetter: { vm.tap($0) },
                onDelete: { vm.deleteLast() },
                onEnter: { vm.submit() }
            )
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
        .padding(.top, 8)
        .tuzScreenBackground()
        .navigationTitle("Kelimelik")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vm.onScore = { points in
                ScoreService(context: modelContext).record(
                    memberID: memberID, game: .kelimelik, points: points,
                    detail: "seviye"
                )
            }
        }
    }

    // MARK: - Başlık

    private var header: some View {
        VStack(spacing: 3) {
            Text("Seviye \(vm.level.number)")
                .font(TUZFont.headline)
                .foregroundStyle(TUZColor.cini)
            Text(vm.level.gridLabel)
                .font(TUZFont.caption)
                .foregroundStyle(TUZColor.inkSoft)
        }
    }

    // MARK: - Durum / sonuç

    @ViewBuilder
    private var statusArea: some View {
        switch vm.state {
        case .playing:
            Text(vm.message ?? " ")
                .font(TUZFont.callout)
                .foregroundStyle(TUZColor.cini)
                .frame(height: 24)
                .animation(.easeInOut, value: vm.message)

        case .won:
            resultCard(
                title: vm.isLastLevel ? "Tüm seviyeleri bitirdin! 🎉" : "Aferin! 🎉",
                detail: "+\(vm.earnedPoints) puan · aile havuzuna eklendi",
                buttonTitle: vm.isLastLevel ? "Yeniden Oyna" : "Sonraki Seviye",
                action: { vm.isLastLevel ? vm.retry() : vm.nextLevel() },
                color: TUZColor.correct
            )

        case .lost(let answer):
            resultCard(
                title: "Bu sefer olmadı",
                detail: "Kelime: \(answer)",
                buttonTitle: "Tekrar Dene",
                action: { vm.retry() },
                color: TUZColor.inkSoft
            )
        }
    }

    private func resultCard(title: String, detail: String, buttonTitle: String,
                            action: @escaping () -> Void, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(TUZFont.headline)
                .foregroundStyle(color)
            Text(detail)
                .font(TUZFont.callout)
                .foregroundStyle(TUZColor.ink)
            Button(action: action) {
                Text(buttonTitle)
                    .font(TUZFont.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 11)
                    .background(TUZColor.turquoise, in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .tuzCard(padding: 12)
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        KelimelikView(memberID: "bilal")
    }
    .modelContainer(PersistenceController.preview.container)
}
