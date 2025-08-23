import SwiftUI

struct SocialMediaShare: View {
    @ObservedObject var controller: SocialMediaShareController

    var body: some View {
        VStack(spacing: 20) {
            Text("Social Media Share")
                .font(.headline)
            
            Button(action: {
                controller.createTodaySummary()
            }) {
                Text("Create my summary for today")
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .sheet(isPresented: $controller.showingSummaryPopup) {
            SummaryImageView(controller: controller)
        }
    }
}