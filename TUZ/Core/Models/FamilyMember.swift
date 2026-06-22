import Foundation
import SwiftData

/// Bir TÜZ aile üyesinin profili (GDD §3, §6).
///
/// CloudKit'e geçişe hazır olması için tüm alanların varsayılan değeri vardır
/// ve benzersizlik kısıtı kullanılmaz (CloudKit gereksinimi).
@Model
final class FamilyMember {
    /// Kararlı, koda gömülü kimlik (örn. "bilal"). `id` adı, `PersistentModel`
    /// ile çakışmasın diye `memberID` olarak tutulur.
    var memberID: String = ""
    var name: String = ""
    var nickname: String = ""
    /// Aile içindeki rol etiketi (örn. "Baba", "1. Çocuk", "1. Gelin").
    var roleTitle: String = ""
    /// Hikâyeye katılım sırası (GDD §5.3).
    var order: Int = 0

    var mainPowerName: String = ""
    var mainPowerDetail: String = ""
    var sidePowerName: String = ""
    var sidePowerDetail: String = ""

    /// Tercih edilen zorluk bandı (GDD §5.5).
    var difficultyMin: Int = 3
    var difficultyMax: Int = 6

    /// Placeholder figür/rozet için kimlik rengi (#RRGGBB).
    var colorHex: String = "#1C6E8C"

    init(
        memberID: String,
        name: String,
        nickname: String,
        roleTitle: String,
        order: Int,
        mainPowerName: String,
        mainPowerDetail: String,
        sidePowerName: String,
        sidePowerDetail: String,
        difficultyMin: Int,
        difficultyMax: Int,
        colorHex: String
    ) {
        self.memberID = memberID
        self.name = name
        self.nickname = nickname
        self.roleTitle = roleTitle
        self.order = order
        self.mainPowerName = mainPowerName
        self.mainPowerDetail = mainPowerDetail
        self.sidePowerName = sidePowerName
        self.sidePowerDetail = sidePowerDetail
        self.difficultyMin = difficultyMin
        self.difficultyMax = difficultyMax
        self.colorHex = colorHex
    }
}

extension FamilyMember {
    var difficultyText: String { "\(difficultyMin)–\(difficultyMax)" }

    var mainPower: Power { Power(name: mainPowerName, detail: mainPowerDetail, kind: .main) }
    var sidePower: Power { Power(name: sidePowerName, detail: sidePowerDetail, kind: .side) }
}
