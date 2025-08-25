import SwiftUI

struct ScheduledBlock: Identifiable, Codable {
    let id = UUID()
    var name: String
    var isHardMode: Bool
    var starts: Date
    var ends: Date
    
    var timeRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: starts)) - \(formatter.string(from: ends))"
    }

    var blockDuration: Int
}

class ScheduleBlockController: ObservableObject {
    @Published var scheduledBlocks: [ScheduledBlock] = []
    @Published var showingAddBlockForm = false
    
    // Form state
    @Published var newBlockName = ""
    @Published var newBlockStartTime = Date()
    @Published var newBlockEndTime = Date()
    @Published var newBlockIsHardMode = false
    
    init() {
        // Set default times (9 AM to 5 PM)
        let calendar = Calendar.current
        let now = Date()
        newBlockStartTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now) ?? now
        newBlockEndTime = calendar.date(bySettingHour: 17, minute: 0, second: 0, of: now) ?? now
    }
    
    @MainActor
    func showAddBlockForm() {
        resetForm()
        showingAddBlockForm = true
    }
    
    @MainActor
    func hideAddBlockForm() {
        showingAddBlockForm = false
        resetForm()
    }
    
    @MainActor
    func addScheduledBlock() async {
        guard !newBlockName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newBlock = ScheduledBlock(
            name: newBlockName.trimmingCharacters(in: .whitespacesAndNewlines),
            isHardMode: newBlockIsHardMode,
            starts: newBlockStartTime,
            ends: newBlockEndTime,
            blockDuration: Int(newBlockEndTime.timeIntervalSince(newBlockStartTime))
        )
        
        scheduledBlocks.append(newBlock)
        await BlockerManager.shared.addBlockToDatabase(newBlock)
        await hideAddBlockForm()
        await BlockerManager.shared.getBlockerTable()

    }

   
    func removeScheduledBlock(_ block: ScheduledBlock) {
        scheduledBlocks.removeAll { $0.id == block.id }
    }
    
    @MainActor
    private func resetForm() {
        newBlockName = ""
        newBlockIsHardMode = false
        let calendar = Calendar.current
        let now = Date()
        newBlockStartTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now) ?? now
        newBlockEndTime = calendar.date(bySettingHour: 17, minute: 0, second: 0, of: now) ?? now
    }
}
