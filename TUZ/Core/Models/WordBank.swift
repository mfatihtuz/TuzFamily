import Foundation

/// Kelimelik kelime bankası. `Resources/WordBank.json` dosyasından yüklenir;
/// dosya bulunamazsa küçük bir gömülü liste ile çalışmaya devam eder.
///
/// Tüm kelimeler Türkçe büyük harfe (tr_TR) çevrilerek tutulur; günün kelimesi
/// tarihe göre deterministik seçilir, böylece tüm aile aynı kelimeyi oynar.
final class WordBank {
    static let shared = WordBank()

    let words: [String]
    private let wordSet: Set<String>

    private struct WordBankFile: Decodable {
        let words: [String]
    }

    init() {
        var loaded: [String] = []
        if let url = Bundle.main.url(forResource: "WordBank", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let file = try? JSONDecoder().decode(WordBankFile.self, from: data) {
            loaded = file.words
        }
        if loaded.isEmpty {
            loaded = WordBank.fallback
        }
        // Yalnızca tam 5 harfli kelimeleri al, Türkçe büyük harfe çevir, tekille.
        let normalized = loaded
            .map { $0.turkishUppercased() }
            .filter { $0.count == 5 }
        self.words = Array(Set(normalized)).sorted()
        self.wordSet = Set(self.words)
    }

    /// Verilen gün indeksine karşılık gelen günün kelimesi.
    func dailyAnswer(index: Int) -> String {
        guard !words.isEmpty else { return "KALEM" }
        let i = ((index % words.count) + words.count) % words.count
        return words[i]
    }

    /// Tahminin geçerli (listede olan) bir kelime olup olmadığı.
    func isValid(_ guess: String) -> Bool {
        wordSet.contains(guess.turkishUppercased())
    }

    private static let fallback = [
        "KALEM", "KİTAP", "ARMUT", "DENİZ", "ÇİÇEK",
        "SABAH", "HUZUR", "SEVGİ", "GÜNEŞ", "BAHÇE"
    ]
}
