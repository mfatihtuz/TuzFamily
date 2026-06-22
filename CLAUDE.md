# TÜZ — Proje Kuralları (CLAUDE.md)

## Proje
iOS oyunu. Ana: Monument Valley tarzı 3D bulmaca (SceneKit). Yan: Zeka Odası mini oyunlar.
Tam tasarım: `TUZ_Tasarim_Dokumani.md`. Güç tablosu: `TUZ_Karakter_Guc_Sistemi.xlsx`.

## Stack
iOS 17+, Swift, SwiftUI (UI), SceneKit (3D), SwiftData (yerel), ileride CloudKit.
Türkçe UI (taban dil `tr`, `Localizable.xcstrings`), İngilizce kod tanımları.

## Anti-Hallucination
- API uydurma; emin değilsen dur ve sor / resmi dokümana dayan.
- Var olmayan sembol/dosya/asset referans verme.
- Her adımda proje derlenir kalsın; küçük commit'ler.
- Belirsizlikte varsayımı yaz ve onay iste.

## Mimari
Feature-bazlı (`TUZ/Features/…`), `TUZ/Core/` paylaşımlı. Büyük tek dosya yok.
Navigasyon: `AppRouter` + `NavigationStack`. Kök ekran Aile Meclisi (hub).

## Proje Dosyası
`TUZ.xcodeproj` Xcode 16 "file system synchronized groups" kullanır: `TUZ/`
klasörüne eklenen dosyalar otomatik derlemeye girer (pbxproj'a el ile ekleme gerekmez).
Yedek olarak `project.yml` (XcodeGen) vardır.

## Figür Sözleşmesi
`Character_<Ad>` kök node; klipler `Idle`/`Walk`/`Power_<GüçAdı>`; `/Characters/<Ad>/<Ad>.usdz`.
Placeholder ve Meshy aynı sözleşmeyi paylaşır (drop-in). (Faz 2+)

## Yol Haritası
Faz 0 iskelet → Faz 1 Zeka Odası → Faz 2 Yolculuk dikey dilimi → Faz 3 sistem → Faz 4 Meshy+cila.
**Şu an: Faz 0 + Faz 1 (Kelimelik tam çalışır).** Sıradaki: Trivia, Pasaparola, Matematik;
haftalık ortak hedef/liderlik derinleştirme; ardından Faz 2 SceneKit dikey dilimi.
