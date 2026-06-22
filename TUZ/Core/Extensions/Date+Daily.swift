import Foundation

/// Günlük oyun döngüsü için tarih yardımcıları.
///
/// Günün kelimesi/içeriği, sabit bir başlangıç tarihinden bu yana geçen gün
/// sayısına göre seçilir; böylece aynı gün tüm cihazlarda aynı içerik gelir.
enum DailyClock {
    /// Sabit başlangıç (referans) tarihi: 1 Ocak 2024.
    static var reference: Date {
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 1
        return Calendar.current.date(from: components)
            ?? Date(timeIntervalSince1970: 1_704_067_200)
    }

    /// Referans tarihinden bu yana geçen tam gün sayısı (>= 0).
    static func dayIndex(for date: Date = .now, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: reference)
        let today = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: start, to: today).day ?? 0
        return max(0, days)
    }

    /// "yyyy-MM-dd" biçiminde gün anahtarı (kayıt anahtarları için).
    static func dateKey(for date: Date = .now, calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
