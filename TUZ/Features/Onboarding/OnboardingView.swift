import SwiftUI
import SwiftData

/// İlk açılış akışı (1-2 dk): oyun tanıtımı + aile tanıtımı + **kimlik seçimi**.
///
/// Sonunda kullanıcı "bu ailede gerçekte kim olduğunu" seçer; bu kimlik
/// skorların yazılacağı hanedir (oyun karakteri DEĞİL). `onFinish` ile döner.
struct OnboardingView: View {
    var onFinish: (String) -> Void

    @Query(sort: \FamilyMember.order) private var members: [FamilyMember]
    @State private var page = 0
    @State private var selectedID: String?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $page) {
                welcomePage.tag(0)
                infoPage(
                    icon: "brain.head.profile",
                    title: "Zeka Odası",
                    text: "Kelimelik gibi mini oyunlar. Herkes kendi vaktinde oynar; puanlar ortak aile havuzunda toplanır."
                ).tag(1)
                infoPage(
                    icon: "mountain.2.fill",
                    title: "TÜZ Yolculuğu",
                    text: "Ailenin hikâyesi, imkânsız mimarilerde adım adım ilerler. Her bölümde hikâyenin o anki kahramanı sahnededir."
                ).tag(2)
                familyPage.tag(3)
                identityPage.tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            if page < 4 {
                Button("Atla") {
                    withAnimation { page = 4 }
                }
                .font(TUZFont.callout)
                .foregroundStyle(TUZColor.inkSoft)
                .padding()
            }
        }
        .tuzScreenBackground()
    }

    // MARK: - Sayfalar

    private var welcomePage: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("TÜZ")
                .font(.system(size: 64, weight: .bold, design: .serif))
                .foregroundStyle(TUZColor.cini)
                .kerning(6)
            Text("Ailenin yolculuğu ve zeka odası")
                .font(TUZFont.headline)
                .foregroundStyle(TUZColor.ink)
            Text("Bu, TÜZ ailesine özel bir oyundur. Başlamadan önce seni biraz tanıyalım.")
                .font(TUZFont.body)
                .foregroundStyle(TUZColor.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Text("Kaydır →")
                .font(TUZFont.caption)
                .foregroundStyle(TUZColor.inkSoft)
                .padding(.top, 8)
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func infoPage(icon: String, title: String, text: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 72))
                .foregroundStyle(TUZColor.cini)
            Text(title)
                .font(TUZFont.title)
                .foregroundStyle(TUZColor.ink)
            Text(text)
                .font(TUZFont.body)
                .foregroundStyle(TUZColor.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var familyPage: some View {
        VStack(spacing: 10) {
            Text("Aile")
                .font(TUZFont.title)
                .foregroundStyle(TUZColor.ink)
                .padding(.top, 44)
            Text("Hikâyenin kahramanları ve güçleri")
                .font(TUZFont.caption)
                .foregroundStyle(TUZColor.inkSoft)
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(members) { member in
                        HStack(spacing: 12) {
                            MemberBadge(
                                initial: String(member.name.prefix(1)),
                                color: Color(hex: member.colorHex),
                                size: 40
                            )
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(member.name) · \(member.nickname)")
                                    .font(TUZFont.callout)
                                    .foregroundStyle(TUZColor.ink)
                                Text("Güç: \(member.mainPowerName)")
                                    .font(.caption2)
                                    .foregroundStyle(TUZColor.inkSoft)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .tuzCard(padding: 10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 44)
            }
        }
    }

    private var identityPage: some View {
        VStack(spacing: 14) {
            Text("Bu ailede sen kimsin?")
                .font(TUZFont.title)
                .foregroundStyle(TUZColor.ink)
                .multilineTextAlignment(.center)
                .padding(.top, 44)
            Text("Puanların bu kişiye yazılır. Sonra Ayarlar'dan değiştirebilirsin.")
                .font(TUZFont.caption)
                .foregroundStyle(TUZColor.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(members) { member in
                        memberPick(member)
                    }
                }
                .padding(.horizontal)
            }

            Button {
                if let id = selectedID { onFinish(id) }
            } label: {
                Text("Başla")
                    .font(TUZFont.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(selectedID == nil ? TUZColor.stone : TUZColor.turquoise, in: Capsule())
            }
            .buttonStyle(.plain)
            .disabled(selectedID == nil)
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }

    private func memberPick(_ member: FamilyMember) -> some View {
        let selected = selectedID == member.memberID
        return Button {
            selectedID = member.memberID
        } label: {
            VStack(spacing: 8) {
                MemberBadge(
                    initial: String(member.name.prefix(1)),
                    color: Color(hex: member.colorHex),
                    size: 52
                )
                Text(member.name)
                    .font(TUZFont.headline)
                    .foregroundStyle(TUZColor.ink)
                Text(member.nickname)
                    .font(.caption2)
                    .foregroundStyle(TUZColor.inkSoft)
            }
            .frame(maxWidth: .infinity)
            .tuzCard(padding: 14)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(selected ? TUZColor.turquoise : .clear, lineWidth: 3)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingView { _ in }
        .modelContainer(PersistenceController.preview.container)
}
