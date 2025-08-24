import SwiftUI

struct StatRowView: View {
    let stat: Stat
    @EnvironmentObject var statsManager: StatisticsManager
    @State private var showingDeleteConfirmation = false
    @State private var isEditing = false
    @State private var newTitle = ""
    @FocusState private var isTextFieldFocused: Bool
  

    var body: some View {
        ZStack {
            // Normal row content
            if !showingDeleteConfirmation {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            if isEditing {
                                // Edit mode - show text field
                                TextField("Title", text: $newTitle)
                                    .font(.custom("Inter-Regular", size: 16))
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .focused($isTextFieldFocused)
                                    .onSubmit {
                                        Task {
                                            await statsManager.renameStat(stat: stat, newTitle: newTitle)
                                            await statsManager.getStatsFromDatabase()
                                            isEditing = false
                                            isTextFieldFocused = false
                                        }
                                    }
                                    .onAppear {
                                        newTitle = stat.title
                                        DispatchQueue.main.async {
                                            isTextFieldFocused = true
                                        }
                                    }
                            } else {
                                // View mode - show title
                                Text(stat.title)
                                    .font(.custom("Inter-Regular", size: 16))
                            }
                        }

                        if let date = stat.createdAt {
                            Text(date, style: .date)
                                .font(.custom("Inter-Regular", size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(displayTime(stat.time_elapsed))")
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(.blue)
                    }

                    // Three-dot menu button
                    Menu {
                        Button(action: {
                            isEditing = true
                        }) {
                            Label("Rename", systemImage: "pencil")
                        }

                        Button(action: {
                            showingDeleteConfirmation = true
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.leading, 8)
                }
                .padding()
                .glassBackground()
                .transition(.move(edge: .leading))
            }

            // Confirmation dialog replaces the row
            if showingDeleteConfirmation {
                ConfirmationDialog.delete(
                    itemName: "statistic"
                ) {
                    // Delete action
                    Task {
                        await statsManager.removeStatFromDatabase(stat: stat)
                        await statsManager.getStatsFromDatabase()
                    }
                    showingDeleteConfirmation = false
                } cancelAction: {
                    showingDeleteConfirmation = false
                }
                .padding()
                .glassBackground()
                .transition(.move(edge: .trailing)) // slides in from right
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingDeleteConfirmation)
        .animation(.easeInOut(duration: 0.2), value: isEditing)
    }

    private func getTimeUnit(_ seconds: Int) -> String {
        if seconds < 3600 {
            return "minutes"
        } else {
            return "hours"
        }
    }

    private func displayTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 {
            if minutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(minutes)m"
            }
        } else {
            return "\(minutes)m"
        }
    }
}
