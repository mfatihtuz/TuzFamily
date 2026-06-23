# TÜZ — Proje Hafızası (CLAUDE.md)

> **Bu dosya projenin kalıcı hafızasıdır. Her oturum başında bunu, `ROADMAP.md` ve
> `DEVLOG.md`'yi oku.** Kaldığımız yerden devam et; **Kilitli Kararlar**ı yeniden tartışma.
> Büyük kapsam ya da yeni bir yön gerekiyorsa önce sor. Tasarımın tamamı
> `TUZ_Tasarim_Dokumani.md`'de, güç tablosu `TUZ_Karakter_Guc_Sistemi.xlsx`'te.

## Oturum başlangıç checklist
1. `CLAUDE.md` + `ROADMAP.md` oku.
2. (Mac'te) Derle, simülatörde çalıştır, ekran görüntüsü al → "Build/Run/Screenshot" bölümü.
3. "Güncel Durum"u doğrula, "Sıradaki Adımlar"dan devam et.
4. Küçük, **derlenebilir** adımlar; her adımda commit. Belirsizlikte varsayımı yaz, gerekirse sor.
5. Her anlamlı değişiklikten (commit) sonra **`DEVLOG.md`'ye tarihli bir madde** ekle (ne · neden · dosyalar).

## Dokümanlar (rol dağılımı)
- **CLAUDE.md** (bu dosya): kurallar + güncel durum + kilitli kararlar (otomatik okunur).
- **ROADMAP.md**: fazlar, durumlar, sıradaki işler (ileriye dönük plan).
- **DEVLOG.md**: tarihli detaylı geliştirme kaydı / bilgi bankası (geriye dönük; sürekli güncellenir).
- **TUZ_Tasarim_Dokumani.md** / **TUZ_Karakter_Guc_Sistemi.xlsx**: tam tasarım ve güç tablosu.

---

## 1. Proje
TÜZ ailesine özel iOS oyunu. İki katman:
- **TÜZ Yolculuğu** — Monument Valley tarzı imkânsız-mimari 3D bulmaca (SceneKit). Ailenin hikâyesini anlatır.
- **Zeka Odası** — senkronsuz mini oyunlar (Kelimelik tam çalışır; Trivia/Pasaparola/Matematik sırada). Puanlar ortak aile havuzunda toplanır.

Görsel dil: **premium, ağırbaşlı, Osmanlı/İslam geometrik estetiği** — çocuksu/low-poly DEĞİL. 57–63 yaş anne-baba rahat oynar; gençler için derinleşir.

## 2. Stack
iOS 17+, **Swift 5**, **SwiftUI** (UI), **SceneKit** (3D), **SwiftData** (yerel kalıcılık),
**Observation** (`@Observable`). İleride **CloudKit**. **Türkçe UI** (taban dil `tr`,
`Localizable.xcstrings`), **İngilizce kod** tanımları.

## 3. ⚠️ KRİTİK zihin modeli — Kimlik ≠ Karakter (asla karıştırma)
- **Oyuncu Kimliği = skor hanesi.** Onboarding'de "Bu ailede sen kimsin?" ile seçilir →
  `@AppStorage("playerMemberID")`. **Ayarlar'dan değiştirilebilir** (ortak telefon).
  Zeka Odası skorları **bu kimliğe** yazılır.
- **Hikâye Karakteri = senaryo yerleştirir.** Oyuncu Yolculuk'ta **karakter SEÇMEZ**.
  Her bölümün karakteri `LevelData.characterID`'den gelir (katılım sırası, GDD §5.3).
  Birlik Bölümleri'nde oyuncu sahnedeki karakterler **arasında geçiş** yapar ama kadroyu seçmez.
- Bu ikisini **birbirine bağlama** (eski hata buydu, düzeltildi).

## 4. Mimari
Feature-bazlı + paylaşılan `Core`. Navigasyon: `AppRouter` (`@Observable`, `[Route]` path) +
`NavigationStack`. Kök `RootView`: kimlik boşsa `OnboardingView`, doluysa `AileMeclisiView` (hub).

```
TUZ/
├── App/           TUZApp(@main) · RootView · AppRouter
├── Features/
│   ├── Onboarding/   OnboardingView · SettingsView
│   ├── AileMeclisi/  hub
│   ├── ZekaOdasi/    ZekaOdasiView + Kelimelik/*
│   ├── Yolculuk/     Levels/* · Mechanics/* · Scene/* · YolculukView
│   ├── Profiller/    bilgi amaçlı kadro
│   └── AileHavuzu/   ortak skor + liderlik
├── Core/
│   ├── Models/       FamilyMember, ScoreEntry, Power, GameKind, WordBank, FamilyData
│   ├── Persistence/  PersistenceController (SwiftData), ScoreService
│   ├── DesignSystem/ TUZColor, TUZFont, TUZTheme
│   └── Extensions/   Color+Hex, UIColor+Hex, String+Turkish, Date+Daily
├── Resources/WordBank.json
├── Assets.xcassets · Localizable.xcstrings
```

## 5. Kurallar (Anti-hallucination)
- API/framework **uydurma**; emin değilsen resmi dokümana dayan ya da sor. Gerçek imzalar.
- Var olmayan sembol/dosya/asset referansı verme.
- Her adımda **derlenir** kal; küçük commit'ler; büyük tek dosya yok.
- Belirsizlikte varsayımı **açıkça yaz**, onay iste; sessizce ilerleme.
- Türkçe büyük/küçük harf **her zaman** `tr_TR` locale (`String+Turkish`): i↔İ, ı↔I.
- SwiftData `@Model`: CloudKit'e hazır olsun — tüm alanlar varsayılan değerli, benzersizlik kısıtı yok.

## 6. Build / Run / Screenshot (Mac — zorunlu görsel döngü)
`TUZ.xcodeproj` Xcode 16 **file system synchronized groups** kullanır: `TUZ/` altına eklenen
dosyalar otomatik derlemeye girer (pbxproj'a el ekleme YOK). Yedek: `project.yml` (XcodeGen).
Paylaşılan **scheme** depoda var (`xcshareddata/xcschemes/TUZ.xcscheme`).

```bash
# Derle
xcodebuild -project TUZ.xcodeproj -scheme TUZ \
  -destination 'platform=iOS Simulator,name=iPhone 15' build

# Çalıştır + ekran görüntüsü
xcrun simctl boot "iPhone 15" 2>/dev/null
xcrun simctl install booted <DerivedData>/.../TUZ.app
xcrun simctl launch booted com.tuzailesi.TUZ
xcrun simctl io booted screenshot out.png
```
**RENDER KISITI:** Bulut/Linux oturumunda SceneKit derlenip **GÖRÜLEMEZ**. 3D görsel ayarı
(kamera/ölçek/palet/figür) **Mac'te** bu ekran-görüntüsü döngüsüyle yapılmalı. Bu yüzden
geliştirme **Mac'teki claude** ile yürütülür.

## 7. Git
- Geliştirme dalı: **`claude/laughing-heisenberg-w3i1vp`**. `main` = ilk iskelet temeli.
- `git push -u origin claude/laughing-heisenberg-w3i1vp`. **PR #1 zaten açık** — kullanıcı istemeden yeni PR açma.
- Aynı dalda **iki ajan birden** çalışmasın (çakışma). Tek yerden commit/push.

## 8. Kilitli Kararlar (yeniden tartışma)
- **Kimlik:** onboarding'de seçilir, Ayarlar'dan değiştirilebilir. Skor hanesi budur.
- **Hikâye:** karakteri **senaryo** yerleştirir; oyuncu kadro seçmez (yukarı §3).
- **Aile Havuzu (CloudKit öncesi):** 6 üye de görünür; oynamayanlar 0 puan.
- **Kelimelik akışı (12 seviye):** (harf, ipucu) = (3,1)(4,1)(4,1)(5,2)(5,1)(5,1)(6,2)(6,1)(7,2)(7,1)(8,3)(8,2).
  Deneme: 3-4→4, 5-6→5, 7-8→6. **Her oyunda rastgele kelime + rastgele ipucu konumu.**
  **Kelime listesi doğrulaması YOK** (uzunluk yeterli). Puan = yeşil×3 + kalan deneme×2 + (bulundu? 10).
- **Kelime havuzu:** ~4000 gerçek Türkçe kelime, 3–8 harf, **667'şer**, TDK kaynaklı
  ([CanNuhlar/Turkce-Kelime-Listesi](https://github.com/CanNuhlar/Turkce-Kelime-Listesi)), aile-dostu süzülmüş.
- **Türkçe UI / İngilizce kod.** Xcode 16 synchronized groups.
- **Geliştirme Mac'te lokal** yürütülür (render görebilmek için).

## 9. Güncel Durum (✅ yapıldı)
- **Faz 0** iskelet: navigasyon, hub, tasarım sistemi, profiller (SwiftData seed).
- **Onboarding + kimlik:** tanıtım sayfaları + kimlik seçimi → `playerMemberID`; Ayarlar'dan değişir; Profiller bilgi amaçlı + "Ben" rozeti.
- **Kelimelik (TAM):** 12 seviye, 4000 kelimelik havuz (3–8 harf), rastgele kelime + rastgele ipucu, doğrulamasız giriş, yeni puanlama; ilerleme `kelimelik.level.<id>`, ödül guard `kelimelik.awarded.<id>`.
- **Aile Havuzu:** aile toplamı + haftalık hedef + liderlik (6 üye, 0'lı).
- **Yolculuk (3D temel):** SceneKit, **flat (constant) MV gölgeleme**, ortografik izometrik kamera, içi dolu taş sütun + zemin, tap-to-move (PathGraph + BFS), **Yol Gösteren** gücü, **döndürme + perspektif hizalama** (imkânsız geometri), 4 prototip bölüm; figür **senaryonun karakteri** (`characterID`).

## 10. Sıradaki Adımlar (öncelik sırası)
1. **Kelimelik testi:** temiz kurulumda Seviye 1'den (3 harf) başladığını ekran görüntüsüyle doğrula. Ayarlar'a **"Kelimelik ilerlemesini sıfırla"** ekle (`kelimelik.level.<id>` + `kelimelik.awarded.<id>` temizle).
2. **3D görsel cila** (Mac, ekran-görüntüsü döngüsü): kamera açısı/ölçek, palet, figür, okunaklılık — gerçek MV hissi.
3. **Matematik** mini oyunu (Kelimelik kalitesinde, güvenilir 2D kazanım).
4. **Hikâye iskeleti:** chapter akışı, bölümlerin sırayla açılması, çok-karakterli **Birlik Bölümleri** (güç zinciri), kalan güç mekanikleri.
5. **Trivia / Pasaparola.** Zorluk profilleri (anne-baba 3–6 / gençler 5–8).
6. **CloudKit** havuz senkronu (Faz 3). **Meshy USDZ** figür drop-in + ses/cila (Faz 4).

## 11. Figür Sözleşmesi (Meshy drop-in)
Kök node `Character_<Ad>`; klipler `Idle`/`Walk`/`Power_<GüçAdı>`; asset `/Characters/<Ad>/<Ad>.usdz`.
Şu an placeholder: `CharacterRig` (koni cüppe + küre baş, flat gölgeli). Gerçek USDZ aynı
node/clip adlarıyla **kod değişmeden** yerine konur.

## 12. Aile kadrosu (kimlik = id)
bilal (Reis Baba · Yol Gösteren) · hatice (Şefkatli Anne · Sevgi Kanadı) ·
huzeyfe (Atılgan Patron · Çifte İdare) · fatih (Mucit · Karadan Gemi) ·
sedef (Yardımsever Abla · Uzanan El) · nur (Minnoş · Gönül Işığı).
Kanonik veri: `Core/Models/FamilyData.swift`. Ana güç eşsiz; yan güç ortak havuz.
