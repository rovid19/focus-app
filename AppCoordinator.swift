import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    enum Route {
        case home
    }

    @Published var route: Route = .home
    let homeController: HomeController

    init(homeController: HomeController) {
        self.homeController = homeController
    }

    func navigate(to route: Route) {
        self.route = route
    }

    
}
