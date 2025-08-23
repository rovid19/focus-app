import SwiftUI

struct SettingsView: View {
    @StateObject private var controller: SettingsController
    @EnvironmentObject var router: Router

    init(controller: SettingsController) {
        _controller = StateObject(wrappedValue: controller)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 👇 Your custom mini bar under native titlebar
           /* CustomTitlebar()
                .frame(height: 32)
*/
            // 👇 Header row
            HStack {
                Text("Settings")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 12)
            .frame(height: 36)
            .background(.regularMaterial)

            .overlay(Divider(), alignment: .bottom)

            // 👇 Sidebar + content
            HStack(spacing: 0) {
                SettingsSidebar(controller: controller)
                    .frame(width: 240)
                    .background(.ultraThinMaterial)

                SettingsContent(controller: controller)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.regularMaterial)
            }
            .frame(width: 700, height: 600)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
        .onAppear { controller.loadSettings() }
    }
}

/*

struct CustomTitlebar: View {
    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(Color.red).frame(width: 12, height: 12)
            Circle().fill(Color.yellow).frame(width: 12, height: 12)
            Circle().fill(Color.green).frame(width: 12, height: 12)
        }
        .padding(.leading, 12)
        .frame(height: 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .overlay(Divider(), alignment: .bottom)
    }
}
*/
