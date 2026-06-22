import SwiftUI
import SwiftData

/// Aile Meclisi — ana hub (GDD §6.4). Buradan Yolculuk, Zeka Odası, Profiller
/// ve Aile Havuzu'na geçilir. Üstte o an aktif olan aile üyesi gösterilir.
struct AileMeclisiView: View {
    @Environment(AppRouter.self) private var router
    @AppStorage("activeMemberID") private var activeMemberID = "bilal"
    @Query(sort: \FamilyMember.order) private var members: [FamilyMember]

    private var activeMember: FamilyMember? {
        members.first { $0.memberID == activeMemberID } ?? members.first
    }

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                hubGrid
            }
            .padding()
        }
        .tuzScreenBackground()
        .navigationTitle("Aile Meclisi")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Başlık

    private var header: some View {
        VStack(spacing: 12) {
            Text("TÜZ")
                .font(.system(size: 52, weight: .bold, design: .serif))
                .foregroundStyle(TUZColor.cini)
                .kerning(6)

            Text("Ailenin yolculuğu ve zeka odası")
                .font(TUZFont.callout)
                .foregroundStyle(TUZColor.inkSoft)

            activeMemberChip
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var activeMemberChip: some View {
        Button {
            router.push(.profiller)
        } label: {
            HStack(spacing: 10) {
                if let member = activeMember {
                    MemberBadge(
                        initial: String(member.name.prefix(1)),
                        color: Color(hex: member.colorHex),
                        size: 34
                    )
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Aktif oyuncu")
                            .font(.caption2)
                            .foregroundStyle(TUZColor.inkSoft)
                        Text(member.name)
                            .font(TUZFont.headline)
                            .foregroundStyle(TUZColor.ink)
                    }
                } else {
                    Text("Profil seç")
                        .font(TUZFont.headline)
                        .foregroundStyle(TUZColor.ink)
                }
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(TUZColor.inkSoft)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(TUZColor.cream)
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(TUZColor.stone, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Hub kartları

    private var hubGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            HubCard(
                title: "TÜZ Yolculuğu",
                subtitle: "İmkânsız mimari bulmaca",
                systemImage: "mountain.2.fill",
                tint: TUZColor.cini
            ) { router.push(.yolculuk) }

            HubCard(
                title: "Zeka Odası",
                subtitle: "Mini oyunlar",
                systemImage: "brain.head.profile",
                tint: TUZColor.turquoise
            ) { router.push(.zekaOdasi) }

            HubCard(
                title: "Profiller",
                subtitle: "Aile üyeleri ve güçler",
                systemImage: "person.3.fill",
                tint: TUZColor.brass
            ) { router.push(.profiller) }

            HubCard(
                title: "Aile Havuzu",
                subtitle: "Ortak skor ve liderlik",
                systemImage: "trophy.fill",
                tint: Color(hex: "#B5742E")
            ) { router.push(.aileHavuzu) }
        }
    }
}

/// Hub'daki büyük, dokunmatik kart.
private struct HubCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 30))
                    .foregroundStyle(tint)
                    .frame(height: 36)

                Spacer(minLength: 0)

                Text(title)
                    .font(TUZFont.headline)
                    .foregroundStyle(TUZColor.ink)
                    .multilineTextAlignment(.leading)

                Text(subtitle)
                    .font(TUZFont.caption)
                    .foregroundStyle(TUZColor.inkSoft)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
            .tuzCard()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        AileMeclisiView()
    }
    .environment(AppRouter())
    .modelContainer(PersistenceController.preview.container)
}
