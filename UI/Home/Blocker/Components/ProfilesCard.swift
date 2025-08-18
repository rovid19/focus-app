import SwiftUI

// MARK: - Main ProfilesCard
struct ProfilesCard: View {
    @ObservedObject var controller: BlockerController

    var body: some View {
        HStack(spacing: 8) {
            ProfilesHeader()
            ProfilesPicker(controller: controller)
        }
        .padding(12)
        .defaultBackgroundStyle()
    }
}

// MARK: - Header
struct ProfilesHeader: View {
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "slider.horizontal.3")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.white.opacity(0.8))
                VStack(alignment: .leading) {
                    Text("Profiles")
                        .font(.custom("Inter-Regular", size: 16))
                    Text("Choose a blocking profile")
                        .font(.custom("Inter-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            Spacer()
        }
    }
}

// MARK: - Picker
struct ProfilesPicker: View {
    @ObservedObject var controller: BlockerController

    var body: some View {
        Menu {
            Button("Custom") { controller.selectedProfile = "custom" }
            Button("Workday") { controller.selectedProfile = "workday" }
            Button("Deep Focus") { controller.selectedProfile = "deep" }
            Button("Social Detox") { controller.selectedProfile = "social" }
        } label: {
            HStack {
                Text(controller.selectedProfile.capitalized)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}
