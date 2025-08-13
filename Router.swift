import SwiftUI

enum ViewType {
    case home
    case settings
}

class Router: ObservableObject {
    @Published var currentView:ViewType = .home

    func changeView(view: ViewType) {
        currentView = view
    }
   
}
