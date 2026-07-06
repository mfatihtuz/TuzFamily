import Foundation
import Observation

/// Kelimelik oyun mantığı — kademeli seviyeler, ipuçları, kullanıcı dostu kurallar.
///
/// - Izgara seviyeyle büyür (3→6 harf). İpuçları ızgaranın ~%12'si kadar açık gelir.
/// - **Kelime listesi doğrulaması yok**: doğru uzunlukta her tahmin kabul edilir.
/// - Her yeni seviye ilk kez kazanılınca puan aile havuzuna yazılır (`onScore`).
/// - İlerleme cihazda saklanır (üye bazında mevcut seviye).
@Observable
final class KelimelikViewModel {
    private let memberID: String
    private let bank: WordBank

    private(set) var level: KelimelikLevel
    private(set) var answer: String = ""
    private(set) var hintPositions: Set<Int> = []
    private(set) var guesses: [String] = []
    private(set) var current: String = ""
    private(set) var state: KelimelikState = .playing
    private(set) var letterStates: [String: LetterFeedback] = [:]
    var message: String?

    /// Yeni bir seviye ilk kez kazanılınca puanı havuza yazmak için.
    var onScore: ((Int) -> Void)?

    private var levelIndex: Int

    var wordLength: Int { level.wordLength }
    var attempts: Int { level.attempts }
    var isLastLevel: Bool { levelIndex >= KelimelikProgression.count - 1 }
    var hasHints: Bool { !hintPositions.isEmpty }

    init(memberID: String, bank: WordBank = .shared) {
        self.memberID = memberID
        self.bank = bank
        let startIndex = UserDefaults.standard.integer(forKey: "kelimelik.level.\(memberID)")
        self.levelIndex = startIndex
        self.level = KelimelikProgression.level(at: startIndex)
        setupLevel()
    }

    // MARK: - Seviye kurulumu

    private func setupLevel() {
        level = KelimelikProgression.level(at: levelIndex)
        // Her seferinde rastgele kelime ve rastgele ipucu konumları.
        answer = bank.randomAnswer(length: level.wordLength)
        hintPositions = Set(Array(0..<level.wordLength).shuffled().prefix(level.hintCount))
        guesses = []
        current = ""
        state = .playing
        letterStates = [:]
        message = nil
    }

    /// İpucu satırı: açık konumlarda harf, diğerlerinde boş.
    var hintRow: [LetterTile] {
        let letters = answer.letters
        return (0..<wordLength).map { i in
            if hintPositions.contains(i), i < letters.count {
                return LetterTile(letter: letters[i], feedback: .hint)
            }
            return LetterTile(letter: "", feedback: .empty)
        }
    }

    // MARK: - Girdi

    func tap(_ letter: String) {
        guard state == .playing, current.letters.count < wordLength else { return }
        current += letter.turkishUppercased()
        message = nil
    }

    func deleteLast() {
        guard state == .playing, !current.isEmpty else { return }
        current.removeLast()
        message = nil
    }

    func submit() {
        guard state == .playing else { return }
        let guess = current.turkishUppercased()
        guard guess.letters.count == wordLength else {
            message = "\(wordLength) harf gir"
            return
        }
        // Kullanıcı dostu: kelime listesi doğrulaması YOK; uzunluk yeterli.
        let feedback = evaluate(guess: guess)
        guesses.append(guess)
        updateLetterStates(guess: guess, feedback: feedback)
        current = ""
        message = nil

        if feedback.allSatisfy({ $0 == .correct }) {
            state = .won(attempts: guesses.count)
            awardIfFirstWin()
        } else if guesses.count >= attempts {
            state = .lost(answer: answer)
        }
    }

    // MARK: - İlerleme

    func nextLevel() {
        guard case .won = state else { return }
        levelIndex = min(levelIndex + 1, KelimelikProgression.count - 1)
        UserDefaults.standard.set(levelIndex, forKey: "kelimelik.level.\(memberID)")
        setupLevel()
    }

    func retry() {
        setupLevel()
    }

    var earnedPoints: Int {
        guard case .won = state else { return 0 }
        return points()
    }

    private func awardIfFirstWin() {
        let key = "kelimelik.awarded.\(memberID)"
        let awardedCount = UserDefaults.standard.integer(forKey: key)
        guard levelIndex >= awardedCount else { return }
        UserDefaults.standard.set(levelIndex + 1, forKey: key)
        onScore?(points())
    }

    /// Puan = (yeşil harf × 3) + (kalan deneme × 2) + (kelime bulunduysa 10).
    /// Kazanınca tüm harfler yeşildir → yeşil harf sayısı = kelime uzunluğu.
    private func points() -> Int {
        let greens = wordLength
        let left = max(0, attempts - guesses.count)
        return greens * 3 + left * 2 + 10
    }

    // MARK: - Izgara

    var grid: [[LetterTile]] {
        var rows: [[LetterTile]] = []
        for guess in guesses {
            let letters = guess.letters
            let fb = evaluate(guess: guess)
            rows.append(zip(letters, fb).map { LetterTile(letter: $0, feedback: $1) })
        }
        if state == .playing && rows.count < attempts {
            let typed = current.letters
            rows.append((0..<wordLength).map { i in
                LetterTile(letter: i < typed.count ? typed[i] : "", feedback: .empty)
            })
        }
        while rows.count < attempts {
            rows.append(Array(repeating: LetterTile(letter: "", feedback: .empty), count: wordLength))
        }
        return rows
    }

    // MARK: - Değerlendirme

    func evaluate(guess: String) -> [LetterFeedback] {
        let g = guess.letters
        let a = answer.letters
        var result = Array(repeating: LetterFeedback.absent, count: g.count)
        var remaining: [String: Int] = [:]
        for ch in a { remaining[ch, default: 0] += 1 }
        for i in g.indices where i < a.count && g[i] == a[i] {
            result[i] = .correct
            if let c = remaining[g[i]] { remaining[g[i]] = c - 1 }
        }
        for i in g.indices where result[i] != .correct {
            let ch = g[i]
            if let c = remaining[ch], c > 0 {
                result[i] = .present
                remaining[ch] = c - 1
            }
        }
        return result
    }

    private func updateLetterStates(guess: String, feedback: [LetterFeedback]) {
        for (letter, newState) in zip(guess.letters, feedback) {
            if shouldOverride(existing: letterStates[letter], with: newState) {
                letterStates[letter] = newState
            }
        }
    }

    private func shouldOverride(existing: LetterFeedback?, with new: LetterFeedback) -> Bool {
        guard let existing else { return true }
        func rank(_ f: LetterFeedback) -> Int {
            switch f {
            case .correct: return 3
            case .present: return 2
            case .absent: return 1
            default: return 0
            }
        }
        return rank(new) > rank(existing)
    }
}
