import Foundation
import SwiftData

/// Tek bir oyun oturumundan kazanılan skor kaydı.
///
/// Kişisel toplam ve aile havuzu toplamı bu kayıtlardan hesaplanır
/// (tek doğruluk kaynağı). CloudKit uyumu için tüm alanlar varsayılan değerlidir.
@Model
final class ScoreEntry {
    var entryID: UUID = UUID()
    /// Skoru kazanan üyenin `FamilyMember.memberID` değeri.
    var memberID: String = ""
    /// Oyun türü ham değeri (`GameKind.rawValue`).
    var game: String = ""
    var points: Int = 0
    var date: Date = Date.now
    /// Serbest açıklama (örn. Kelimelik için "KALEM|3" = kelime|deneme).
    var detail: String = ""

    init(
        memberID: String,
        game: String,
        points: Int,
        date: Date = .now,
        detail: String = ""
    ) {
        self.entryID = UUID()
        self.memberID = memberID
        self.game = game
        self.points = points
        self.date = date
        self.detail = detail
    }
}
