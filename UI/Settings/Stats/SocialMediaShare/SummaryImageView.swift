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
    let summary: SocialMediaSummary

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
        ZStack {
            Color.black
            RadialGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.06), Color.clear]),
                center: UnitPoint(x: 0.5, y: 0),
                startRadius: 0,
                endRadius: 400
            )
            RadialGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.04), Color.clear]),
                center: UnitPoint(x: 1, y: 1),
                startRadius: 0,
                endRadius: 300
            )
            RadialGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.035), Color.clear]),
                center: UnitPoint(x: 0, y: 1),
                startRadius: 0,
                endRadius: 250
            )
        }
    }
}

// MARK: - Share Card

struct ShareCard: View {
    let summary: SocialMediaSummary

    var body: some View {
        VStack(spacing: 24) {
            CardHeader(date: formattedDate(summary.currentDate))
            HeroStats(summary: summary)
            DividerLine()
            ContentSection(summary: summary)
        }
        .padding(40)
    }

    private func formattedDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d, yyyy"
        return fmt.string(from: date)
    }
}

// MARK: - Card Pieces

struct CardHeader: View {
    let date: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(date)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
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
    let summary: SocialMediaSummary

    var body: some View {
        HStack(spacing: 16) {
            ModernStatCard(
                icon: "clock",
                label: "Focus \nTime",
                value: summary.focusTime,
            )

            ModernStatCard(
                icon: "flame",
                label: "Focus \nSessions",
                value: "\(summary.focusSessions.count) \nSessions",
            )

            ModernStatCard(
                icon: "flame",
                label: "Current \nStreak",
                value: summary.currentStreak > 1 ? "\(summary.currentStreak) \ndays" : "\(summary.currentStreak) day",
            )
        }
    }

    private func averageSessionLength(_ sessions: [FocusSession]) -> String {
        let totalSeconds = sessions.map { $0.time_elapsed }.reduce(0, +)
        guard !sessions.isEmpty else { return "0m" }
        let avgSeconds = totalSeconds / sessions.count
        return "\(avgSeconds / 60)m"
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
    let summary: SocialMediaSummary

    var body: some View {
        SessionsList(sessions: summary.focusSessions)
    }
}

// MARK: - Subviews

struct ModernStatCard: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 6) { // 👈 control spacing here
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
                .textCase(.uppercase)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 100, height: 100)
        .padding(20)
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

        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct SessionsList: View {
    let sessions: [FocusSession]

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
                if sessions.isEmpty {
                    SessionRow(
                        color: .gray,
                        name: "No sessions yet",
                        duration: "Start your first session!"
                    )
                } else {
                    let colors: [Color] = [.white, .white, .white, .white, .white]
                    ForEach(Array(sessions.prefix(4).enumerated()), id: \.offset) { index, session in
                        SessionRow(
                            color: colors[index % colors.count],
                            name: session.title,
                            duration: "\(session.time_elapsed / 60)m"
                        )
                    }

                    if sessions.count > 4 {
                        Text("+ \(sessions.count - 4) more sessions")
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
