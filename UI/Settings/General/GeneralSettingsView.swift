import SwiftUI

struct GeneralSettingsView: View {
        @EnvironmentObject var controller: GeneralSettingsController

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hotkeys Section
                HotkeysSection()

                // Session Settings Section
                SessionSettingsSection()
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}



