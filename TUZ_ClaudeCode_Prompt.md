# TÜZ — Claude Code Başlangıç Promptu

> **Nasıl kullanılır:** Yeni bir Xcode/iOS klasörü aç, `TUZ_Tasarim_Dokumani.md` dosyasını köke koy, sonra aşağıdaki **"PROMPT"** bloğunu Claude Code'a yapıştır. Bölüm 0–4 ilk oturum içindir; 5–7 referanstır.

---

## PROMPT (Claude Code'a yapıştır)

### 0. Rol & Bağlam
Sen, **"TÜZ"** adlı bir iOS oyununu sıfırdan kuran kıdemli bir iOS geliştiricisisin. Oyun iki katmanlıdır:
1. **TÜZ Yolculuğu** — *Monument Valley* tarzı 3D imkânsız-mimari bulmacaları (SceneKit), aile figürleri başrolde.
2. **Zeka Odası** — senkronsuz mini oyunlar (Pasaparola, TÜZ Trivia, Kelimelik, Matematik), skorlar ortak **aile havuzunda** toplanır.

Tasarımın **tamamı** `TUZ_Tasarim_Dokumani.md` dosyasındadır. **Önce onu oku, ona uy.** Çelişki olursa dokümana göre davran ve bana sor.

### 1. Teknik Kısıtlar
- **iOS 17+**, **Swift**, **SwiftUI** (UI), **SceneKit** (3D).
- MVP'de **3. parti ücretli servis YOK**. 3D figürler **USDZ**; şimdilik **placeholder** (riglenmiş primitive).
- Persistence: **SwiftData** (yerel) → ileride **CloudKit**. MVP'de yerel yeterli.
- **Türkçe UI** (`Localizable`); kod tanımları İngilizce.
- Mimari: §13'teki klasör yapısı; modüler, feature-bazlı.

### 2. Çalışma Kuralları (anti-hallucination — KRİTİK)
- **API/framework uydurma.** Emin değilsen DUR ve sor ya da resmi dokümana dayan. SceneKit/SwiftUI/SwiftData API'lerini **gerçek imzalarıyla** kullan.
- Var olmayan dosya/sembol/asset referans verme.
- **Küçük, derlenebilir adımlar.** Her adım sonunda proje **derlenir** halde kalsın.
- Belirsizlik varsa **varsayımını açıkça yaz** ve onay iste; sessizce ilerleme.
- Büyük tek dosya yok; sorumluluğa göre böl.
- Her faz/iş için ayrı, küçük commit/PR; ne yaptığını kısaca özetle.

### 3. İLK GÖREV — Faz 0 + Faz 1 (MVP ilk halka)
Sırayla yap; her adımda derlenir bırak:
1. **Proje iskeleti:** SwiftUI App (`TUZApp.swift`), §13 klasör yapısı, `AppRouter`.
2. **Navigasyon:** *Aile Meclisi* (ana hub) → { Zeka Odası, Yolculuk (şimdilik placeholder ekran), Profiller, Aile Havuzu }.
3. **Profil sistemi:** 6 aile üyesi (lakap + ana/yan güç + zorluk profili), yerel kayıt (SwiftData). Veriyi §5'teki tablodan al.
4. **Zeka Odası → Kelimelik (TAM çalışır):** Türkçe 5 harf, günlük kelime, tahmin + renk geri bildirimi (yeşil/sarı/gri), klavye, skor. Kelime bankası `Resources/WordBank.json`.
5. **Aile Havuzu iskeleti:** kişisel skor + aile toplamı (yerel; CloudKit'e hazır arayüz).
6. **Tasarım token'ları:** §4 paleti/tipografisi merkezi (`Core/DesignSystem`).
7. **`CLAUDE.md` oluştur:** §7'deki içerikle.

**Kabul kriterleri:** proje derlenir; hub'dan Kelimelik açılıp oynanır; doğru tahminde skor profile **ve** aile havuzuna yazılır; UI tamamen Türkçe.

### 4. Sonraki Fazlar (özet — her biri ayrı iş)
- **Faz 1 devamı:** Trivia, Pasaparola, Matematik + senkronsuz günlük döngü + haftalık ortak hedef/liderlik.
- **Faz 2:** SceneKit **Yolculuk dikey dilimi** — kamera (uzak/eğik izometrik), tap-to-move (node graph), **1 döndürme + 1 perspektif hizalama** mekaniği (screen-space alignment), placeholder figür, **2–3 prototip bölüm**, **1 güç** (Yol Gösteren).
- **Faz 3:** kalan güçler, **Birlik Bölümleri**, chapter/hikâye akışı, zorluk profilleri, **CloudKit** havuz.
- **Faz 4:** **Meshy figür drop-in** (§6 sözleşmesi), animasyon/ses cilası, bölüm çoğaltma.

---

## 5. Karakter & Güç Referansı (kod için)

| Üye | id | Lakap | Ana Güç (rare) | Yan Güç |
|---|---|---|---|---|
| Bilal | `bilal` | Reis Baba | Yol Gösteren | Reisin Çağrısı |
| Hatice | `hatice` | Şefkatli Anne | Sevgi Kanadı | Şefkat Işığı |
| Huzeyfe | `huzeyfe` | Atılgan Patron | Çifte İdare | Sır Kâtibi |
| Fatih | `fatih` | Mucit | Karadan Gemi | Kıvılcım |
| Sedef | `sedef` | Yardımsever Abla | Uzanan El | Sedef Işıltısı |
| Nur | `nur` | Minnoş | Gönül Işığı | Esinti |

**Kural:** Ana güç eşsiz/paylaşılmaz; yan güç ortak havuz (kesişebilir). Tam açıklamalar: `TUZ_Karakter_Guc_Sistemi.xlsx` / GDD §6.

## 6. Figür Pipeline Sözleşmesi (kodu drop-in yaz)
- Kök node: `Character_<Ad>` (örn. `Character_Bilal`).
- Rig: standart humanoid (Mixamo benzeri) kemik adları.
- Animasyon klipleri: `Idle`, `Walk`, `Power_<GüçAdı>` (örn. `Power_YolGosteren`).
- Asset: `/Characters/<Ad>/<Ad>.usdz`. Placeholder yokken `_Placeholder` riglenmiş primitive kullan; aynı node/clip adlarıyla → Meshy gelince kod değişmeden değişir.

## 7. CLAUDE.md İçeriği (oluşturulacak)
```markdown
# TÜZ — Proje Kuralları (CLAUDE.md)

## Proje
iOS oyunu. Ana: Monument Valley tarzı 3D bulmaca (SceneKit). Yan: Zeka Odası mini oyunlar.
Tam tasarım: TUZ_Tasarim_Dokumani.md. Güç tablosu: TUZ_Karakter_Guc_Sistemi.xlsx.

## Stack
iOS 17+, Swift, SwiftUI (UI), SceneKit (3D), SwiftData (yerel), ileride CloudKit.
Türkçe UI (Localizable), İngilizce kod tanımları.

## Anti-Hallucination
- API uydurma; emin değilsen dur ve sor / resmi dokümana dayan.
- Var olmayan sembol/dosya/asset referans verme.
- Her adımda proje derlenir kalsın; küçük commit'ler.
- Belirsizlikte varsayımı yaz ve onay iste.

## Mimari
Feature-bazlı (Features/…), Core/ paylaşımlı. Büyük tek dosya yok.

## Figür Sözleşmesi
Character_<Ad> kök node; klipler Idle/Walk/Power_<GüçAdı>; /Characters/<Ad>/<Ad>.usdz.
Placeholder ve Meshy aynı sözleşmeyi paylaşır (drop-in).

## Yol Haritası
Faz 0 iskelet → Faz 1 Zeka Odası → Faz 2 Yolculuk dikey dilimi → Faz 3 sistem → Faz 4 Meshy+cila.
Şu an: Faz 0/1.
```
