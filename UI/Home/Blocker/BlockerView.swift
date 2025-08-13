import SwiftUI

struct BlockerView: View {
    @ObservedObject var controller: BlockerController

    init(controller: BlockerController) {
        self.controller = controller
    }

    var body: some View {
        Text("Blocker")
    }
}
