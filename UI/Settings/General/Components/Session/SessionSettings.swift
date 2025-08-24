import SwiftUI

struct SessionSettingsSection: View {
    @EnvironmentObject var controller: GeneralSettingsController

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Session Configuration", description: "Configure session defaults and limits")

            VStack(spacing: 12) {
                DurationSettingRow(
                    title: "Focus Session Minimal Duration",
                    description: "Minimum time for focus sessions",
                    value: controller.settings.focusMinimalDuration,
                    unit: "minutes",
                    range: 5 ... 120,
                    onChange: { newValue in
                        if let homeController = controller.homeController,
                           !(homeController.focusController.isSessionRunning)
                        {
                            controller.settings.focusMinimalDuration = newValue
                        } else {
                            print("cant change this while session is running")
                        }
                    },
                    increment: 5
                )

                DurationSettingRow(
                    title: "Blocker Session Minimal Duration",
                    description: "Minimum time for blocking sessions",
                    value: controller.settings.blockerMinimalDuration,
                    unit: "hours",
                    range: 1 ... 12,
                    onChange: { newValue in
                        if let homeController = controller.homeController,
                           !(homeController.focusController.isSessionRunning)
                        {
                            controller.settings.blockerMinimalDuration = newValue
                        } else {
                            print("cant change this while session is running")
                        }
                    },
                    increment: 1
                )

                TabLimitSettingRow(
                    title: "Allowed Tabs During Blocking",
                    description: "Maximum browser tabs allowed during blocking sessions",
                    value: controller.settings.allowedTabsDuringBlocking,
                    range: 1 ... 3,
                    onChange: { newValue in
                        if let homeController = controller.homeController,
                           !(homeController.focusController.isSessionRunning)
                        {
                            controller.settings.allowedTabsDuringBlocking = newValue
                        } else {
                            print("cant change this while session is running")
                        }
                    }
                )
            }
        }
        .padding(16)
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

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.custom("Inter-Regular", size: 15))
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))

            Text(description)
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}
