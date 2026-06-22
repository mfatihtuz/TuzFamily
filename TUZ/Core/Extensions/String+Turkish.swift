import Foundation

extension String {
    /// Türkçe (tr_TR) yerele göre büyük harf — i→İ, ı→I doğru çalışır.
    func turkishUppercased() -> String {
        uppercased(with: Locale(identifier: "tr_TR"))
    }

    /// Türkçe (tr_TR) yerele göre küçük harf — I→ı, İ→i doğru çalışır.
    func turkishLowercased() -> String {
        lowercased(with: Locale(identifier: "tr_TR"))
    }

    /// Dizgeyi harf harf (grapheme cluster) diziye böler. Türkçe ç, ğ, ş, ı,
    /// İ, ö, ü harfleri tek karakter olarak ele alınır.
    var letters: [String] {
        map { String($0) }
    }
}
