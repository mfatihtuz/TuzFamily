import Foundation

/// Faz 2 prototip bölümleri (GDD §5.2, §12). Şimdilik koda gömülü (data-driven
/// yapı, deterministik); ileride aynı `LevelData` JSON'dan da yüklenebilir.
enum LevelLibrary {

    static func level(id: String) -> LevelData? {
        all.first { $0.id == id }
    }

    static let all: [LevelData] = [bolum1, bolum2, bolum3]

    // MARK: - Bölüm 1 — Avlu (yükselen basit yol)
    static let bolum1 = LevelData(
        id: "bolum1",
        title: "Avlu",
        subtitle: "İlk adımlar — yolu takip et",
        nodes: [
            LevelNode(id: "a", point: .init(x: 0, y: 0, z: 0)),
            LevelNode(id: "b", point: .init(x: 1, y: 0, z: 0)),
            LevelNode(id: "c", point: .init(x: 2, y: 0, z: 0)),
            LevelNode(id: "d", point: .init(x: 2, y: 1, z: 1)),
            LevelNode(id: "e", point: .init(x: 2, y: 1, z: 2)),
            LevelNode(id: "f", point: .init(x: 2, y: 2, z: 3))
        ],
        edges: [
            .init(a: "a", b: "b"), .init(a: "b", b: "c"), .init(a: "c", b: "d"),
            .init(a: "d", b: "e"), .init(a: "e", b: "f")
        ],
        startID: "a",
        goalID: "f"
    )

    // MARK: - Bölüm 2 — Çay Bahçesi (çıkmaz dallı)
    static let bolum2 = LevelData(
        id: "bolum2",
        title: "Çay Bahçesi",
        subtitle: "Çıkmazlara dikkat — Yol Gösteren yardımcı olur",
        nodes: [
            LevelNode(id: "a", point: .init(x: 0, y: 0, z: 0)),
            LevelNode(id: "b", point: .init(x: 0, y: 0, z: 1)),
            LevelNode(id: "c", point: .init(x: 0, y: 0, z: 2)),
            LevelNode(id: "d", point: .init(x: 1, y: 0, z: 2)),
            LevelNode(id: "e", point: .init(x: 2, y: 0, z: 2)),
            LevelNode(id: "f", point: .init(x: 2, y: 1, z: 3)),
            LevelNode(id: "g", point: .init(x: 2, y: 1, z: 4)),
            LevelNode(id: "k", point: .init(x: 1, y: 0, z: 1))   // çıkmaz dal
        ],
        edges: [
            .init(a: "a", b: "b"), .init(a: "b", b: "c"), .init(a: "c", b: "d"),
            .init(a: "d", b: "e"), .init(a: "e", b: "f"), .init(a: "f", b: "g"),
            .init(a: "b", b: "k")
        ],
        startID: "a",
        goalID: "g"
    )

    // MARK: - Bölüm 3 — Çarşı (dallı, çok kademeli)
    static let bolum3 = LevelData(
        id: "bolum3",
        title: "Çarşı",
        subtitle: "Kademeli yapı — doğru kolu seç",
        nodes: [
            LevelNode(id: "a", point: .init(x: 0, y: 0, z: 0)),
            LevelNode(id: "b", point: .init(x: 1, y: 0, z: 0)),
            LevelNode(id: "c", point: .init(x: 2, y: 0, z: 0)),
            LevelNode(id: "d", point: .init(x: 2, y: 0, z: 1)),
            LevelNode(id: "e", point: .init(x: 2, y: 0, z: 2)),
            LevelNode(id: "f", point: .init(x: 3, y: 1, z: 2)),
            LevelNode(id: "g", point: .init(x: 4, y: 1, z: 2)),
            LevelNode(id: "h", point: .init(x: 4, y: 2, z: 3)),   // hedef
            LevelNode(id: "x", point: .init(x: 2, y: 0, z: -1)),  // çıkmaz dal
            LevelNode(id: "y", point: .init(x: 0, y: 0, z: 1))    // çıkmaz dal
        ],
        edges: [
            .init(a: "a", b: "b"), .init(a: "b", b: "c"), .init(a: "c", b: "d"),
            .init(a: "d", b: "e"), .init(a: "e", b: "f"), .init(a: "f", b: "g"),
            .init(a: "g", b: "h"), .init(a: "c", b: "x"), .init(a: "a", b: "y")
        ],
        startID: "a",
        goalID: "h"
    )
}
