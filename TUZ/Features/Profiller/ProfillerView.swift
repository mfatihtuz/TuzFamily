import SwiftUI
import SwiftData

/// Profiller — aile üyeleri, güçleri ve hikâyedeki rolleri (GDD §6, §5.5).
/// Bilgi amaçlıdır; bir üyeye dokununca güç detayları açılır. "Ben" rozeti
/// oyuncunun kimliğini gösterir (kimlik Onboarding/Ayarlar'dan değişir).
struct ProfillerView: View {
    @Query(sort: \FamilyMember.order) private var members: [FamilyMember]
    @AppStorage("playerMemberID") private var playerMemberID = ""
    @State private var detailMember: FamilyMember?

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Text("Ailenin bireyleri, güçleri ve hikâyedeki rolleri. Detay için dokun.")
                    .font(TUZFont.caption)
                    .foregroundStyle(TUZColor.inkSoft)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(members) { member in
                    memberRow(member)
                }
            }
            .padding()
        }
        .tuzScreenBackground()
        .navigationTitle("Profiller")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $detailMember) { member in
            ProfileDetailSheet(member: member)
        }
    }

    private func memberRow(_ member: FamilyMember) -> some View {
        let isMe = member.memberID == playerMemberID

        // Bilgi amaçlı: karta dokununca güç detayları açılır. "Ben" rozeti
        // oyuncunun kimliğini gösterir (burada kimlik DEĞİŞTİRİLMEZ).
        return HStack(spacing: 14) {
            MemberBadge(
                initial: String(member.name.prefix(1)),
                color: Color(hex: member.colorHex),
                size: 50
            )

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(member.name)
                        .font(TUZFont.headline)
                        .foregroundStyle(TUZColor.ink)
                    Text("·")
                        .foregroundStyle(TUZColor.inkSoft)
                    Text(member.nickname)
                        .font(TUZFont.callout)
                        .foregroundStyle(TUZColor.inkSoft)
                }
                Text("\(member.roleTitle) · Zorluk \(member.difficultyText)")
                    .font(TUZFont.caption)
                    .foregroundStyle(TUZColor.inkSoft)
                HStack(spacing: 6) {
                    powerTag(member.mainPowerName, color: TUZColor.cini)
                    powerTag(member.sidePowerName, color: TUZColor.brass)
                }
                .padding(.top, 2)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                if isMe {
                    Text("Ben")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(TUZColor.turquoise, in: Capsule())
                }
                Image(systemName: "info.circle")
                    .foregroundStyle(TUZColor.turquoise)
                    .font(.title3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .tuzCard()
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(isMe ? TUZColor.turquoise : .clear, lineWidth: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            detailMember = member
        }
    }

    private func powerTag(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.13))
            .clipShape(Capsule())
    }
}

/// Bir üyenin ana ve yan gücünün tam açıklamasını gösteren sayfa.
private struct ProfileDetailSheet: View {
    let member: FamilyMember
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 14) {
                        MemberBadge(
                            initial: String(member.name.prefix(1)),
                            color: Color(hex: member.colorHex),
                            size: 56
                        )
                        VStack(alignment: .leading, spacing: 2) {
                            Text(member.name)
                                .font(TUZFont.title)
                                .foregroundStyle(TUZColor.ink)
                            Text("\(member.nickname) · \(member.roleTitle)")
                                .font(TUZFont.callout)
                                .foregroundStyle(TUZColor.inkSoft)
                        }
                    }

                    powerSection(member.mainPower)
                    powerSection(member.sidePower)
                }
                .padding()
            }
            .tuzScreenBackground()
            .navigationTitle("Karakter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
    }

    private func powerSection(_ power: Power) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(power.kind.label)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(power.kind == .main ? TUZColor.cini : TUZColor.brass)
                    .clipShape(Capsule())
                Text(power.name)
                    .font(TUZFont.headline)
                    .foregroundStyle(TUZColor.ink)
            }
            Text(power.detail)
                .font(TUZFont.body)
                .foregroundStyle(TUZColor.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .tuzCard()
    }
}

#Preview {
    NavigationStack {
        ProfillerView()
    }
    .modelContainer(PersistenceController.preview.container)
}
