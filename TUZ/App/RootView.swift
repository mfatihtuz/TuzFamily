import SwiftUI
import SwiftData

/// Kök görünüm: ilk açılışta profilleri tohumlar, oyuncu kimliği seçilmemişse
/// **Onboarding** gösterir, seçilmişse ana navigasyonu kurar.
struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var router = AppRouter()

    /// Oyuncunun bu ailedeki kimliği (skorların yazılacağı hane).
    /// Boşsa onboarding gösterilir. Ayarlar'dan değiştirilebilir.
    @AppStorage("playerMemberID") private var playerMemberID = ""

    var body: some View {
        @Bindable var router = router
        return Group {
            if playerMemberID.isEmpty {
                OnboardingView { chosenID in
                    playerMemberID = chosenID
                }
            } else {
                NavigationStack(path: $router.path) {
                    AileMeclisiView()
                        .navigationDestination(for: Route.self) { route in
                            destination(for: route)
                        }
                }
                .environment(router)
            }
        }
        .tint(TUZColor.turquoise)
        .onAppear {
            FamilyData.seedIfNeeded(in: modelContext)
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .zekaOdasi:
            ZekaOdasiView()
        case .kelimelik:
            KelimelikView(memberID: playerMemberID)
        case .yolculuk:
            YolculukView()
        case .yolculukLevel(let id):
            LevelView(levelID: id)
        case .profiller:
            ProfillerView()
        case .aileHavuzu:
            AileHavuzuView()
        case .ayarlar:
            SettingsView()
        }
    }
}

#Preview {
    RootView()
        .modelContainer(PersistenceController.preview.container)
}
