import SwiftUI
import SwiftData

/// Profiller — aile üyeleri, güçleri ve zorluk profilleri (GDD §6, §5.5).
/// Bir üyeye dokunmak onu "aktif oyuncu" yapar; bilgi tuşu güç detaylarını açar.
struct ProfillerView: View {
    @Query(sort: \FamilyMember.order) private var members: [FamilyMember]
    @AppStorage("activeMemberID") private var activeMemberID = "bilal"
    @State private var detailMember: FamilyMember?

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Text("Bir üyeye dokunarak aktif oyuncuyu seç.")
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
        let isActive = member.memberID == activeMemberID

        // Kartın geneline dokunmak aktif oyuncuyu seçer; "i" tuşu detayları açar.
        // İç içe Button kullanmamak için seçim onTapGesture ile yapılır.
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

            VStack(spacing: 10) {
                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(TUZColor.correct)
                }
                Button {
                    detailMember = member
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(TUZColor.turquoise)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .tuzCard()
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(isActive ? TUZColor.turquoise : .clear, lineWidth: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            activeMemberID = member.memberID
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
