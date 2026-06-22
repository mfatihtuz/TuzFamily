import Foundation
import SwiftData

/// Skor yazma/okuma için soyutlama. MVP'de yerel SwiftData uygulaması
/// (`ScoreService`) kullanılır; ileride aynı arayüzü uygulayan CloudKit
/// tabanlı bir tür ile değiştirilebilir (GDD §9).
protocol ScoreStoring {
    func record(memberID: String, game: GameKind, points: Int, detail: String)
    func hasPlayed(memberID: String, game: GameKind, on date: Date) -> Bool
}

/// SwiftData üzerinden çalışan yerel skor servisi.
struct ScoreService: ScoreStoring {
    let context: ModelContext

    /// Bir skoru kaydeder. Bu kayıt hem kişisel toplama hem de aile havuzuna
    /// (her ikisi de `ScoreEntry`'lerden hesaplanır) katkı verir.
    func record(memberID: String, game: GameKind, points: Int, detail: String = "") {
        let entry = ScoreEntry(
            memberID: memberID,
            game: game.rawValue,
            points: points,
            detail: detail
        )
        context.insert(entry)
        try? context.save()
    }

    /// Bu üyenin verilen oyunu belirtilen günde oynayıp oynamadığını döner
    /// (günlük döngü kontrolü için).
    func hasPlayed(memberID: String, game: GameKind, on date: Date = .now) -> Bool {
        let gameRaw = game.rawValue
        let descriptor = FetchDescriptor<ScoreEntry>(
            predicate: #Predicate<ScoreEntry> { $0.memberID == memberID && $0.game == gameRaw }
        )
        let entries = (try? context.fetch(descriptor)) ?? []
        return entries.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
}
