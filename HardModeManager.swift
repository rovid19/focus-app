import SwiftUI

class HardModeManager: ObservableObject {
    static let shared = HardModeManager()
    @Published var isHardMode: Bool = false

     init() {}

    func toggleHardMode() {
        isHardMode.toggle()
    }
}