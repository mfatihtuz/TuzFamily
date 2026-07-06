import SwiftUI

/// TÜZ Yolculuğu — bölüm seçimi (GDD §5). Faz 2 dikey dilimi: SceneKit sahnesi,
/// izometrik kamera, tap-to-move ve "Yol Gösteren" gücü ile oynanabilir prototip
/// bölümler. Döndürme + perspektif hizalama mekaniği sonraki adımda gelecek.
struct YolculukView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                intro

                ForEach(LevelLibrary.all) { level in
                    levelCard(level)
                }
            }
            .padding()
        }
        .tuzScreenBackground()
        .navigationTitle("Yolculuk")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var intro: some View {
        VStack(spacing: 8) {
            Image(systemName: "mountain.2.fill")
                .font(.system(size: 40))
                .foregroundStyle(TUZColor.cini)
            Text("Bir bölüm seç")
                .font(TUZFont.headline)
                .foregroundStyle(TUZColor.ink)
            Text("Karaktere değil, gitmesini istediğin karoya dokun. Takılırsan Yol Gösteren'i kullan.")
                .font(TUZFont.caption)
                .foregroundStyle(TUZColor.inkSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 4)
    }

    private func levelCard(_ level: LevelData) -> some View {
        Button {
            router.push(.yolculukLevel(level.id))
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(TUZColor.cini.gradient)
                        .frame(width: 52, height: 52)
                    Image(systemName: "cube.transparent.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(level.title)
                        .font(TUZFont.headline)
                        .foregroundStyle(TUZColor.ink)
                    Text(level.subtitle)
                        .font(TUZFont.caption)
                        .foregroundStyle(TUZColor.inkSoft)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(TUZColor.inkSoft)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .tuzCard()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        YolculukView()
    }
    .environment(AppRouter())
}
