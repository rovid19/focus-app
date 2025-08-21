import SwiftUI

struct DurationPickerCard: View {
    @ObservedObject var controller: BlockerController
    @ObservedObject var blockerManager: BlockerManager

    var body: some View {
        if !blockerManager.isRunning {
            HStack(spacing: 12) {
                // left icon + labels
                HStack(spacing: 12) {
                    Image(systemName: "clock")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Duration")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(.white)
                        Text("How long to block websites and apps")
                            .font(.custom("Inter-Regular", size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }

                Spacer()

                // 🔹 custom styled dropdown menu
                Menu {
                    ForEach(1 ... 12, id: \.self) { hours in
                        Button("\(hours) hour\(hours == 1 ? "" : "s")") {
                            controller.selectedHours = hours
                        }
                    }
                } label: {
                    HStack {
                        Text("\(controller.selectedHours) hour\(controller.selectedHours == 1 ? "" : "s")")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1)) // ✅ same as your original
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1) // ✅ same as your original
                            )
                    )
                }
            }
            .padding(12)
            .glassBackground(cornerRadius: 16)
        }
    }
}
