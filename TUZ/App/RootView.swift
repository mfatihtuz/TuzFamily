import SwiftUI
import SwiftData

/// Navigasyon yığınını kuran, ilk açılışta aile profillerini tohumlayan kök görünüm.
struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var router = AppRouter()

    /// O an aktif olan (skorların yazılacağı) aile üyesinin kimliği.
    @AppStorage("activeMemberID") private var activeMemberID = "bilal"

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            AileMeclisiView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .zekaOdasi:
                        ZekaOdasiView()
                    case .kelimelik:
                        KelimelikView(memberID: activeMemberID)
                    case .yolculuk:
                        YolculukPlaceholderView()
                    case .profiller:
                        ProfillerView()
                    case .aileHavuzu:
                        AileHavuzuView()
                    }
                }
        }
        .environment(router)
        .tint(TUZColor.turquoise)
        .onAppear {
            FamilyData.seedIfNeeded(in: modelContext)
        }
    }
}

#Preview {
    RootView()
        .modelContainer(PersistenceController.preview.container)
}
