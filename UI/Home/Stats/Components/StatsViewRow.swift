import SwiftUI

struct StatRowView: View {
    let stat: Stat
    let statsManager: StatisticsManager
    @State private var showingDeleteConfirmation = false
    @State private var isEditing = false
    @State private var newTitle = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
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
                                // Focus the text field when it appears
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
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(stat.time_elapsed)")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.blue)

                Text("minutes")
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.secondary)
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
        .defaultBackgroundStyle()
        .overlay(
            Group {
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
                    .transition(.opacity.combined(with: .scale))
                }
            }
        )
        .animation(.easeInOut(duration: 0.2), value: showingDeleteConfirmation)
        .animation(.easeInOut(duration: 0.2), value: isEditing)
    }
}