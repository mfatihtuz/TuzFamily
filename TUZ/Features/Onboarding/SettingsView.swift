import SwiftUI
import SwiftData

/// Ayarlar — oyuncu kimliğini (skor hanesini) değiştirme ve tanıtımı yeniden görme.
/// Kimlik onboarding'de seçilir; ortak telefon için buradan değiştirilebilir.
struct SettingsView: View {
    @AppStorage("playerMemberID") private var playerMemberID = ""
    @Query(sort: \FamilyMember.order) private var members: [FamilyMember]
    @State private var showOnboarding = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Kimliğim")
                    .font(TUZFont.headline)
                    .foregroundStyle(TUZColor.ink)
                Text("Skorların yazılacağı kişi. Ortak telefonda buradan değiştir.")
                    .font(TUZFont.caption)
                    .foregroundStyle(TUZColor.inkSoft)

                VStack(spacing: 10) {
                    ForEach(members) { member in
                        identityRow(member)
                    }
                }

                Divider()
                    .padding(.vertical, 8)

                Button {
                    showOnboarding = true
                } label: {
                    Label("Tanıtımı tekrar gör", systemImage: "play.circle")
                        .font(TUZFont.callout)
                        .foregroundStyle(TUZColor.turquoise)
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .tuzScreenBackground()
        .navigationTitle("Ayarlar")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showOnboarding) {
            OnboardingView { id in
                playerMemberID = id
                showOnboarding = false
            }
        }
    }

    private func identityRow(_ member: FamilyMember) -> some View {
        let selected = member.memberID == playerMemberID
        return HStack(spacing: 12) {
            MemberBadge(
                initial: String(member.name.prefix(1)),
                color: Color(hex: member.colorHex),
                size: 40
            )
            VStack(alignment: .leading, spacing: 1) {
                Text(member.name)
                    .font(TUZFont.callout)
                    .foregroundStyle(TUZColor.ink)
                Text(member.nickname)
                    .font(.caption2)
                    .foregroundStyle(TUZColor.inkSoft)
            }
            Spacer()
            if selected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(TUZColor.correct)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .tuzCard(padding: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(selected ? TUZColor.turquoise : .clear, lineWidth: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            playerMemberID = member.memberID
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(PersistenceController.preview.container)
}
