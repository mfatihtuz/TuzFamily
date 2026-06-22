import Foundation

/// Yürünebilir noktaların yol grafiği. Tap-to-move ve Yol Gösteren gücü bu
/// grafik üzerinde çalışır (GDD §10). Bağlar çift yönlüdür.
///
/// İleride döndürme/perspektif-hizalama, kenar kümesini dinamik değiştirerek
/// (kenar ekle/çıkar) buraya bağlanacak.
struct PathGraph {
    private var adjacency: [String: Set<String>] = [:]

    init(nodes: [LevelNode], edges: [LevelEdge]) {
        for node in nodes {
            adjacency[node.id] = []
        }
        for edge in edges {
            adjacency[edge.a, default: []].insert(edge.b)
            adjacency[edge.b, default: []].insert(edge.a)
        }
    }

    func neighbors(of id: String) -> Set<String> {
        adjacency[id] ?? []
    }

    /// İki nokta arasındaki en kısa yol (kenar sayısına göre, BFS). Yoksa nil.
    func shortestPath(from start: String, to goal: String) -> [String]? {
        if start == goal { return [start] }

        var queue = [start]
        var head = 0
        var visited: Set<String> = [start]
        var parent: [String: String] = [:]

        while head < queue.count {
            let current = queue[head]
            head += 1

            for next in neighbors(of: current) where !visited.contains(next) {
                visited.insert(next)
                parent[next] = current

                if next == goal {
                    var path = [goal]
                    var node = goal
                    while let previous = parent[node] {
                        path.append(previous)
                        node = previous
                    }
                    return path.reversed()
                }
                queue.append(next)
            }
        }
        return nil
    }
}
