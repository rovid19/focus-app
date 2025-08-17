import SwiftUI

struct BlockerState: Codable {
    var remainingTime: Int
    var isRunning: Bool
    var hardLocked: Bool
}

struct FocusSessionState: Codable {
    var timerMinutes: Int
    var isTimerRunning: Bool
    var isHardMode: Bool
    var initialTimerMinutes: Int
}


final class AppStateManager {
    static let shared = AppStateManager()   // singleton
    
    private let blockerKey = "blockerState"
    private let focusKey = "focusSessionState"
    private let defaults = UserDefaults.standard
    
    private init() {} // prevent creating other instances
    
    // Save
    func saveBlockerState(_ state: BlockerState) {
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: blockerKey)
            print("BlockerState saved: \(state)")
        }

      
    }
    
    func saveFocusState(_ state: FocusSessionState) {
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: focusKey)
            print("FocusState saved: \(state)")
        }
    }
    
    // Load
    func loadBlockerState() -> BlockerState? {
        guard let data = defaults.data(forKey: blockerKey) else { return nil }
        return try? JSONDecoder().decode(BlockerState.self, from: data)
    }
    
    func loadFocusState() -> FocusSessionState? {
        guard let data = defaults.data(forKey: focusKey) else { return nil }
        return try? JSONDecoder().decode(FocusSessionState.self, from: data)
    }
}

