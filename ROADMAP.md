# TÜZ — Geliştirme Planı (Yol Haritası)

Bu dosya tüm fazları, durumlarını ve sıradaki işleri özetler. Tasarımın tamamı
`TUZ_Tasarim_Dokumani.md`'dedir; bu plan onun uygulama takvimidir.

Durum: ✅ tamam · 🔄 sürüyor (cihazda ince ayar gerek) · ⬜ yapılacak

---

## Faz 0 — İskelet ✅
- ✅ SwiftUI App, `AppRouter` + `NavigationStack`, §13 klasör yapısı
- ✅ Aile Meclisi (hub) → Yolculuk / Zeka Odası / Profiller / Aile Havuzu
- ✅ Tasarım sistemi (palet, tipografi, tema), `CLAUDE.md`

## Faz 1 — Zeka Odası 🔄
- ✅ **Kelimelik** (tam çalışır): Türkçe 5 harf, günlük kelime, renk geri bildirimi, klavye, skor
- ✅ Profiller (6 üye, güçler, aktif oyuncu), SwiftData yerel kayıt
- ✅ Aile Havuzu: aile toplamı + haftalık hedef + liderlik (temel)
- ⬜ **Matematik** mini oyunu (tam çalışır) — *2D, güvenilir, hızlı eklenebilir*
- ⬜ **Trivia** (soru bankası gerekir; aile temalı sorular)
- ⬜ **Pasaparola** (A–Z çark; en karmaşık mini oyun)
- ⬜ Günlük set + haftalık ortak hedef döngüsünün derinleştirilmesi

## Faz 2 — Yolculuk dikey dilimi (SceneKit) 🔄
- ✅ Ortografik izometrik kamera, veri-güdümlü modüler ortam (sütun + zemin)
- ✅ Tap-to-move (yol grafiği + BFS), placeholder figür (`Character_<Ad>` sözleşmesi)
- ✅ "Yol Gösteren" gücü (doğru yolu parlatma)
- ✅ Döndürme + perspektif hizalama (imkânsız geometri) — "Işıklı Eyvan" bölümü
- 🔄 **Görsel cila** — kamera açısı/ölçek, malzeme, figür, okunaklılık *(cihazda
  ekran görüntüsüyle iterasyon gerekiyor; bu ortamda derlenip görülemiyor)*
- ⬜ Yolculuk ilerlemesinin Aile Havuzu'na işlenmesi (GDD §9)

## Faz 3 — Sistem genişleme ⬜
- ⬜ Kalan güç mekanikleri (her karakterin ana + yan gücü oynanışta)
- ⬜ Birlik Bölümleri (karakterler arası güç zinciri — duygu zirveleri, GDD §6.3)
- ⬜ Karakter katılım yayı / chapter & hikâye akışı (avlu→çay bahçesi→… →konak)
- ⬜ Zorluk profilleri (anne-baba 3–6 / gençler 5–8 — yardım ölçekleme)
- ⬜ CloudKit ile aile havuzu senkronu (yerel arayüz hazır)

## Faz 4 — Cila & Meshy ⬜
- ⬜ Meshy USDZ figür drop-in (aynı node/clip sözleşmesi)
- ⬜ Animasyon (SCNAnimationPlayer cross-fade) + huzurlu ses/ambient
- ⬜ Görsel sanat: çini desenleri, kemer/mukarnas dekoratif parçalar (premium look)
- ⬜ Bölüm çoğaltma + TestFlight ile aile içi dağıtım

---

## Bilinen sınırlama (önemli)
Geliştirme ortamı Linux; **Xcode/SceneKit burada derlenip çalıştırılamıyor.** Bu yüzden:
- 2D SwiftUI ekranları (Kelimelik, hub, profiller, havuz) yüksek doğrulukla yazılabiliyor.
- 3D Yolculuk'un **görsel cilası** ekran görüntüsü/cihaz geri bildirimiyle tur tur
  ilerlemeli — kör geliştirmede "his" tutturmak zor.

## En verimli yol (öneri)
1. **Zeka Odası'nı tamamla** (Matematik + cila) → hemen, güvenilir biçimde ailece oynanır bir ürün.
2. **3D'yi ekran görüntüleriyle** birlikte hassas düzelt (kamera/ölçek/figür/renk).
3. Sonra Faz 3 (hikâye + Birlik Bölümleri + CloudKit).
