import SwiftUI

struct StatsSettingsView: View {
    @ObservedObject var controller: StatsSettingsController
    @State private var summaryVisible = false
    @State private var statsListVisible = false
    @State private var emptyViewVisible = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Summary Section
                VStack(spacing: 12) {
                    SummaryStatSettings(statsManager: statsManager)
                        .opacity(summaryVisible ? 1 : 0)
                        .offset(y: summaryVisible ? 0 : 20)
                        .animation(.easeOut(duration: 0.6), value: summaryVisible)
                }
                
                // Stats Content
                VStack(spacing: 12) {
                    if statsManager.isLoading {
                        SpinnerLoader()
                    } else {
                        if statsManager.stats.isEmpty {
                            EmptyStatsSettingsView()
                                .opacity(emptyViewVisible ? 1 : 0)
                                .offset(y: emptyViewVisible ? 0 : 20)
                                .animation(.easeOut(duration: 0.6), value: emptyViewVisible)
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Focus sessions:")
                                        .font(.custom("Inter-Regular", size: 15))
                                        .fontWeight(.medium)
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    Spacer()
                                    
                                    Text("\(statsManager.stats.count) total")
                                        .font(.custom("Inter-Regular", size: 12))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                
                                LazyVStack(spacing: 8) {
                                    ForEach(statsManager.stats.reversed(), id: \.id) { stat in
                                        StatRowView(stat: stat, statsManager: statsManager)
                                    }
                                }
                            }
                            .opacity(statsListVisible ? 1 : 0)
                            .offset(y: statsListVisible ? 0 : 20)
                            .animation(.easeOut(duration: 0.6), value: statsListVisible)
                        }
                    }
                }
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            animateElements()
        }
        .onChange(of: statsManager.stats) { newStats in
            Task { @MainActor in
                animateElements()
            }
        }
    }
    
    // Access StatisticsManager through HomeController
    private var statsManager: StatisticsManager {
        return StatisticsManager.shared
    }

    private func animateElements() {
        withAnimation(.easeOut(duration: 0.3)) {
            summaryVisible = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.3)) {
                if statsManager.stats.isEmpty {
                    emptyViewVisible = true
                } else {
                    statsListVisible = true
                }
            }
        }
    }
}

private struct EmptyStatsSettingsView: View {
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: "chart.bar")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Text("No focus sessions yet.")
                .font(.custom("Inter-Regular", size: 14))
                .foregroundColor(.white.opacity(0.8))
            
            Text("Complete your first focus session to see detailed statistics.")
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - SummaryStat for Settings (doesn't use EnvironmentObject)
struct SummaryStatSettings: View {
    let statsManager: StatisticsManager
    
    var body: some View {
        let totalSeconds = statsManager.totalSeconds
        let totalHours = statsManager.totalHours

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
                    Text("\(totalHours)")
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
