# TÜZ — Oyun Tasarım Dokümanı (GDD)

**Platform:** iOS (iPhone) · **Teknoloji:** Swift + SwiftUI + SceneKit · **Sürüm:** 1.0 (taslak) · **Dil:** Türkçe

---

## 1. Vizyon / Özet

**TÜZ**, TÜZ ailesinin 3D figürleriyle oynanan, iOS için zarif bir bulmaca yolculuğudur.

- **Ana oyun — TÜZ Yolculuğu:** *Monument Valley* tarzı "imkânsız mimari" perspektif bulmacaları. Ailenin bireyleri bu yapıların içinde yolculuk eder; her birinin kendine özel bir gücü çözümün parçasıdır.
- **Yan oyun — Zeka Odası:** Senkronsuz oynanan, puanları ortak bir **aile havuzunda** toplanan zeka/bilgi mini oyunları (Pasaparola, TÜZ Trivia, Kelimelik, Matematik).

Görsel dil **premium ve ağırbaşlıdır** (Osmanlı/İslam geometrik estetiği) — ne low-poly ne çocuksu. 57–63 yaş anne-babanın rahat oynayabileceği sakinlikte; çocuk ve gelinler için derinleşen bir zorlukta.

> **Tek cümle:** Ailemizin 3D figürleriyle imkânsız mimarilerde ilerlediğimiz dingin ve zarif bir bulmaca yolculuğu; yanında ailece yarıştığımız bir zeka odası.

---

## 2. Tasarım İlkeleri (Pillars)

1. **Figür başrol.** Test: figürleri çıkarırsak oyun çöker. Karakter sürekli sahnede ve oynanışın merkezinde.
2. **Büyük-dostu sakinlik.** Refleks yok, süre baskısı minimal/kapatılabilir, oynanış düşünseldir.
3. **Onore.** Büyükler vakur rehberler; güçler kişinin **isminin/karakterinin anlamına** bağlı; aile asla rezil/komik duruma düşmez.
4. **Premium, çocuksu değil.** Osmanlı/İslam geometrik zarafeti; sade ama zengin.
5. **Senkronsuz + ortak havuz.** Herkes kendi vaktinde oynar; skorlar tek havuzda birleşir.
6. **Hem birlikte hem rekabet.** Haftalık ortak hedef (co-op) + günlük liderlik tablosu (tatlı rekabet), dengeli.

---

## 3. Hedef Kitle & Bağlam

- **Aile:** TÜZ ailesi — Bilal (baba), Hatice (anne), Huzeyfe (1. çocuk), Fatih (2. çocuk), Sedef (1. gelin), Nur (2. gelin). Hepsi iPhone kullanıyor.
- **Zorluk bandı:** anne-baba **3–6/10**, çocuk-gelinler **5–8/10** (sabit değil, aralık).
- **Ton:** standart muhafazakar Türk ailesi — abartısız, ne aşırı dindar ne seküler. İçerik tamamen temiz (alkol/kumar yok; yerine çay-kahve-ikram kültürü). Figürler tevazulu: anne ve yenge (Sedef) kapalı, eş (Nur) Türk aile yapısına uygun açık.

---

## 4. Görsel Yön (Art Direction)

- **Referans his:** *Monument Valley*'nin sadeliği **+** Osmanlı/İslam geometrik sanatı. Premium, dingin, ağırbaşlı.
- **Palet:** sıcak taş bej/krem zemin, turkuaz–çini mavisi vurgular, pirinç/altın detaylar, derinlikli yumuşak gölgeler.
- **Desen/doku:** geometrik yıldız (girih) panolar, sırlı çini, mukarnas tavanlar, kemerler, kafes (mashrabiya) ışık oyunları.
- **Malzeme:** mat taş, cilalı pirinç, sırlı çini — sade PBR; **flat low-poly görünüm DEĞİL**, zengin ama yalın.
- **KAÇINILACAK:** köşeli low-poly estetik, çocuksu/karikatür renkler, Candy-Crush parlaklığı, kalabalık efekt.
- **Kamera:** 3. şahıs, **uzak, eğik izometrik** (MV açısı). Bölüm kurarken yapı etrafında **sınırlı döndürme**. **FPS yok, Tycoon değil.**
- **Atmosfer/ışık:** yumuşak, sıcak, huzurlu; gün doğumu/akşam tonları; sessiz ve dingin.
- **Ses:** sade, huzurlu ambient/enstrümantal; yumuşak UI sesleri. (Müzikte muhafazakar hassasiyete dikkat — ney/su/ambient dokular, abartısız.)

---

## 5. Ana Oyun: TÜZ Yolculuğu

### 5.1 Çekirdek Mekanikler (MV-tarzı)
- **Yapı döndürme:** bölümün modüler parçalarını döndürerek yol oluşturma.
- **Perspektif hizalama (imzası):** kameradan birleşik görünen iki yolu *gerçekten* birleştirme — imkânsız geometri.
- **Yol/köprü uzatma**, kaydırma platformları, **mekanizmalar** (kol, kapı, asansör, dişli).
- **Gizli yol açma**, **yumuşak engel/tehlike** (düşersen başa değil, yakın güvenli noktaya).
- **Tap-to-move:** karaktere dokunarak geçerli yol üzerinde yürütme (MV gibi).

### 5.2 Bölüm Yapısı
- Her bölüm el yapımı küçük bir **diorama**; ~2–5 dk çözüm; **süre yok**.
- Bölümler **chapter**'lara gruplanır; her chapter bir mekan teması **+** bir karakter teması taşır.

### 5.3 Karakter Katılım Yayı (Hikâye Omurgası)
Karakterler **gerçek aile sırasıyla** katılır; herkes topluca yürümez:
1. **Bölüm 1–2:** Bilal & Hatice yola çıkar (ailenin reisleri, yolun rehberleri).
2. **Bölüm 3:** Huzeyfe katılır.
3. **Bölüm 4:** Fatih katılır.
4. **Bölüm 5:** Sedef katılır.
5. **Bölüm 6:** Nur katılır.
6. **Büyük Final:** hepsi birlikte ailenin evini/konağını yükseltir.

Her karakter, kendi chapter'ında **ana gücüyle** öne çıkar.

### 5.4 Güçlerin Bulmacada Kullanımı
- Her bölümde sahnedeki karakter(ler)in güçleri çözümün parçasıdır.
- **Tek karakter bölümleri:** o kişinin gücüyle çözülür (gücü öğretir/parlatır).
- **Birlik Bölümleri:** birden çok karakter arasında geçişle **güç zinciri** (bkz. §6.3).

### 5.5 Zorluk Bantları (aynı bölüm, ölçekli yardım)
Her aile üyesi **kendi profilinde** oynar; içerik aynı, yardım ölçeklenir:
- **Anne-baba (3–6):** yol gösterici çizgi/işaret, geniş hedef alanı, daha az/yumuşak hareketli tehlike, cömert ipucu.
- **Çocuk-gelinler (5–8):** yardım çizgisi yok, daha karmaşık geometri, daha çok mekanizma/eşzamanlılık, kısıtlı ipucu.
- Zorluk **düşünseldir** — hiçbir profilde refleks/twitch yoktur.

---

## 6. Karakterler & Güç Sistemi

### 6.1 Kurallar
- **Ana Güç = Rare:** her kişiye özel, **eşsiz** mekanik, kimseyle paylaşılmaz.
- **Yan Güç = Ortak Havuz:** belirli oranlarda kesişebilir, düşük potansiyel (uyum hissi).

### 6.2 Kadro
*(Tam, çok cümleli açıklamalar için bkz. `TUZ_Karakter_Guc_Sistemi.xlsx`. Aşağıda özet mekanik.)*

| Aile Üyesi | Lakap | Ana Güç (Rare) | Mekanik (özet) | Yan Güç | Mekanik (özet) |
|---|---|---|---|---|---|
| **Bilal** | Reis Baba | **Yol Gösteren** | Doğru rotayı işaretler, yanlışları soluklaştırır (aydınlatmaz/yol açmaz) | Reisin Çağrısı | Uzaktaki mekanizmayı tetikler / bireyi çağırır |
| **Hatice** | Şefkatli Anne | **Sevgi Kanadı** | Bir bireyin gücünü güçlendirir + aileyi korur (kalkan) | Şefkat Işığı | Bir engeli nazikçe yatıştırır/iter |
| **Huzeyfe** | Atılgan Patron | **Çifte İdare** | Aynı anda **iki** mekanizmayı yönetir | Sır Kâtibi | Gizli mekanizma/geçit açığa çıkarır |
| **Fatih** | Mucit | **Karadan Gemi** | Ölü mekanizmayı devreye alır + olmayan yolu kurar | Kıvılcım | Yakın mekanizmayı tetikler / engeli kısa durdurur |
| **Sedef** | Yardımsever Abla | **Uzanan El** | Sıkışan/geride kalan bireyi elini uzatıp güvene çeker | Sedef Işıltısı | Yüzeyi parlatıp gizli işaretleri belirginleştirir |
| **Nur** | Minnoş | **Gönül Işığı** | Karanlığı aydınlatıp gizli yolları gerçek kılar | Esinti | Bir debuff'tan/engelden zarifçe sıyrılıp geçer |

**Onore katmanı (isim/karakter):** Bilal-i Habeşi'nin sesi → *Reisin Çağrısı*; Hz. Hatice'nin sarıp koruyan sevgisi → *Sevgi Kanadı*; sahabe Huzeyfe'nin sır kâtipliği → *Sır Kâtibi* + esnaflığı → *Atılgan Patron / Çifte İdare*; Fatih'in mühendisliği + gemileri karadan yürütmesi + elektrik → *Mucit / Karadan Gemi / Kıvılcım*; baskı altında parıldayan sedef + yardımseverlik → *Yardımsever Abla / Uzanan El*; "ışık" anlamındaki nur → *Gönül Işığı*.

### 6.3 Birlik Bölümleri
- Chapter finalleri ve kilit anlarda, sahnedeki karakterler arasında geçiş yaparak güçler **birlikte** kullanılır.
- **Örnek zincir:** Huzeyfe iki kolu tutar → Bilal aileyi çağırır → Hatice birini güçlendirir → Sedef çöken köprüyü tutar → Nur karanlığı aydınlatır → Fatih son yolu kurar.
- Güçler eşsiz olduğu için bu zincir anlam kazanır; hikâyenin duygu zirveleri buradadır.

### 6.4 Aile Meclisi (Ara Sahne / Hub)
- Her chapter arası, o ana dek katılmış figürler bir mekânda toplanır (görsel bütünlük).
- Ana navigasyon noktası: buradan **Yolculuk**'a, **Zeka Odası**'na, **Profiller** ve **Aile Havuzu**'na geçilir.

---

## 7. Hikâye / Senaryo

- **Tema:** ailenin, adım adım kurulan bir **ev/konak**a doğru zarif yolculuğu — ailenin gerçek hikâyesinin bir alegorisi.
- **Ton:** sıcak, vakur; sözsüz ya da çok az metin (MV gibi); büyükler yolun rehberi.
- **Mekan temaları (chapter):** avlu → çay bahçesi → çarşı (Huzeyfe) → atölye (Fatih) → gül bahçesi (Sedef) → ışıklı eyvan (Nur) → konak (final).
- **Onore:** anne-baba yolu açar; her birey kendi gücüyle aileye katkı verir; final birliktelikle taçlanır.

---

## 8. Zeka Odası (Mini Oyunlar)

Ayrı bir hub; **senkronsuz**; günlük içerik; ortak aile havuzu.

- **Pasaparola (Rosco):** A–Z harf çarkı; her harfle başlayan/içeren kelime; ipuçları; süre **opsiyonel** (büyükler için kapatılabilir).
- **TÜZ Trivia:** genel kültür + aile temalı sorular (anı/fotoğraf bankası eklenebilir); kategoriler.
- **Kelimelik:** Türkçe 5 harf Wordle; günlük kelime; bazı günler aile temalı; renk geri bildirimi.
- **Matematik:** zihinden işlem/örüntü; seviye ölçekli; süre opsiyonel.

**Sosyal döngü:**
- **Günlük:** herkes günün setini kendi vaktinde oynar → kişisel skor.
- **Ortak havuz (co-op):** skorlar aile toplamına eklenir; **haftalık ortak hedef**.
- **Liderlik (rekabet):** günlük/haftalık bireysel sıralama.

**Zorluk:** oyuncu profiline göre (büyükler için süre kapalı/uzun + bol ipucu; gençler için süreli + az ipucu).

---

## 9. Aile Havuzu & Sosyal Sistem

- **Profil:** her aile üyesi için figür + lakap + tercih edilen zorluk profili.
- **Senkronsuz paylaşım:** bulut üzerinden skor toplama — **CloudKit önerisi** (Apple ekosistemi, ek backend yok). MVP'de yerel; sonra CloudKit.
- **Ortak havuz iki kaynaktan beslenir:** (1) Yolculuk ilerlemesi (ortak chapter açma), (2) Zeka Odası skorları.
- **Denge:** haftalık ortak hedef (birlikte başarma) + günlük/haftalık liderlik (rekabet).

---

## 10. Teknik Mimari

- **Platform:** iOS 17+ (öneri). **Dil:** Swift. **UI:** SwiftUI. **3D:** SceneKit.
- **Neden SceneKit:** USDZ native desteği, animasyon (SCNAnimationPlayer), SwiftUI ile entegrasyon (`SceneView` / `UIViewRepresentable`).
- **App akışı:** *Aile Meclisi* (ana hub) → { *TÜZ Yolculuğu* (SceneKit), *Zeka Odası* (SwiftUI mini oyunlar), *Profiller*, *Aile Havuzu* }.
- **MV imkânsız geometri yaklaşımı (işin zor kısmı):**
  - Modüler, döndürülebilir `SCNNode` yapılar.
  - **Ekran-uzayı (screen-space) hizalama:** iki yol uç noktası ekranda örtüştüğünde (`SCNSceneRenderer.projectPoint` ile) mantıksal bağ kurulur — perspektif "kandırması" buradan gelir.
  - **Yol grafiği (node graph)** üzerinde pathfinding; tap-to-move bu grafik üzerinde yürür.
- **Persistence:** yerel (**SwiftData** veya basit JSON) + ileride **CloudKit** (aile paylaşımlı kayıt, senkronsuz havuz).
- **Figür sistemi:** rigged humanoid **USDZ**; başlangıçta riglenmiş **placeholder** primitive; animasyon klip kütüphanesi (idle, walk, güç animasyonu); **drop-in** değişim için isim/iskelet sözleşmesi (§11).
- **Animasyon:** `SCNAnimationPlayer`; figür başına klip seti; akıcı **cross-fade** geçişler.
- **Lokalizasyon:** Türkçe (`Localizable`). İçerik bankaları (kelime/soru) JSON/asset.

---

## 11. Placeholder → Meshy Figür Hattı

- **Şimdi:** her karakter için **riglenmiş basit placeholder** (renk-kodlu, lakap etiketli), hepsi **aynı iskelet hiyerarşisiyle**.
- **Sonra:** Meshy'den **USDZ** (riglenmiş + animasyonlu) export → **aynı node adı/iskelet sözleşmesi** → kod değişmeden **drop-in**.
- **Sözleşme:**
  - Kök node: `Character_<Ad>` (örn. `Character_Bilal`).
  - Rig kemik adları: standart humanoid (Mixamo benzeri) düzen.
  - Klip adları: `Idle`, `Walk`, `Power_<GüçAdı>` (örn. `Power_YolGosteren`).
  - Asset yolu: `/Characters/<Ad>/<Ad>.usdz`.

---

## 12. MVP / Yol Haritası

- **Faz 0 — İskelet:** Xcode projesi, navigasyon (Aile Meclisi hub), profil sistemi, tasarım token'ları, `CLAUDE.md`.
- **Faz 1 — Zeka Odası (oynanabilir ilk halka):** önce **Kelimelik** tam çalışır → sonra Trivia, Pasaparola, Matematik. Yerel skor + havuz iskeleti. *(Hemen ailece oynanır.)*
- **Faz 2 — Yolculuk dikey dilimi:** SceneKit sahne + kamera, tap-to-move, **1 döndürme + 1 perspektif hizalama** mekaniği, placeholder figür, **2–3 prototip bölüm**, **1 güç** (örn. Yol Gösteren).
- **Faz 3 — Sistem genişleme:** kalan güçler, Birlik Bölümleri, chapter/hikâye akışı, zorluk profilleri, CloudKit havuz.
- **Faz 4 — Cila & Meshy:** Meshy figür drop-in, animasyon/ses cilası, görsel polish, bölüm çoğaltma.

---

## 13. Proje Yapısı (öneri)

```
TUZ/
├── App/
│   ├── TUZApp.swift              # @main
│   └── AppRouter.swift           # navigasyon
├── Features/
│   ├── AileMeclisi/              # ana hub
│   ├── Yolculuk/                 # MV-style puzzle (SceneKit)
│   │   ├── Scene/                # SCNScene, kamera
│   │   ├── Mechanics/            # döndürme, perspektif hizalama, pathfinding
│   │   ├── Levels/               # bölümler (data-driven)
│   │   └── Powers/               # güç sistemi
│   ├── ZekaOdasi/
│   │   ├── Kelimelik/  Trivia/  Pasaparola/  Matematik/
│   ├── Profiller/                # aile üyeleri
│   └── AileHavuzu/               # ortak skor
├── Core/
│   ├── Models/                   # Character, Power, Level, Score...
│   ├── Persistence/              # SwiftData + (ileride) CloudKit
│   ├── DesignSystem/             # renk, tipografi, token (§4)
│   └── Extensions/
├── Characters/                   # figür assetleri (placeholder → Meshy USDZ)
│   ├── Bilal/ Hatice/ Huzeyfe/ Fatih/ Sedef/ Nur/  _Placeholder/
├── Resources/
│   ├── tr.lproj/                 # Localizable
│   ├── WordBank.json             # Kelimelik/Pasaparola
│   └── TriviaBank.json
└── CLAUDE.md
```

---

## 14. Açık Konular / Kararlar

- **Dağıtım:** aile içi → **TestFlight** muhtemelen en pratik (mevcut Apple Developer hesabı). Doğrulanacak.
- **Bulut:** CloudKit vs basit paylaşım — MVP yerel, sonra karar.
- **Ses/müzik:** kaynak ve muhafazakar hassasiyet (enstrümantal/ambient).
- **Trivia anı/fotoğraf bankası:** gizlilik ve içerik yönetimi.
- **Tam bölüm sayısı** ve chapter başına bölüm dağılımı (Faz 3'te netleşir).
