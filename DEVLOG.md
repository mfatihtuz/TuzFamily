# TÜZ — Geliştirme Günlüğü (Bilgi Bankası)

> Tarihli, **detaylı** geliştirme kaydıdır. Roller:
> `CLAUDE.md` = kurallar + güncel durum + kilitli kararlar · `ROADMAP.md` = plan/fazlar ·
> **bu dosya = NE yapıldı, NEDEN, hangi dosyalar (tarih tarih).**
>
> **Nasıl güncellenir:** Her anlamlı değişiklikten (commit) sonra, **en üstteki** o günün
> tarihi altına bir madde ekle. Gün yoksa en üste yeni bir `## YYYY-MM-DD` başlığı aç.
> Madde formatı: **Başlık (commit)** → Ne · Neden/Karar · Dosyalar · Not.

---

## 2026-06-23

### Proje hafızası kuruldu (55a7d7b)
- **Ne:** Kapsamlı `CLAUDE.md` (otomatik okunan hafıza) baştan yazıldı; `ROADMAP.md` güncel
  duruma çekildi; eksik **paylaşılan Xcode scheme** eklendi (`xcshareddata/xcschemes/TUZ.xcscheme`).
- **Neden:** Çok sayıda prompt sonrası dağılmamak; sıfır oturumun kaldığı yerden devam etmesi;
  klondan/`xcodebuild -scheme TUZ` ile derleme.
- **Dosyalar:** `CLAUDE.md`, `ROADMAP.md`, `TUZ.xcodeproj/xcshareddata/xcschemes/TUZ.xcscheme`.
- **Not:** Bu DEVLOG da bu yapının parçası (geçmiş kaydı).

### Onboarding + kimlik/karakter ayrımı (b766901)
- **Ne:** İlk açılış akışı (tanıtım + "bu ailede sen kimsin?") → `playerMemberID`. Yeni `SettingsView`
  (kimlik değiştir + tanıtımı tekrar gör). Hub'da "aktif oyuncu seç" kalktı → "Merhaba, <ad>" → Ayarlar.
  Profiller bilgi amaçlı + "Ben" rozeti. Yolculuk figürü artık `LevelData.characterID`'den (senaryo).
- **Neden (KARAR):** Kullanıcı düzeltmesi — **Oyuncu Kimliği (skor hanesi) ≠ Hikâye Karakteri**.
  Kimlik onboarding'de seçilir/Ayarlar'dan değişir; hikâye karakterini senaryo yerleştirir.
- **Dosyalar:** `Features/Onboarding/OnboardingView.swift`, `SettingsView.swift`, `App/RootView.swift`,
  `App/AppRouter.swift` (+`ayarlar`), `AileMeclisi/AileMeclisiView.swift`, `Profiller/ProfillerView.swift`,
  `Yolculuk/Levels/LevelData.swift`+`LevelLibrary.swift`, `Yolculuk/Scene/LevelView.swift`.
- **Not:** `activeMemberID` tamamen kaldırıldı → `playerMemberID`. Bölüm karakterleri: Avlu=Bilal,
  Çay Bahçesi=Hatice, Çarşı=Huzeyfe, Işıklı Eyvan=Nur.

### Kelimelik: 4000 kelime + 12 seviye akışı (dc16cfe)
- **Ne:** TDK tabanlı (CanNuhlar/Turkce-Kelime-Listesi) listeden temizlenip dengelenen **4000 kelime**
  (3–8 harf, **667'şer**). 12 seviyelik akış: (harf,ipucu) = (3,1)(4,1)(4,1)(5,2)(5,1)(5,1)(6,2)(6,1)(7,2)(7,1)(8,3)(8,2).
  Deneme: 3-4→4, 5-6→5, 7-8→6. **Her oyunda rastgele kelime + rastgele ipucu konumu.** Skor = yeşil×3 + kalan×2 + 10.
- **Neden (KARAR):** Kullanıcı isteği — tekrar olmasın, kademeli zorluk, ipuçları rastgele, net puanlama.
- **Dosyalar:** `Resources/WordBank.json`, `Core/Models/WordBank.swift`,
  `ZekaOdasi/Kelimelik/KelimelikLevel.swift`+`KelimelikViewModel.swift`+`KelimelikView.swift`.
- **Not:** Havuz a–z baş-harf dağılımı doğal Türkçeyle örtüşüyor (K %10.4, A %8.2, T %7.2…). Engelleme
  listesiyle aile-dostu süzüldü.

### Düzeltme: KelimelikViewModel init 'self' erken kullanımı (c9f24ba)
- **Ne/Neden:** `self.level = …(levelIndex)` tüm property'ler init edilmeden `self`'e dokunuyordu →
  derleme hatası. Yerel `startIndex` sabitiyle giderildi. **Dosya:** `KelimelikViewModel.swift`.

---

## 2026-06-22

### Kelimelik yeniden tasarım: kademeli seviyeler (97fd048)
- **Ne:** İlk kademeli sürüm — değişken ızgara, ipucu satırı, "Kelime yok" doğrulaması kaldırıldı,
  kazanınca "Sonraki Seviye". **Neden:** "oynaması zor / yönlendirme yok" geri bildirimi.
- **Not:** Sonradan 4000 kelime + kesin 12-seviye akışı (dc16cfe) ile genişletildi.

### Yolculuk: gerçek MV tekniği — flat gölgeleme (fffad84)
- **Ne:** Tüm malzemeler `.constant` lighting (ışıktan etkilenmez); küp yüzlerine yönüne göre düz ton;
  gerçekçi gölge kaldırıldı. **Neden:** PBR+gölge "çamurlu/plastik" görünüyordu; MV grafiksel görünümün
  doğru tekniği bu. **Dosyalar:** `Yolculuk/Scene/SceneArt.swift`, `LevelSceneController.swift`, `CharacterRig.swift`.
- **Not:** Son görsel "his" cihazda ekran-görüntüsü döngüsüyle ayarlanmalı (Linux'ta render görülemez).

### Yolculuk görsel elden geçirme (acf39fb)
- **Ne:** "Uçuşan bloklar" yerine içi dolu taş sütun + zemin + okunaklı üst yüzey + cüppeli figür.
  **Neden:** "anlamsız/hatalı görünüyor" geri bildirimi. **Dosyalar:** aynı Scene dosyaları.

### Yol haritası (45f70b5)
- **Ne:** `ROADMAP.md` — tüm fazlar, durumlar, sıradaki işler.

### Düzeltme: PersistenceController @MainActor (39e20b2)
- **Ne/Neden:** `ModelContainer.mainContext` @MainActor'a bağlı; nonisolated init'ten erişilince hata.
  Önizleme tohumlaması ayrı `ModelContext(container)` ile yapıldı. **Dosya:** `Core/Persistence/PersistenceController.swift`.

### Faz 2 tamamlandı: döndürme + perspektif hizalama (6829aa2)
- **Ne:** `LevelRotator`/`LevelSeam`; rotator grupları; **ekran-uzayı hizalama** (kamera-uzayı projeksiyon,
  `simd`); döndürme sonrası yol grafiği yeniden kurulur. "Işıklı Eyvan" bölümü. Yatay/dikey birim eşitlendi
  (kübik grid) — hizalama doğru çalışsın diye. **Dosyalar:** `Levels/LevelData.swift`+`LevelLibrary.swift`,
  `Scene/LevelSceneController.swift`, `Scene/LevelView.swift`.

### Faz 2 temeli: SceneKit Yolculuk dikey dilimi (00ffdfa)
- **Ne:** `LevelData`/`LevelLibrary` (yol grafiği), `PathGraph` (BFS), `CharacterRig` (placeholder figür,
  `Character_<Ad>` sözleşmesi), `LevelSceneController` (sahne/kamera/ışık/bloklar), `LevelSceneView`
  (UIViewRepresentable + tap), `LevelView` (HUD), `YolculukView` (bölüm seçimi). Ortografik izometrik
  kamera, tap-to-move, Yol Gösteren gücü, 3 prototip bölüm. Placeholder ekran kaldırıldı.

### Faz 0 + Faz 1: TÜZ iskeleti ve Kelimelik (c860ff2)
- **Ne:** SwiftUI App + `AppRouter` + `NavigationStack`; feature/Core mimarisi; tasarım sistemi
  (`TUZColor`/`TUZFont`/`TUZTheme`); SwiftData (`FamilyMember`, `ScoreEntry`, `PersistenceController`,
  `FamilyData` seed — 6 üye, güçler xlsx'ten); Kelimelik ilk sürüm; Aile Havuzu; Profiller; Yolculuk
  placeholder. Xcode 16 synchronized-groups `project.pbxproj` elle; `project.yml` (XcodeGen) yedeği;
  `.gitignore`, `README.md`, ilk `CLAUDE.md`. 152 doğrulanmış 5-harfli kelime.
- **Not:** Depo boş başladığı için `main` sonradan ilk commit'e açıldı; PR #1 açıldı.
