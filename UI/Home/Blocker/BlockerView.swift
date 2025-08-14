import SwiftUI

struct BlockerView: View {
    @ObservedObject var controller: BlockerController

    init(controller: BlockerController) {
        self.controller = controller
        print("BlockerView init")
    }

    var body: some View {
        VStack(spacing: 12) {
            BlockerCard(controller: controller)
            HardModeCard(controller: controller)
            ProfilesCard(controller: controller)
        }
    }


}
