import Foundation

/// Bir harfin tahmindeki durumu (renk geri bildirimi).
enum LetterFeedback {
    case correct  // doğru harf, doğru yer (yeşil)
    case present  // kelimede var ama yanlış yer (sarı/amber)
    case absent   // kelimede yok (gri)
    case empty    // henüz girilmemiş kutu
}

/// Izgarada tek bir kutu.
struct LetterTile {
    var letter: String
    var feedback: LetterFeedback
}

/// Oyunun genel durumu.
enum KelimelikState: Equatable {
    case playing
    case won(attempts: Int)
    case lost(answer: String)

    var isFinished: Bool {
        self != .playing
    }
}

/// Cihazda saklanan günlük ilerleme (uygulama kapanıp açılsa da korunur).
struct KelimelikProgress: Codable {
    var guesses: [String]
    var finished: Bool
}
