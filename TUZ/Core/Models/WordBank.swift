import Foundation

/// Kelimelik kelime bankası — kelimeler uzunluğa göre gruplanır (3–8 harf,
/// her biri ~667 kelime, toplam ~4000). `Resources/WordBank.json`'dan yüklenir.
/// Her seferinde rastgele kelime seçilir (tekrar azalır).
final class WordBank {
    static let shared = WordBank()

    private var byLength: [Int: [String]] = [:]

    init() {
        var loaded: [Int: [String]] = [:]
        if let url = Bundle.main.url(forResource: "WordBank", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let raw = try? JSONDecoder().decode([String: [String]].self, from: data) {
            for (key, words) in raw {
                if let length = Int(key) {
                    loaded[length] = words.map { $0.turkishUppercased() }.filter { $0.count == length }
                }
            }
        }
        byLength = loaded.isEmpty ? WordBank.fallback : loaded
    }

    func words(length: Int) -> [String] {
        if let words = byLength[length], !words.isEmpty { return words }
        return WordBank.fallback[length] ?? ["KALEM"]
    }

    /// O uzunluktan rastgele bir kelime.
    func randomAnswer(length: Int) -> String {
        words(length: length).randomElement() ?? "KALEM"
    }

    private static let fallback: [Int: [String]] = [
        3: ["KOL", "GÜL", "TUZ", "YOL", "BAL", "KAR"],
        4: ["MASA", "ELMA", "KEDİ", "KAPI", "OYUN", "PARA"],
        5: ["KALEM", "KİTAP", "ÇİÇEK", "DENİZ", "SEVGİ", "HUZUR"],
        6: ["KARPUZ", "DEFTER", "BALKON", "MUTFAK", "PEYNİR", "ZEYTİN"],
        7: ["KELEBEK", "ÖĞRENCİ", "ARMAĞAN", "MANZARA", "PENCERE", "KESTANE"],
        8: ["ÖĞRETMEN", "AKTARMAK", "BAHÇECİK", "DOLAŞMAK", "GÜVERCİN", "KUTLAMAK"]
    ]
}
