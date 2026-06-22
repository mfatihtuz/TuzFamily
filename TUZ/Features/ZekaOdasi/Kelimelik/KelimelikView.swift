import SwiftUI
import SwiftData

/// Kelimelik ekranı: ızgara + klavye + sonuç. Oyun bitince skoru aktif üyenin
/// profiline ve aile havuzuna (ScoreEntry) yazar.
struct KelimelikView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FamilyMember.order) private var members: [FamilyMember]

    let memberID: String
    @State private var vm: KelimelikViewModel

    init(memberID: String) {
        self.memberID = memberID
        _vm = State(initialValue: KelimelikViewModel(memberID: memberID))
    }

    private var activeMember: FamilyMember? {
        members.first { $0.memberID == memberID }
    }

    var body: some View {
        VStack(spacing: 12) {
            header

            KelimelikGridView(rows: vm.grid)
                .frame(maxWidth: 360)
                .padding(.horizontal)

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
            // Oyun bitince skoru havuza yaz (yalnızca ilk bitişte tetiklenir).
            vm.onComplete = { points, detail in
                ScoreService(context: modelContext).record(
                    memberID: memberID,
                    game: .kelimelik,
                    points: points,
                    detail: detail
                )
            }
        }
    }

    // MARK: - Başlık

    private var header: some View {
        VStack(spacing: 4) {
            Text("Günün Kelimesi")
                .font(TUZFont.caption)
                .foregroundStyle(TUZColor.inkSoft)
            if let member = activeMember {
                HStack(spacing: 8) {
                    MemberBadge(
                        initial: String(member.name.prefix(1)),
                        color: Color(hex: member.colorHex),
                        size: 26
                    )
                    Text(member.name)
                        .font(TUZFont.headline)
                        .foregroundStyle(TUZColor.ink)
                }
            }
        }
    }

    // MARK: - Durum / sonuç alanı

    @ViewBuilder
    private var statusArea: some View {
        switch vm.state {
        case .playing:
            Text(vm.message ?? " ")
                .font(TUZFont.callout)
                .foregroundStyle(TUZColor.cini)
                .frame(height: 24)
                .animation(.easeInOut, value: vm.message)

        case .won(let attempts):
            resultBanner(
                title: "Tebrikler! 🎉",
                detail: "\(attempts) denemede bildin.",
                points: max(0, (vm.maxAttempts - attempts + 1)) * 10,
                color: TUZColor.correct
            )

        case .lost(let answer):
            resultBanner(
                title: "Bugün olmadı",
                detail: "Kelime: \(answer)",
                points: 0,
                color: TUZColor.inkSoft
            )
        }
    }

    private func resultBanner(title: String, detail: String, points: Int, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(TUZFont.headline)
                .foregroundStyle(color)
            Text(detail)
                .font(TUZFont.callout)
                .foregroundStyle(TUZColor.ink)
            if points > 0 {
                Text("+\(points) puan · aile havuzuna eklendi")
                    .font(TUZFont.caption)
                    .foregroundStyle(TUZColor.inkSoft)
            }
            Text("Yarın yeni kelime!")
                .font(TUZFont.caption)
                .foregroundStyle(TUZColor.inkSoft)
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
