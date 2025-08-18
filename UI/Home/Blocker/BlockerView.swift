import SwiftUI

struct BlockerView: View {
    @ObservedObject var controller: BlockerController
    @EnvironmentObject var blockerManager: BlockerManager

    init(controller: BlockerController) {
        self.controller = controller
        print("BlockerView init")
    }

    var body: some View {
        VStack(spacing: 12) {
            BlockerCard(controller: controller, blockerManager: blockerManager)
            HardModeCard(controller: controller)
            DurationPickerCard(controller: controller)
            ProfilesCard(controller: controller)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
    }
}
