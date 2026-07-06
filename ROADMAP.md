# TÜZ — Geliştirme Planı (Yol Haritası)

Fazlar, durumları ve sıradaki işler. Kararlar ve çalışma kuralları için `CLAUDE.md`.
Durum: ✅ tamam · 🔄 sürüyor (cihazda ince ayar) · ⬜ yapılacak

---

## Faz 0 — İskelet ✅
- ✅ SwiftUI App, `AppRouter` + `NavigationStack`, feature/Core klasör yapısı
- ✅ Tasarım sistemi (palet, tipografi, tema), SwiftData profil seed
- ✅ Paylaşılan Xcode scheme (klondan/CLI derleme)

## Faz 1 — Zeka Odası 🔄
- ✅ **Onboarding + kimlik:** tanıtım + "sen kimsin?" → `playerMemberID`; Ayarlar'dan değişir
- ✅ **Kelimelik (TAM):** 12 seviye, 4000 kelimelik havuz (3–8 harf, 667'şer), rastgele
  kelime + rastgele ipucu, doğrulamasız giriş, puan = yeşil×3 + kalan×2 + 10
- ✅ Aile Havuzu: aile toplamı + haftalık hedef + liderlik (6 üye, 0'lı)
- ⬜ Ayarlar'a "Kelimelik ilerlemesini sıfırla"
- ⬜ **Matematik** mini oyunu (tam çalışır) — *sıradaki güvenilir 2D*
- ⬜ **Trivia** (aile temalı soru bankası) · ⬜ **Pasaparola** (A–Z çark)

## Faz 2 — Yolculuk dikey dilimi (SceneKit) 🔄
- ✅ Ortografik izometrik kamera, flat (MV) gölgeleme, içi dolu sütun + zemin
- ✅ Veri-güdümlü ortam (PathGraph), tap-to-move (BFS), placeholder figür
- ✅ "Yol Gösteren" gücü; **döndürme + perspektif hizalama** (imkânsız geometri)
- ✅ Figür **senaryonun karakteri** (`LevelData.characterID`), oyuncu kimliği değil
- 🔄 **Görsel cila** — kamera/ölçek/palet/figür (Mac, ekran-görüntüsü döngüsü gerekir)
- ⬜ Yolculuk ilerlemesinin Aile Havuzu'na işlenmesi

## Faz 3 — Sistem genişleme ⬜
- ⬜ Hikâye iskeleti: chapter akışı, bölümlerin sırayla açılması (GDD §5.3, §7)
- ⬜ **Birlik Bölümleri** (çok-karakter güç zinciri) + kalan güç mekanikleri
- ⬜ Zorluk profilleri (anne-baba 3–6 / gençler 5–8 — yardım ölçekleme)
- ⬜ CloudKit ile aile havuzu senkronu (yerel arayüz hazır)

## Faz 4 — Cila & Meshy ⬜
- ⬜ Meshy USDZ figür drop-in (aynı node/clip sözleşmesi)
- ⬜ Animasyon (cross-fade) + huzurlu ses/ambient
- ⬜ Görsel sanat: çini desenleri, kemer/mukarnas (premium look)
- ⬜ Bölüm çoğaltma + TestFlight ile aile içi dağıtım

---

## Bilinen sınırlama
Bulut/Linux oturumunda **SceneKit derlenip görülemez.** 2D ekranlar yüksek doğrulukla
yazılır; 3D'nin görsel cilası **Mac'te** ekran-görüntüsü döngüsüyle ilerler. Bu yüzden
geliştirme Mac'teki claude ile yürütülür (bkz. `CLAUDE.md` → Build/Run/Screenshot).
