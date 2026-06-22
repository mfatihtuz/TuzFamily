import SwiftUI
import SwiftData
import UIKit

/// Bir bölümün tam ekranı: SceneKit sahnesi + üstüne SwiftUI HUD.
/// Aktif aile üyesinin rengi/adı figüre uygulanır.
struct LevelView: View {
    let levelID: String

    @Environment(\.dismiss) private var dismiss
    @AppStorage("activeMemberID") private var activeMemberID = "bilal"
    @Query(sort: \FamilyMember.order) private var members: [FamilyMember]

    @State private var controller: LevelSceneController?

    private var level: LevelData? { LevelLibrary.level(id: levelID) }

    var body: some View {
        ZStack {
            if let controller {
                LevelSceneView(controller: controller)
                    .ignoresSafeArea()
                hud(controller)
            } else {
                TUZColor.cream.ignoresSafeArea()
                ProgressView()
            }
        }
        .navigationTitle(level?.title ?? "Bölüm")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: setupIfNeeded)
    }

    private func setupIfNeeded() {
        guard controller == nil, let level else { return }
        let member = members.first { $0.memberID == activeMemberID } ?? members.first
        let color = UIColor(Color(hex: member?.colorHex ?? "#1C6E8C"))
        let name = member?.name ?? "Bilal"
        controller = LevelSceneController(level: level, characterName: name, characterColor: color)
    }

    // MARK: - HUD

    @ViewBuilder
    private func hud(_ controller: LevelSceneController) -> some View {
        VStack {
            HStack {
                Label("\(controller.movesCount) hamle", systemImage: "shoeprints.fill")
                    .font(TUZFont.caption)
                    .foregroundStyle(TUZColor.ink)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(.ultraThinMaterial, in: Capsule())
                Spacer()
                if let subtitle = level?.subtitle {
                    Text(subtitle)
                        .font(TUZFont.caption)
                        .foregroundStyle(TUZColor.inkSoft)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(.ultraThinMaterial, in: Capsule())
                }
            }
            .padding(.horizontal)

            Spacer()

            if controller.reachedGoal {
                goalBanner
            } else {
                powerButton(controller)
            }
        }
        .padding(.bottom, 28)
        .padding(.top, 8)
    }

    private func powerButton(_ controller: LevelSceneController) -> some View {
        Button {
            controller.togglePower()
        } label: {
            Label("Yol Gösteren", systemImage: controller.powerActive ? "sparkles" : "wand.and.stars")
                .font(TUZFont.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 13)
                .background(controller.powerActive ? TUZColor.brass : TUZColor.turquoise, in: Capsule())
                .shadow(color: TUZColor.ink.opacity(0.2), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var goalBanner: some View {
        VStack(spacing: 12) {
            Text("Bölüm tamamlandı 🎉")
                .font(TUZFont.title)
                .foregroundStyle(TUZColor.cini)
            Text("Reis Baba doğru yolu gösterdi; aile bir adım daha ilerledi.")
                .font(TUZFont.callout)
                .foregroundStyle(TUZColor.ink)
                .multilineTextAlignment(.center)
            Button {
                dismiss()
            } label: {
                Text("Bölümlere dön")
                    .font(TUZFont.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(TUZColor.turquoise, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(TUZColor.cream.opacity(0.96), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(TUZColor.stone, lineWidth: 1)
        )
        .padding(.horizontal)
    }
}
