import SwiftUI

struct HardModeCard: View {
    @ObservedObject var controller: BlockerController
    @EnvironmentObject var blockerManager: BlockerManager

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "shield")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hard Mode")
                        .font(.system(size: 14, weight: .medium))
                    Text("When enabled, you cannot turn it off or change time while a session is running.")
                        .font(.system(size: 12))
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
