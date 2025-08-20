import SwiftUI

struct StatsView: View {
    @ObservedObject var controller: StatsController
    @EnvironmentObject var statsManager: StatisticsManager
    @State private var summaryVisible = false
    @State private var statsListVisible = false
    @State private var emptyViewVisible = false

    var body: some View {
        VStack(spacing: 12) {
            SummaryStat()
                .opacity(summaryVisible ? 1 : 0)
                .offset(y: summaryVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.6), value: summaryVisible)

            if statsManager.isLoading {
                SpinnerLoader()
            } else {
                if statsManager.stats.isEmpty {
                    EmptyStatsView()
                        .opacity(emptyViewVisible ? 1 : 0)
                        .offset(y: emptyViewVisible ? 0 : 20)
                        .animation(.easeOut(duration: 0.6), value: emptyViewVisible)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Focus sessions:")
                            .font(.custom("Inter-Regular", size: 12))
                            .foregroundColor(.white.opacity(0.55))
                            .padding(.leading, 4)

                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(statsManager.stats.reversed(), id: \.id) { stat in
                                    StatRowView(stat: stat, statsManager: statsManager)
                                }
                            }
                            // .padding(.horizontal)
                        }
                    }
                    .opacity(statsListVisible ? 1 : 0)
                    .offset(y: statsListVisible ? 0 : 20)
                    .animation(.easeOut(duration: 0.6), value: statsListVisible)
                }
            }
        }
        //.padding(.horizontal, 24)
        //.padding(.vertical, 12)
        .onAppear {
            animateElements()
           
        }
        .onChange(of: statsManager.stats) { newStats in
            Task { @MainActor in
                animateElements()
            }
        }
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

private struct EmptyStatsView: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("Complete your first focus session to see statistics here")
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .defaultBackgroundStyle()
    }
}
