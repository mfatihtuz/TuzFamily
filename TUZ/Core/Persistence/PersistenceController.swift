import Foundation
import SwiftData

/// SwiftData `ModelContainer`'ını tek noktadan kuran yardımcı.
///
/// MVP'de kalıcılık yereldir. İleride CloudKit'e geçmek için burada
/// `ModelConfiguration(..., cloudKitDatabase: .automatic)` kullanmak ve
/// projeye iCloud yetkisi eklemek yeterli olacak (GDD §9, §10).
final class PersistenceController {
    static let shared = PersistenceController()

    /// SwiftUI önizlemeleri ve testler için bellekte (kalıcı olmayan) kapsayıcı.
    static let preview = PersistenceController(inMemory: true)

    let container: ModelContainer

    init(inMemory: Bool = false) {
        let schema = Schema([FamilyMember.self, ScoreEntry.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("SwiftData ModelContainer oluşturulamadı: \(error)")
        }

        if inMemory {
            // Önizleme/test tohumlaması: `mainContext` @MainActor'a bağlı olduğu için
            // nonisolated init'ten erişilemez. Aynı container'ı paylaşan ayrı bir
            // ModelContext kullan (in-memory store ortak; @Query bunu görür).
            FamilyData.seedIfNeeded(in: ModelContext(container))
        }
    }
}
