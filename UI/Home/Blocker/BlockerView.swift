import SwiftUI

struct BlockerView: View {
    @ObservedObject var controller: BlockerController
    @EnvironmentObject var blockerManager: BlockerManager
    @State private var blockerCardVisible = false
    @State private var hardModeCardVisible = false
    @State private var durationPickerCardVisible = false
    @State private var profilesCardVisible = false

    init(controller: BlockerController) {
        self.controller = controller
    }

    var body: some View {
        VStack(spacing: 12) {
            BlockerCard(controller: controller, blockerManager: blockerManager)
                .opacity(blockerCardVisible ? 1 : 0)
                .offset(y: blockerCardVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.6), value: blockerCardVisible)

            HardModeCard(controller: controller, blockerManager: blockerManager)
                .opacity(hardModeCardVisible ? 1 : 0)
                .offset(y: hardModeCardVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.6), value: hardModeCardVisible)

            DurationPickerCard(controller: controller, blockerManager: blockerManager)
                .opacity(durationPickerCardVisible ? 1 : 0)
                .offset(y: durationPickerCardVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.6), value: durationPickerCardVisible)

            ProfilesCard(controller: controller, blockerManager: blockerManager)
                .opacity(profilesCardVisible ? 1 : 0)
                .offset(y: profilesCardVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.6), value: profilesCardVisible)
        }
        //.padding(.horizontal, 24)
        //.padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .onAppear {
            animateElements()

        }
    }

    private func animateElements() {
        withAnimation(.easeOut(duration: 0.3)) {
            blockerCardVisible = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.3)) {
                hardModeCardVisible = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.3)) {
                durationPickerCardVisible = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.3)) {
                profilesCardVisible = true
            }
        }
    }
}
