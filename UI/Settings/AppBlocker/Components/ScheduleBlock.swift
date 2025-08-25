import SwiftUI

struct ScheduleBlock: View {
    @StateObject private var controller = ScheduleBlockController()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with Add Button
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Scheduled Blocks")
                        .font(.custom("Inter-Medium", size: 16))
                        .foregroundColor(.white)

                    Text("Set time-based blocking schedules")
                        .font(.custom("Inter-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                Button(action: {
                    controller.showAddBlockForm()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.custom("Inter-Regular", size: 12))
                        Text("Add Block")
                            .font(.custom("Inter-Regular", size: 12))
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .settingsButton(opacity: 0)
                }
                .buttonStyle(PlainButtonStyle())
            }

            // Blocks List
            if controller.scheduledBlocks.isEmpty {
                EmptyScheduleView()
            } else {
                VStack(spacing: 8) {
                    ForEach(controller.scheduledBlocks) { block in
                        ScheduledBlockRow(block: block, controller: controller)
                    }
                }
            }
        }
        .sheet(isPresented: $controller.showingAddBlockForm) {
            AddScheduleBlockForm(controller: controller)
        }
    }
}

// MARK: - Empty State

private struct EmptyScheduleView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 24))
                .foregroundColor(.white.opacity(0.4))

            Text("No scheduled blocks")
                .font(.custom("Inter-Regular", size: 14))
                .foregroundColor(.white.opacity(0.6))

            Text("Add your first scheduled block to automatically enable blocking during specific times")
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .settingsBackground(opacity: 0.05)
    }
}

// MARK: - Scheduled Block Row

struct ScheduledBlockRow: View {
    let block: ScheduledBlock
    let controller: ScheduleBlockController
    @State private var showingDeleteConfirmation = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(block.name)
                        .font(.custom("Inter-Medium", size: 14))
                        .foregroundColor(.white)

                    if block.isHardMode {
                        Text("HARD")
                            .font(.custom("Inter-Regular", size: 10))
                            .foregroundColor(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.red.opacity(0.2))
                            )
                    }
                }

                Text(block.timeRange)
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            Button(action: {
                showingDeleteConfirmation = true
            }) {
                Image(systemName: "trash")
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
            }
            .settingsButton(opacity: 0)
        }
        .padding(12)
        .settingsBackground()
        .alert("Delete Schedule Block", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                controller.removeScheduledBlock(block)
            }
        } message: {
            Text("Are you sure you want to delete '\(block.name)'?")
        }
    }
}

// MARK: - Add Block Form

struct AddScheduleBlockForm: View {
    @ObservedObject var controller: ScheduleBlockController

    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Text("Add Scheduled Block")
                    .font(.custom("Inter-Medium", size: 18))
                    .foregroundColor(.white)

                Spacer()

                Button(action: {
                    controller.hideAddBlockForm()
                }) {
                    Text("Cancel")
                        .font(.custom("Inter-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                }
                .settingsButton()
            }

            // Form
            VStack(alignment: .leading, spacing: 16) {
                // Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Block Name")
                        .font(.custom("Inter-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.7))

                    TextField("Work hours, Study time, etc.", text: $controller.newBlockName)
                        .font(.custom("Inter-Regular", size: 14))
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .settingsBackground(opacity: 0.05)
                        .foregroundColor(.white)
                }

                // Time Range
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Start Time")
                            .font(.custom("Inter-Regular", size: 12))
                            .foregroundColor(.white.opacity(0.7))

                        DatePicker("", selection: $controller.newBlockStartTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .glassBackground(cornerRadius: 8)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("End Time")
                            .font(.custom("Inter-Regular", size: 12))
                            .foregroundColor(.white.opacity(0.7))

                        DatePicker("", selection: $controller.newBlockEndTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .glassBackground(cornerRadius: 8)
                    }
                }

                // Hard Mode Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hard Mode")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(.white)

                        Text("Cannot be stopped once started")
                            .font(.custom("Inter-Regular", size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }

                    Spacer()

                    Toggle("", isOn: $controller.newBlockIsHardMode)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle())
                }
            }

            Spacer()

            // Save Button
            Button(action: {
                Task { @MainActor in
                    await controller.addScheduledBlock()
                }
            }) {
                Text("Add Block")
                    .font(.custom("Inter-Medium", size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .disabled(controller.newBlockName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(controller.newBlockName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
            .settingsButton(opacity: 0.1)
        }
        .padding(36)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5))
        .foregroundColor(.white)
    }
}
