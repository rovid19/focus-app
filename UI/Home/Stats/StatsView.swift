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
                content
            }
        }
        .onAppear { animateElements() }
        .onChange(of: statsManager.stats) { _ in animateElements() }
        .onChange(of: controller.selectedDate) { _ in animateElements() }
    }

    // MARK: - Content
    @ViewBuilder
    private var content: some View {
        if statsManager.stats.isEmpty {
            EmptyStatsView()
                .opacity(emptyViewVisible ? 1 : 0)
                .offset(y: emptyViewVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.6), value: emptyViewVisible)
        } else {
            StatsListSection(
                controller: controller,
                statsListVisible: statsListVisible
            )
        }
    }

    // MARK: - Animations
    private func animateElements() {
        withAnimation(.easeOut(duration: 0.3)) {
            summaryVisible = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.3)) {
                if statsManager.stats.isEmpty {
                    emptyViewVisible = true
                } else {
                    let filtered = controller.getStatsForSelectedDate(from: statsManager.statsSortedByDate)
                    if filtered.isEmpty {
                        emptyViewVisible = true
                    } else {
                        statsListVisible = true
                    }
                }
            }
        }
    }
}

// MARK: - Stats List Section
struct StatsListSection: View {
    @ObservedObject var controller: StatsController
    @EnvironmentObject var statsManager: StatisticsManager
    let statsListVisible: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            StatsHeader(controller: controller)

            let filteredStats = controller.getStatsForSelectedDate(from: statsManager.statsSortedByDate)

            if filteredStats.isEmpty {
                NoStatsView(selectedDate: controller.selectedDate)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredStats, id: \.id) { stat in
                            StatRowView(stat: stat)   // ✅ no statsManager passed
                        }
                    }
                    .onAppear {
                        print("filteredStats", filteredStats)
                    }
                }
            }
        }
        .opacity(statsListVisible ? 1 : 0)
        .offset(y: statsListVisible ? 0 : 20)
        .animation(.easeOut(duration: 0.6), value: statsListVisible)
    }
}

// MARK: - Header
private struct StatsHeader: View {
    @ObservedObject var controller: StatsController

    var body: some View {
        HStack {
            Text("Focus sessions:")
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.white.opacity(0.55))

            Spacer()

            Button(action: { controller.toggleCalendar() }) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.custom("Inter-Regular", size: 10))
                    Text(formatDate(controller.selectedDate))
                        .font(.custom("Inter-Regular", size: 10))
                }
            }
            .popover(isPresented: $controller.showingCalendar) {
                DatePicker("", selection: $controller.selectedDate, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding(12)
                    .textFieldStyle(PlainTextFieldStyle()) // hides focus ring on macOS
            }
        }
        .padding(.leading, 4)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - No Stats View
private struct NoStatsView: View {
    let selectedDate: Date

    var body: some View {
        VStack(spacing: 4) {
            Text("No focus sessions on \(formatDate(selectedDate))")
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .glassBackground()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Empty Stats View
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
        .glassBackground()
    }
}
