import Observation

/// Aile Meclisi (ana hub) üzerinden gidilebilecek ekranlar.
enum Route: Hashable {
    case zekaOdasi
    case kelimelik
    case yolculuk
    case yolculukLevel(String)   // bölüm (level) kimliği
    case profiller
    case aileHavuzu
    case ayarlar
}

/// Uygulamanın navigasyon yığınını yöneten basit yönlendirici.
///
/// `NavigationStack(path:)` ile birlikte kullanılır; ekranlar `push(_:)`
/// ile yığına eklenir. Tek bir yığın tutulur (Aile Meclisi köktür).
@Observable
final class AppRouter {
    var path: [Route] = []

    func push(_ route: Route) {
        path.append(route)
    }

    func popToRoot() {
        path.removeAll()
    }
}
