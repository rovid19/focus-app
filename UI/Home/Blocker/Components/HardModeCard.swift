import SwiftUI

struct HardModeCard: View {
    @ObservedObject var controller: BlockerController
    @EnvironmentObject var blockerManager: BlockerManager

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "shield")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.white.opacity(0.7))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hard Mode")
                        .font(.custom("Inter-Regular", size: 14))
                    Text("When enabled, you cannot turn it off or change time while a session is running.")
                        .font(.custom("Inter-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { blockerManager.hardLocked },
                set: { _ in blockerManager.toggleHardLocked() }
            ))
            .toggleStyle(SwitchToggleStyle())
            .opacity(blockerManager.hardLocked ? 0.6 : 1)
        }
        .padding(12)
        .defaultBackgroundStyle()
    }
}
