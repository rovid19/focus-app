import SwiftUI

struct SummaryImageView: View {
    @ObservedObject var controller: SocialMediaShareController
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Focus Summary")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button("Close") {
                    dismiss()
                }
            }
            .padding()

            // Shareable Image Preview
            if let summary = controller.todaySummary {
                ShareableImageView(summary: summary)
                    .frame(width: 600, height: 800)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding()
            } else {
                Text("No summary available")
                    .foregroundColor(.secondary)
                    .padding()
            }

            Spacer()
        }
        .frame(width: 700, height: 900)
    }
}

struct ShareableImageView: View {
    let summary: TodaySummary

    var body: some View {
        ZStack {
            BackgroundGradient()

            ShareCard(summary: summary)
                .padding(24)
        }
        .frame(width: 600, height: 800)
        .cornerRadius(24)
    }
}

// MARK: - Backgrounds

struct BackgroundGradient: View {
    var body: some View {
        // Stoic black background with subtle radial highlights
        ZStack {
            Color.black

            // Subtle radial gradients for depth
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.06),
                    Color.clear,
                ]),
                center: UnitPoint(x: 0.5, y: 0),
                startRadius: 0,
                endRadius: 400
            )

            RadialGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.04),
                    Color.clear,
                ]),
                center: UnitPoint(x: 1, y: 1),
                startRadius: 0,
                endRadius: 300
            )

            RadialGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.035),
                    Color.clear,
                ]),
                center: UnitPoint(x: 0, y: 1),
                startRadius: 0,
                endRadius: 250
            )
        }
    }
}

// MARK: - Share Card

struct ShareCard: View {
    let summary: TodaySummary

    var body: some View {
        VStack(spacing: 24) {
            CardHeader(date: summary.date)

            HeroStats(summary: summary)

            DividerLine()

            ContentSection(summary: summary)
        }
        .padding(40)
        /* .background(
             LinearGradient(
                 gradient: Gradient(stops: [
                     .init(color: Color.white.opacity(0.1), location: 0),
                     .init(color: Color.white.opacity(0.05), location: 0.5),
                     .init(color: Color.white.opacity(0), location: 1)
                 ]),
                 startPoint: .top,
                 endPoint: .bottom
             ),
             in: RoundedRectangle(cornerRadius: 24)
         )
         .overlay(
             RoundedRectangle(cornerRadius: 24)
                 .stroke(Color.white.opacity(0.1), lineWidth: 1)
         ) */
    }
}

// MARK: - Card Pieces

struct CardHeader: View {
    let date: String

    var body: some View {
        HStack {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(date)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            Spacer()

            HStack(spacing: 8) {
                Image(systemName: "qrcode")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                Text("focusapp.io")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

struct HeroStats: View {
    let summary: TodaySummary

    var body: some View {
        HStack(spacing: 16) {
            ModernStatCard(
                icon: "clock",
                label: "Total\nFocus Time",
                value: summary.totalHours,
                subtitle: "Great pace today—keep the momentum."
            )

            ModernStatCard(
                icon: "flame",
                label: "Focus Sessions",
                value: "\(summary.totalSessions)",
                subtitle: summary.totalSessions > 0 ?
                    "Avg session \(summary.totalFocusTime / max(summary.totalSessions, 1) / 60)m"
                    : "No sessions yet",
            )

            ModernStatCard(
                icon: "flame",
                label: "Current Streak",
                value: "5 days",
                subtitle: "You're on fire—don't break it."
            )
        }
    }
}

struct DividerLine: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(height: 1)
    }
}

struct ContentSection: View {
    let summary: TodaySummary

    var body: some View {
        SessionsList(sessionNames: summary.sessionNames)
    }
}

// MARK: - Subviews

struct ModernStatCard: View {
    let icon: String
    let label: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                        .textCase(.uppercase)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil) // <- allow wrapping, no "..."
                        .fixedSize(horizontal: false, vertical: true)

                    Text(value)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
            }

            Text(subtitle)
                .font(.system(size:11))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(width: 100, height: 100)
        .padding(20)
        .background(Color.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}

struct SessionRow: View {
    let color: Color
    let name: String
    let duration: String

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)

                Text(duration)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct SessionsList: View {
    let sessionNames: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sessions Completed")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Text("Today's highlights")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }

            VStack(spacing: 12) {
                if sessionNames.isEmpty {
                    SessionRow(
                        color: .gray,
                        name: "No sessions yet",
                        duration: "Start your first session!",
                    )
                } else {
                    let colors: [Color] = [.white, .white, .white, .white, .white]
                    ForEach(Array(sessionNames.prefix(4).enumerated()), id: \.offset) { index, name in
                        SessionRow(
                            color: colors[index % colors.count],
                            name: name,
                            duration: "\(Int.random(in: 15 ... 60))m",
                        )
                    }

                    if sessionNames.count > 4 {
                        Text("+ \(sessionNames.count - 4) more sessions")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.leading, 20)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
