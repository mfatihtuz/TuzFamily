import Foundation
import SwiftData

/// TÜZ ailesinin koda gömülü, kanonik kadro verisi.
///
/// Kaynak: GDD §5/§6 ve `TUZ_Karakter_Guc_Sistemi.xlsx`. İlk açılışta
/// SwiftData'ya tohumlanır; sonraki açılışlarda tekrar eklenmez (idempotent).
enum FamilyData {

    struct Seed {
        let memberID: String
        let name: String
        let nickname: String
        let roleTitle: String
        let order: Int
        let mainPowerName: String
        let mainPowerDetail: String
        let sidePowerName: String
        let sidePowerDetail: String
        let difficultyMin: Int
        let difficultyMax: Int
        let colorHex: String

        func makeModel() -> FamilyMember {
            FamilyMember(
                memberID: memberID,
                name: name,
                nickname: nickname,
                roleTitle: roleTitle,
                order: order,
                mainPowerName: mainPowerName,
                mainPowerDetail: mainPowerDetail,
                sidePowerName: sidePowerName,
                sidePowerDetail: sidePowerDetail,
                difficultyMin: difficultyMin,
                difficultyMax: difficultyMax,
                colorHex: colorHex
            )
        }
    }

    /// Profilleri yalnızca veritabanı boşsa ekler.
    static func seedIfNeeded(in context: ModelContext) {
        let count = (try? context.fetchCount(FetchDescriptor<FamilyMember>())) ?? 0
        guard count == 0 else { return }
        for seed in all {
            context.insert(seed.makeModel())
        }
        try? context.save()
    }

    static let all: [Seed] = [
        Seed(
            memberID: "bilal",
            name: "Bilal",
            nickname: "Reis Baba",
            roleTitle: "Baba",
            order: 1,
            mainPowerName: "Yol Gösteren",
            mainPowerDetail: """
            Reis Baba'nın imza gücü: ailenin izleyeceği doğru yolu işaretlemesidir. \
            Etkinleştiğinde gidilecek doğru yön ve sıradaki güvenli adımlar bir süre \
            belirginleşir, çıkmaz ve tuzak yollar ise soluklaşır; böylece aile karmaşık \
            bir yapının neresinden geçeceğini şaşırmadan görür. Ne ortalığı aydınlatır ne \
            de yeni bir yol açar — sadece var olan yollardan hangisinin doğru olduğunu \
            gösterir. Bir ailenin reisi olarak doğru yolu gösteren odur; bu yüzden güç \
            yalnızca ona özeldir ve kimseyle paylaşılmaz.
            """,
            sidePowerName: "Reisin Çağrısı",
            sidePowerDetail: """
            Reis Baba sesini yükselttiğinde çağrısı yapının uzağına ulaşır; oradaki bir \
            mekanizmayı (kapı, kol, asansör) tetikler ya da geride kalan bir aile bireyini \
            yanına çağırır. Yan güç olduğu için etkisi tek seferlik ve sınırlı menzillidir, \
            ama doğru anda kullanıldığında elle erişilemeyen bir düğmeyi uzaktan çalıştırır. \
            İsmi, gür sesiyle bilinen Bilal-i Habeşi'ye küçük bir selamdır.
            """,
            difficultyMin: 3,
            difficultyMax: 6,
            colorHex: "#1C6E8C"
        ),
        Seed(
            memberID: "hatice",
            name: "Hatice",
            nickname: "Şefkatli Anne",
            roleTitle: "Anne",
            order: 2,
            mainPowerName: "Sevgi Kanadı",
            mainPowerDetail: """
            Şefkatli Anne'nin imza gücü: bir aile bireyini kanadının altına alıp \
            güçlendirmesidir. Etkin olduğunda seçtiği kişinin kendi gücü daha geniş menzille \
            ya da daha kuvvetli çalışır — Mucit'in kurduğu yol uzar, Atılgan Patron'un \
            çevirdiği mekanizmalar hızlanır gibi. Aynı anda etrafındaki aileyi düşen platform, \
            kayan zemin gibi bir tehlikeden koruyan bir kalkan kurar. Tek başına yol açmaz; \
            gücü ailesini büyütmek ve korumak üzerinedir, bu yüzden Birlik Bölümleri'nin \
            kalbinde o yer alır ve güç sadece ona aittir.
            """,
            sidePowerName: "Şefkat Işığı",
            sidePowerDetail: """
            Annenin şefkati sertliği yumuşatır: yolu kapatan bir engeli nazikçe kenara iter \
            ya da hareketli/saldırgan bir tehlikeyi bir süre durultup zararsız kılar. Yan güç \
            olduğundan etkisi kısa sürelidir ve tek bir engele dokunur, ama dar bir geçidi \
            açmak için çoğu zaman yeterlidir.
            """,
            difficultyMin: 3,
            difficultyMax: 6,
            colorHex: "#C8788F"
        ),
        Seed(
            memberID: "huzeyfe",
            name: "Huzeyfe",
            nickname: "Atılgan Patron",
            roleTitle: "1. Çocuk",
            order: 3,
            mainPowerName: "Çifte İdare",
            mainPowerDetail: """
            Atılgan Patron'un imza gücü: aynı anda iki mekanizmayı birden yönetmesidir. İki \
            ayrı kolu, kapıyı ya da platformu tek seferde çalıştırıp birlikte tutar; diğer \
            karakterler bir anda yalnızca birini idare edebilirken o ikisini birden çevirir. \
            Bu sayede 'iki düğmeye aynı anda basılması' ya da iki yapının eşzamanlı \
            hizalanması gereken bölümler tek başına çözülür. İki işletmeyi birlikte yürüten \
            atılgan bir esnafa yakışan bu çift-idare yeteneği yalnızca ona vardır.
            """,
            sidePowerName: "Sır Kâtibi",
            sidePowerDetail: """
            Gözden saklı olanı görür: gizli bir mekanizmayı, kapağı kapalı bir düğmeyi ya da \
            görünmeyen bir geçidi açığa çıkarır. Yan güç olduğu için bir seferde tek bir sırrı \
            ortaya döker, ama tıkandığın bölümlerde aradığın 'eksik parça' çoğu zaman onun \
            bulduğu şeydir. İsmi, sırların emanet edildiği sahabe Huzeyfe'ye bir selamdır.
            """,
            difficultyMin: 5,
            difficultyMax: 8,
            colorHex: "#2E7D5B"
        ),
        Seed(
            memberID: "fatih",
            name: "Fatih",
            nickname: "Mucit",
            roleTitle: "2. Çocuk",
            order: 4,
            mainPowerName: "Karadan Gemi",
            mainPowerDetail: """
            Mucit'in imza gücü iki işi birden görür: ölü/çalışmayan bir mekanizmayı yeniden \
            devreye alır ve hiç yol olmayan yere mühendislik marifetiyle yeni bir geçit kurar. \
            Enerjisi kesilmiş, durmuş bir düzeneği canlandırıp çalıştırır; sonra 'olmaz' denen \
            iki nokta arasına beklenmedik bir köprü ya da ray inşa eder. En çıkışsız görünen, \
            'buradan geçilmez' dedirten bölümler onun uzmanlık alanıdır. İsmi hem \
            mühendisliğine hem de gemileri karadan yürüten Fatih'e bir göndermedir; bu \
            yaratıcı çözüm gücü kimseyle paylaşılmaz.
            """,
            sidePowerName: "Kıvılcım",
            sidePowerDetail: """
            Bir kıvılcımla yakınındaki bir mekanizmayı anında tetikler ya da hareketli bir \
            engeli kısa süre durdurur. Yan güç olduğundan menzili kısadır ve tek hedefe etki \
            eder, ama doğru anda çakılan kıvılcım bir kapıyı tam zamanında açar. Elektrik \
            mühendisliğine küçük bir selamdır.
            """,
            difficultyMin: 5,
            difficultyMax: 8,
            colorHex: "#B5742E"
        ),
        Seed(
            memberID: "sedef",
            name: "Sedef",
            nickname: "Yardımsever Abla",
            roleTitle: "1. Gelin",
            order: 5,
            mainPowerName: "Uzanan El",
            mainPowerDetail: """
            Yardımsever Abla'nın imza gücü: geride kalan ya da bir boşlukta sıkışan aile \
            bireyine elini uzatıp onu güvene çekmesidir. Aradaki uçurumu köprüyle değil, \
            uzattığı elle kapatır — düşmüş, takılmış veya ayrı kalmış birini kendi bulunduğu \
            güvenli zemine taşır, kimseyi geride bırakmaz. Özellikle bir karakterin tek başına \
            geçemediği, birinin yardımına muhtaç olduğu bölümlerde işi çözen odur. \
            Yardımseverliğin, misafirperverliğin, merhametin ve sabrın tam karşılığı olan bu \
            güç yalnızca ona aittir.
            """,
            sidePowerName: "Sedef Işıltısı",
            sidePowerDetail: """
            Bir yüzeyi sedef gibi parlatır; üzerindeki gizli işaretleri, desenleri ya da \
            basılması gereken saklı noktaları belirgin kılar. Yan güç olduğundan etkisi tek bir \
            yüzeyle sınırlıdır, ama bir bulmacanın görünmeyen ipucunu çoğu zaman onun ışıltısı \
            ortaya çıkarır. İsmindeki sedefin parıltısına bir selamdır.
            """,
            difficultyMin: 5,
            difficultyMax: 8,
            colorHex: "#8E7CC3"
        ),
        Seed(
            memberID: "nur",
            name: "Nur",
            nickname: "Minnoş",
            roleTitle: "2. Gelin",
            order: 6,
            mainPowerName: "Gönül Işığı",
            mainPowerDetail: """
            Nur'un imza gücü: karanlığı aydınlatıp gölgede saklı yolları gerçek kılmasıdır. \
            Işığı düştüğünde, zifirî karanlıkta yokmuş gibi duran basamaklar, köprüler ve \
            geçitler ortaya çıkıp basılabilir hale gelir. Aydınlatılmadığı sürece geçilemeyen \
            karanlık bölümler tamamen onun gücüne bağlıdır. İsmi 'ışık' anlamına gelen bu \
            üyenin gücü, evin ışığı olmasına bir selamdır ve kimseyle paylaşılmaz.
            """,
            sidePowerName: "Esinti",
            sidePowerDetail: """
            Bir esinti gibi hafif ve çevik: üzerine yapışan olumsuz bir etkiden (yavaşlatma, \
            donma gibi) ya da yolunu kesen bir engelden zarifçe sıyrılıp geçer. Yan güç \
            olduğundan tek seferlik ve kısa menzillidir, ama sıkışılan bir anda bir nefeste \
            kurtuluş verir.
            """,
            difficultyMin: 5,
            difficultyMax: 8,
            colorHex: "#D4A02C"
        ),
    ]
}
