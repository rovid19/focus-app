import SwiftUI

struct StatsView: View {
    @ObservedObject var controller: StatsController
    @StateObject private var statsManager = StatisticsManager.shared

    var body: some View {
       
        VStack(spacing: 12) {
             SummaryStat(totalHours: 10.5, totalMinutes: 630)
            if statsManager.stats.isEmpty {
                EmptyStatsView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(statsManager.stats.reversed(), id: \.id) { stat in
                            StatRowView(stat: stat, statsManager: statsManager)
                        }
                    }
                    //.padding(.horizontal)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .onAppear {
            Task {
                await statsManager.getStatsFromDatabase()
            }
        }
    }
}

private struct EmptyStatsView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "chart.bar.xaxis")
                .font(.custom("Inter-Regular", size: 50))
                .foregroundColor(.gray)

            Text("No Statistics Yet")
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(.secondary)

            Text("Complete your first focus session to see statistics here")
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
