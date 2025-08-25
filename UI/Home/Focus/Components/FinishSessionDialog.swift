import SwiftUI

struct FinishSessionDialog: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var isVisible = false
    @State private var contentVisible = false
    @State private var isExiting = false
    @ObservedObject var controller: FocusController

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                // Header with Title and Save Button
                HStack {
                    Text("Session Complete")
                        .font(.custom("Inter-Medium", size: 14))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: saveSession) {
                        HStack(spacing: 6) {
                            Text("SAVE")
                                .font(.custom("Inter-Regular", size: 12))
                        }
                        .foregroundColor(.white)
                        
                    }
                    .glassy()
                }
                .opacity(contentVisible ? 1 : 0)
                .offset(y: contentVisible ? 0 : 10)

                // Input Fields
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Session title")
                            .font(.custom("Inter-Regular", size: 12))
                            .foregroundColor(.white.opacity(0.6))

                        TextField("Enter session title...", text: $title)
                            .font(.custom("Inter-Regular", size: 14))
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .glassBackground(cornerRadius: 8)
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Description")
                            .font(.custom("Inter-Regular", size: 12))
                            .foregroundColor(.white.opacity(0.6))

                        TextField("Short description...", text: $description, axis: .vertical)
                            .font(.custom("Inter-Regular", size: 14))
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .glassBackground(cornerRadius: 8)
                            .foregroundColor(.white)
                            .lineLimit(2, reservesSpace: true)
                    }
                }
                .opacity(contentVisible ? 1 : 0)
                .offset(y: contentVisible ? 0 : 10)
            }
            .padding(24)
            .glassBackground()
            .scaleEffect(isVisible ? 1 : 0.8)
            .opacity(isVisible ? 1 : 0)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            startEntranceAnimation()
        }
    }

    // MARK: - Animation Functions

    private func startEntranceAnimation() {
        withAnimation(.easeOut(duration: 0.4)) {
            isVisible = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                contentVisible = true
            }
        }
    }

    private func startExitAnimation() {
        guard !isExiting else { return }
        isExiting = true

        withAnimation(.easeInOut(duration: 0.3)) {
            contentVisible = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.4)) {
                isVisible = false
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            controller.homeController.showFinishSessionDialog = false
        }
    }

    // MARK: - Actions

    private func saveSession() {
        Task {
            await addStatToDatabase()
        }
    }

     func addStatToDatabase() async {
        let secondsToSend = controller.homeController.secondsToSend
        print("secondsToSend: \(secondsToSend)")
        do {
            try await StatisticsManager.shared.addStat(title: title.isEmpty ? "Focus Session" : title, time_elapsed: secondsToSend, description: description)
            startExitAnimation()
        } catch {
            print("Error adding stat to database: \(error)")
            startExitAnimation()
        }
    }
}
