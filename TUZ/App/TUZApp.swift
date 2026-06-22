import SwiftUI
import SwiftData

/// Uygulamanın giriş noktası.
///
/// Kalıcılık SwiftData ile yereldir; `PersistenceController` ileride
/// CloudKit'e geçiş için tek noktadan yapılandırılabilir (bkz. GDD §9, §10).
@main
struct TUZApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(PersistenceController.shared.container)
    }
}
