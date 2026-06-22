# TÜZ

TÜZ ailesinin 3D figürleriyle oynanan, iOS için zarif bir bulmaca yolculuğu (ana oyun)
ve ailece yarışılan bir zeka odası (yan oyun). Bu depo **Faz 0 + Faz 1** iskeletini içerir.

> Tam tasarım: `TUZ_Tasarim_Dokumani.md` · Güç sistemi: `TUZ_Karakter_Guc_Sistemi.xlsx`
> Proje kuralları: `CLAUDE.md`

## Bu sürümde ne var (Faz 0 + Faz 1)

- **Aile Meclisi (ana hub):** Yolculuk, Zeka Odası, Profiller, Aile Havuzu'na geçiş.
- **Profil sistemi:** 6 aile üyesi (lakap + ana/yan güç + zorluk profili), SwiftData ile yerel kayıt.
  İlk açılışta otomatik tohumlanır. Tam güç açıklamaları profil detayında.
- **Zeka Odası → Kelimelik (TAM çalışır):** Türkçe 5 harf, günlük kelime, tahmin + renk
  geri bildirimi (yeşil/sarı/gri), Türkçe ekran klavyesi, skor. Günün ilerlemesi cihazda saklanır.
- **Aile Havuzu:** kişisel skor + aile toplamı + haftalık ortak hedef + liderlik (yerel,
  CloudKit'e hazır arayüz).
- **Yolculuk:** şimdilik placeholder ekran (SceneKit dikey dilimi Faz 2).
- **Tasarım sistemi:** merkezi palet/tipografi (`TUZ/Core/DesignSystem`).

## Gereksinimler

- **Xcode 16+** (proje dosyası Xcode 16 senkronize grupları kullanır)
- **iOS 17+** hedef (Simülatör veya cihaz)

## Çalıştırma

1. `TUZ.xcodeproj` dosyasını Xcode ile aç.
2. Bir iPhone simülatörü seç (örn. iPhone 15) ve **Run** (⌘R).
3. Açılışta profiller otomatik oluşur. **Zeka Odası → Kelimelik** ile oyna.
   Doğru tahminde skor, aktif üyenin profiline ve **Aile Havuzu** toplamına yazılır.

> Aktif oyuncuyu **Profiller** ekranından (ya da hub'daki "Aktif oyuncu" rozetinden) değiştir.

### Proje dosyasını yeniden üretmek (gerekirse)

`TUZ.xcodeproj` elle yazılmıştır ve doğrudan açılır. Bir sorun olursa veya projeyi
sıfırdan üretmek istersen XcodeGen yedeğini kullan:

```bash
brew install xcodegen
xcodegen generate
```

## Klasör yapısı

```
TUZ/
├── App/            # TUZApp (@main), RootView, AppRouter
├── Features/
│   ├── AileMeclisi/    # ana hub
│   ├── Yolculuk/       # SceneKit puzzle (şimdilik placeholder)
│   ├── ZekaOdasi/      # mini oyunlar hub + Kelimelik (tam)
│   ├── Profiller/      # aile üyeleri + güç detayları
│   └── AileHavuzu/     # ortak skor, haftalık hedef, liderlik
├── Core/
│   ├── Models/         # FamilyMember, ScoreEntry, Power, GameKind, WordBank, FamilyData
│   ├── Persistence/    # PersistenceController (SwiftData), ScoreService
│   ├── DesignSystem/   # renk, tipografi, tema bileşenleri
│   └── Extensions/     # Color+Hex, String+Turkish, Date+Daily
├── Resources/          # WordBank.json
├── Assets.xcassets/    # AppIcon (placeholder), AccentColor
└── Localizable.xcstrings
```

## MVP varsayımları (onayına açık)

- **Lokalizasyon:** UI metinleri doğrudan Türkçe yazıldı; projenin taban dili `tr` ve
  boş bir `Localizable.xcstrings` kataloğu eklendi (Xcode metinleri otomatik toplar).
  İleride ek dil gerekirse katalog hazır.
- **Kelimelik kelime listesi:** 152 doğrulanmış 5-harfli Türkçe kelime; tahminler bu
  listeye göre doğrulanır. Liste `Resources/WordBank.json` üzerinden genişletilebilir.
- **Skorlama:** ilk denemede 60, her ek denemede −10 (6. denemede 10), kaybedince 0.
- **AppIcon:** placeholder (boş). Gerçek ikon Faz 4 cilasında.
- **CloudKit:** MVP yerel; `PersistenceController` ve `ScoreService` geçişe hazır.

Sonraki adımlar için `CLAUDE.md` → Yol Haritası.
