import SwiftUI
import Supabase

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock HomeController
        let mockController = HomeController(router: Router()/*, blockerManager: BlockerManager.shared*/)
        mockController.switchView(to: "focus")

        // Mock SupabaseAuth with fake user
        let mockAuth = SupabaseAuth()
        mockAuth.user = User(
            id: UUID(),
            appMetadata: [:],
            userMetadata: [:],
            aud: "",
            confirmationSentAt: nil,
            recoverySentAt: nil,
            emailChangeSentAt: nil,
            newEmail: nil,
            invitedAt: nil,
            actionLink: nil,
            email: "mock@example.com",
            phone: nil,
            createdAt: Date(),
            confirmedAt: nil,
            emailConfirmedAt: nil,
            phoneConfirmedAt: nil,
            lastSignInAt: nil,
            role: nil,
            updatedAt: Date(),
            identities: nil,
            factors: nil
        )

        // HardModeManager from your real code
        let mockHardModeManager = FocusManager()

        return HomeView(controller: mockController)
            .environmentObject(mockAuth)
            .environmentObject(mockHardModeManager) // ✅ inject here
            .frame(width: 800, height: 600)
            .previewLayout(.sizeThatFits)
    }
}
