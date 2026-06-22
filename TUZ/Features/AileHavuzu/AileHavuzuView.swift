import SwiftUI
import SwiftData

/// Aile Havuzu — ortak skor, haftalık ortak hedef (co-op) ve liderlik (rekabet).
/// (GDD §9). Skorlar `ScoreEntry` kayıtlarından hesaplanır; MVP'de yereldir,
/// arayüz CloudKit'e geçişe hazırdır.
struct AileHavuzuView: View {
    @Query(sort: \FamilyMember.order) private var members: [FamilyMember]
    @Query private var scores: [ScoreEntry]

    /// Haftalık ortak hedef (puan).
    private let weeklyGoal = 750

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                familyTotalCard
                weeklyGoalCard
                leaderboard
            }
            .padding()
        }
        .tuzScreenBackground()
        .navigationTitle("Aile Havuzu")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Kartlar

    private var familyTotalCard: some View {
        VStack(spacing: 6) {
            Text("Aile Toplamı")
                .font(TUZFont.callout)
                .foregroundStyle(TUZColor.inkSoft)
            Text("\(familyTotal)")
                .font(.system(size: 54, weight: .bold, design: .serif))
                .foregroundStyle(TUZColor.cini)
            Text("puan")
                .font(TUZFont.caption)
                .foregroundStyle(TUZColor.inkSoft)
        }
        .frame(maxWidth: .infinity)
        .tuzCard()
    }

    private var weeklyGoalCard: some View {
        let weekly = weeklyTotal
        let progress = min(1.0, Double(weekly) / Double(weeklyGoal))
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Haftalık Ortak Hedef", systemImage: "target")
                    .font(TUZFont.headline)
                    .foregroundStyle(TUZColor.ink)
                Spacer()
                Text("\(weekly)/\(weeklyGoal)")
                    .font(TUZFont.callout)
                    .foregroundStyle(TUZColor.inkSoft)
            }
            ProgressView(value: progress)
                .tint(TUZColor.turquoise)
            Text(weekly >= weeklyGoal
                 ? "Hedefe ulaştınız, ne güzel! 🎉"
                 : "Birlikte oynayarak hedefi tamamlayın.")
                .font(TUZFont.caption)
                .foregroundStyle(TUZColor.inkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .tuzCard()
    }

    private var leaderboard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Liderlik")
                .font(TUZFont.headline)
                .foregroundStyle(TUZColor.ink)

            if familyTotal == 0 {
                Text("Henüz skor yok. Zeka Odası'ndan Kelimelik oynayın!")
                    .font(TUZFont.callout)
                    .foregroundStyle(TUZColor.inkSoft)
                    .padding(.vertical, 8)
            } else {
                ForEach(Array(rankedMembers.enumerated()), id: \.element.memberID) { index, member in
                    leaderboardRow(rank: index + 1, member: member, points: total(for: member.memberID))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .tuzCard()
    }

    private func leaderboardRow(rank: Int, member: FamilyMember, points: Int) -> some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(TUZFont.headline)
                .foregroundStyle(TUZColor.brass)
                .frame(width: 24)
            MemberBadge(
                initial: String(member.name.prefix(1)),
                color: Color(hex: member.colorHex),
                size: 36
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
            Text("\(points)")
                .font(TUZFont.headline)
                .foregroundStyle(TUZColor.cini)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Hesaplamalar

    private var familyTotal: Int {
        scores.reduce(0) { $0 + $1.points }
    }

    private var weeklyTotal: Int {
        let calendar = Calendar.current
        return scores
            .filter { calendar.isDate($0.date, equalTo: .now, toGranularity: .weekOfYear) }
            .reduce(0) { $0 + $1.points }
    }

    private func total(for memberID: String) -> Int {
        scores.filter { $0.memberID == memberID }.reduce(0) { $0 + $1.points }
    }

    private var rankedMembers: [FamilyMember] {
        members.sorted { total(for: $0.memberID) > total(for: $1.memberID) }
    }
}

#Preview {
    NavigationStack {
        AileHavuzuView()
    }
    .modelContainer(PersistenceController.preview.container)
}
