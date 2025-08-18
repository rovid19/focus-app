import SwiftUI

struct SummaryStat: View {
    let totalHours: Double
    let totalMinutes: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Left side: Icon + Title/Description
            HStack(spacing: 12) {
                // Icon container with gradient background
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.15), Color.blue.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "clock")
                        .font(.system(size: 20))
                        .foregroundColor(Color.blue.opacity(0.8))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total work today \(String(format: "%.1f", totalHours)) hours")
                        .font(.custom("Inter-Regular", size: 22))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .tracking(-0.5)
                    
                    Text("Daily summary across all sessions")
                        .font(.custom("Inter-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            // Right side: Time display
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(String(format: "%.1f", totalHours))h")
                    .font(.custom("Inter-Regular", size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.blue.opacity(0.8))
                
                Text("today")
                    .font(.custom("Inter-Regular", size: 11))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.1),
                            Color.indigo.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.blue.opacity(0.35), radius: 15, x: 0, y: 5)
        )
    }
}