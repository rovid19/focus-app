import SwiftUI

// MARK: - Main ProfilesCard
struct ProfilesCard: View {
    @ObservedObject var controller: BlockerController

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ProfilesHeader()
            ProfilesPicker(controller: controller)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Header
struct ProfilesHeader: View {
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                VStack(alignment: .leading) {
                    Text("Profiles")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Choose a blocking profile")
                        .font(.system(size: 12))
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
        Picker("Profile", selection: $controller.selectedProfile) {
            Text("Custom").tag("custom")
            Text("Workday").tag("workday")
            Text("Deep Focus").tag("deep")
            Text("Social Detox").tag("social")
        }
        .pickerStyle(.menu)
        .frame(width: 220)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }
}
