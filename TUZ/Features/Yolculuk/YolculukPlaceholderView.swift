import SwiftUI

/// TÜZ Yolculuğu için geçici (placeholder) ekran.
///
/// Gerçek SceneKit dikey dilimi Faz 2'de gelecek: kamera (uzak/eğik izometrik),
/// tap-to-move, 1 döndürme + 1 perspektif hizalama mekaniği, placeholder figür
/// ve "Yol Gösteren" gücü (GDD §5, §12 · Tasarım Dokümanı Faz 2).
struct YolculukPlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "mountain.2.fill")
                .font(.system(size: 72))
                .foregroundStyle(TUZColor.cini)

            Text("TÜZ Yolculuğu")
                .font(TUZFont.title)
                .foregroundStyle(TUZColor.ink)

            Text("İmkânsız mimari bulmacaları yakında burada.\nFaz 2'de SceneKit ile gelecek.")
                .font(TUZFont.body)
                .foregroundStyle(TUZColor.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            roadmapCard

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .tuzScreenBackground()
        .navigationTitle("Yolculuk")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var roadmapCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Uzak, eğik izometrik kamera", systemImage: "camera.viewfinder")
            Label("Tap-to-move (yol grafiği)", systemImage: "hand.tap.fill")
            Label("Döndürme + perspektif hizalama", systemImage: "rotate.3d")
            Label("İlk güç: Yol Gösteren", systemImage: "figure.walk")
        }
        .font(TUZFont.callout)
        .foregroundStyle(TUZColor.inkSoft)
        .frame(maxWidth: .infinity, alignment: .leading)
        .tuzCard()
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

#Preview {
    NavigationStack {
        YolculukPlaceholderView()
    }
}
