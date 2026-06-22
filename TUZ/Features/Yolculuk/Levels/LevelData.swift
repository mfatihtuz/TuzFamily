import Foundation

/// Veri-güdümlü bölüm (level) tanımı (GDD §5.2, §10).
///
/// Bir bölüm, yürünebilir noktaların (`nodes`) ve aralarındaki bağların
/// (`edges`) oluşturduğu bir **yol grafiği**dir. 3D ortam bu grafikten
/// programatik olarak (modüler bloklarla) kurulur — harici 3D dosya gerekmez.
/// Döndürme ve perspektif-hizalama verisi (rotators/seams) sonraki adımda eklenecek.

/// Izgara koordinatı. x: sütun, z: sıra, y: yükseklik kademesi.
struct LevelGridPoint: Codable, Hashable {
    var x: Int
    var y: Int
    var z: Int
}

/// Yürünebilir bir nokta (bir platform karosunun merkezi).
struct LevelNode: Codable, Hashable, Identifiable {
    var id: String
    var point: LevelGridPoint
}

/// İki nokta arasındaki yürünebilir bağ (çift yönlü).
struct LevelEdge: Codable, Hashable {
    var a: String
    var b: String
}

/// Tam bir bölüm.
struct LevelData: Codable, Hashable, Identifiable {
    var id: String
    var title: String
    var subtitle: String
    var nodes: [LevelNode]
    var edges: [LevelEdge]
    var startID: String
    var goalID: String
}
