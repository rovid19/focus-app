import SwiftUI

struct RootView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var supabaseAuth: SupabaseAuth

    var body: some View {
       VStack {
            switch coordinator.route {
            case .home:
                HomeView(controller: coordinator.homeController)
            }
        }
        .frame(width: 320, height: 420) // frame size for each popup that appears rendered inside that VStack
    }
    
}
