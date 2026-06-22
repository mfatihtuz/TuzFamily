import Foundation

/// Veri-güdümlü bölüm (level) tanımı (GDD §5.2, §10).
///
/// Bir bölüm, yürünebilir noktaların (`nodes`) ve aralarındaki bağların
/// (`edges`) oluşturduğu bir **yol grafiği**dir. 3D ortam bu grafikten
/// programatik olarak (modüler bloklarla) kurulur — harici 3D dosya gerekmez.

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

/// Döndürülebilir grup (GDD §5.1 "yapı döndürme"). `nodeIDs` içindeki karolar
/// `pivot` etrafında birlikte döner; döndükçe dünya konumları değişir.
struct LevelRotator: Codable, Hashable {
    var id: String
    var pivot: LevelGridPoint
    var nodeIDs: [String]
    var stepDegrees: Double

    init(id: String, pivot: LevelGridPoint, nodeIDs: [String], stepDegrees: Double = 90) {
        self.id = id
        self.pivot = pivot
        self.nodeIDs = nodeIDs
        self.stepDegrees = stepDegrees
    }
}

/// Perspektif-hizalama adayı (GDD §5.1 "perspektif hizalama" — imza mekanik).
/// İki uç ekranda (ortografik kamerada) çakıştığında gerçek bir kenara dönüşür.
struct LevelSeam: Codable, Hashable {
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
    var rotators: [LevelRotator]
    var seams: [LevelSeam]

    init(
        id: String,
        title: String,
        subtitle: String,
        nodes: [LevelNode],
        edges: [LevelEdge],
        startID: String,
        goalID: String,
        rotators: [LevelRotator] = [],
        seams: [LevelSeam] = []
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.nodes = nodes
        self.edges = edges
        self.startID = startID
        self.goalID = goalID
        self.rotators = rotators
        self.seams = seams
    }
}
