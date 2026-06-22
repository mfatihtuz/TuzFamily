import Foundation

/// Kelimelik kelime bankası — kelimeler uzunluğa göre gruplanır (3/4/5/6 harf).
/// `Resources/WordBank.json` dosyasından yüklenir; dosya yoksa gömülü yedek kullanılır.
/// Tüm kelimeler Türkçe büyük harfe (tr_TR) çevrilir.
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
        if loaded.isEmpty {
            loaded = WordBank.fallback
        }
        byLength = loaded
    }

    /// Verilen uzunluktaki kelimeler (azalan güvenle yedeğe düşer).
    func words(length: Int) -> [String] {
        if let words = byLength[length], !words.isEmpty { return words }
        return WordBank.fallback[length] ?? ["KALEM"]
    }

    /// Deterministik seçim: aynı (uzunluk, indeks) her zaman aynı kelimeyi verir.
    func answer(length: Int, index: Int) -> String {
        let pool = words(length: length)
        guard !pool.isEmpty else { return "KALEM" }
        let i = ((index % pool.count) + pool.count) % pool.count
        return pool[i]
    }

    private static let fallback: [Int: [String]] = [
        3: ["KOL", "GÜL", "TUZ", "YOL", "BAL", "KAR"],
        4: ["MASA", "ELMA", "KEDİ", "KAPI", "OYUN", "PARA"],
        5: ["KALEM", "KİTAP", "ÇİÇEK", "DENİZ", "SEVGİ", "HUZUR"],
        6: ["KARPUZ", "DEFTER", "BALKON", "MUTFAK", "PEYNİR", "ZEYTİN"]
    ]
}
