import Foundation
import Observation

/// Kelimelik (Türkçe 5 harf Wordle) oyun mantığı.
///
/// - Günün kelimesi tarihe göre deterministik seçilir (tüm aile aynı kelimeyi oynar).
/// - 6 deneme hakkı, harf harf renk geri bildirimi (yeşil/sarı/gri).
/// - Oyun bittiğinde `onComplete` ile skoru dışarıya bildirir (View bunu havuza yazar).
/// - Günlük ilerleme cihazda saklanır; uygulama yeniden açıldığında tahta geri yüklenir.
@Observable
final class KelimelikViewModel {
    let wordLength = 5
    let maxAttempts = 6

    private(set) var answer: String
    private(set) var guesses: [String] = []
    private(set) var current: String = ""
    private(set) var state: KelimelikState = .playing
    private(set) var letterStates: [String: LetterFeedback] = [:]

    /// Kullanıcıya gösterilecek geçici uyarı (örn. "Kelime listede yok").
    var message: String?

    /// Oyun ilk kez bittiğinde çağrılır: (kazanılan puan, açıklama).
    var onComplete: ((Int, String) -> Void)?

    private let bank: WordBank
    private let memberID: String
    private let dayIndex: Int
    private let dayKey: String
    private var didRecord = false

    init(memberID: String, date: Date = .now, bank: WordBank = .shared) {
        self.memberID = memberID
        self.bank = bank
        self.dayIndex = DailyClock.dayIndex(for: date)
        self.dayKey = DailyClock.dateKey(for: date)
        self.answer = bank.dailyAnswer(index: dayIndex)
        loadProgress()
    }

    // MARK: - Girdi

    func tap(_ letter: String) {
        guard state == .playing else { return }
        guard current.letters.count < wordLength else { return }
        current += letter.turkishUppercased()
        message = nil
    }

    func deleteLast() {
        guard state == .playing else { return }
        guard !current.isEmpty else { return }
        current.removeLast()
        message = nil
    }

    func submit() {
        guard state == .playing else { return }

        let guess = current.turkishUppercased()
        guard guess.letters.count == wordLength else {
            message = "5 harfli bir kelime girin"
            return
        }
        guard bank.isValid(guess) else {
            message = "Kelime listede yok"
            return
        }

        let feedback = evaluate(guess: guess)
        guesses.append(guess)
        updateLetterStates(guess: guess, feedback: feedback)
        current = ""
        message = nil

        if feedback.allSatisfy({ $0 == .correct }) {
            let attempts = guesses.count
            state = .won(attempts: attempts)
            finish(points: points(forAttempts: attempts), detail: "\(answer)|\(attempts)")
        } else if guesses.count >= maxAttempts {
            state = .lost(answer: answer)
            finish(points: 0, detail: "\(answer)|0")
        }

        saveProgress()
    }

    // MARK: - Izgara

    /// Görüntülenecek 6×5 kutu ızgarası (tamamlanan satırlar + aktif satır + boşlar).
    var grid: [[LetterTile]] {
        var rows: [[LetterTile]] = []

        for guess in guesses {
            let letters = guess.letters
            let feedback = evaluate(guess: guess)
            rows.append(zip(letters, feedback).map { LetterTile(letter: $0, feedback: $1) })
        }

        if state == .playing && rows.count < maxAttempts {
            let typed = current.letters
            var row: [LetterTile] = []
            for index in 0..<wordLength {
                let letter = index < typed.count ? typed[index] : ""
                row.append(LetterTile(letter: letter, feedback: .empty))
            }
            rows.append(row)
        }

        while rows.count < maxAttempts {
            rows.append(Array(repeating: LetterTile(letter: "", feedback: .empty), count: wordLength))
        }
        return rows
    }

    // MARK: - Değerlendirme

    /// Tahmini cevaba göre değerlendirir (tekrar eden harfleri doğru sayar).
    func evaluate(guess: String) -> [LetterFeedback] {
        let g = guess.letters
        let a = answer.letters
        var result = Array(repeating: LetterFeedback.absent, count: g.count)
        var remaining: [String: Int] = [:]
        for letter in a {
            remaining[letter, default: 0] += 1
        }

        // 1. geçiş: doğru yerdekiler
        for i in g.indices where i < a.count && g[i] == a[i] {
            result[i] = .correct
            if let count = remaining[g[i]] {
                remaining[g[i]] = count - 1
            }
        }
        // 2. geçiş: kelimede olup yanlış yerdekiler
        for i in g.indices where result[i] != .correct {
            let letter = g[i]
            if let count = remaining[letter], count > 0 {
                result[i] = .present
                remaining[letter] = count - 1
            }
        }
        return result
    }

    private func updateLetterStates(guess: String, feedback: [LetterFeedback]) {
        let letters = guess.letters
        for (letter, newState) in zip(letters, feedback) {
            let existing = letterStates[letter]
            if shouldOverride(existing: existing, with: newState) {
                letterStates[letter] = newState
            }
        }
    }

    /// Klavye renk önceliği: doğru > var > yok.
    private func shouldOverride(existing: LetterFeedback?, with new: LetterFeedback) -> Bool {
        guard let existing else { return true }
        func rank(_ f: LetterFeedback) -> Int {
            switch f {
            case .correct: return 3
            case .present: return 2
            case .absent: return 1
            case .empty: return 0
            }
        }
        return rank(new) > rank(existing)
    }

    // MARK: - Skor

    /// Daha az denemede bulan daha çok puan alır (1. denemede 60 → 6. denemede 10).
    private func points(forAttempts attempts: Int) -> Int {
        max(0, (maxAttempts - attempts + 1)) * 10
    }

    private func finish(points: Int, detail: String) {
        guard !didRecord else { return }
        didRecord = true
        onComplete?(points, detail)
    }

    // MARK: - İlerleme kalıcılığı (cihaz içi)

    private var progressKey: String { "kelimelik.\(memberID).\(dayKey)" }

    private func saveProgress() {
        let progress = KelimelikProgress(guesses: guesses, finished: state.isFinished)
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: progressKey)
        }
    }

    private func loadProgress() {
        guard
            let data = UserDefaults.standard.data(forKey: progressKey),
            let progress = try? JSONDecoder().decode(KelimelikProgress.self, from: data)
        else { return }

        for guess in progress.guesses {
            guesses.append(guess)
            updateLetterStates(guess: guess, feedback: evaluate(guess: guess))
        }

        if progress.finished {
            // Skor ilk bitişte zaten yazıldı; tekrar yazma.
            didRecord = true
            if let last = guesses.last, evaluate(guess: last).allSatisfy({ $0 == .correct }) {
                state = .won(attempts: guesses.count)
            } else {
                state = .lost(answer: answer)
            }
        }
    }
}
