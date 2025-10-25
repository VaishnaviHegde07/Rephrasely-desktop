import Foundation

/// Manages persistent storage of text transformation history
class HistoryManager {
    static let shared = HistoryManager()
    
    private let userDefaults = UserDefaults.standard
    private let historyKey = "text_transformation_history"
    private let maxHistoryItems = 1000 // Keep last 1000 transformations
    
    private init() {}
    
    /// Save a transformation to history
    func saveTransformation(
        hotkeyId: String,
        hotkeyName: String,
        originalText: String,
        transformedText: String,
        modelName: String,
        actionType: String
    ) {
        let entry = HistoryEntry(
            id: UUID().uuidString,
            hotkeyId: hotkeyId,
            hotkeyName: hotkeyName,
            originalText: originalText,
            transformedText: transformedText,
            modelName: modelName,
            actionType: actionType,
            timestamp: Date()
        )
        
        var history = loadHistory()
        history.insert(entry, at: 0) // Add to beginning (most recent first)
        
        // Trim history if it exceeds max items
        if history.count > maxHistoryItems {
            history = Array(history.prefix(maxHistoryItems))
        }
        
        saveHistory(history)
        print("💾 HistoryManager: Saved transformation '\(hotkeyName)'")
    }
    
    /// Load all history entries
    func loadHistory() -> [HistoryEntry] {
        guard let data = userDefaults.data(forKey: historyKey) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let history = try decoder.decode([HistoryEntry].self, from: data)
            return history
        } catch {
            print("❌ HistoryManager: Failed to decode history - \(error)")
            return []
        }
    }
    
    /// Save history to UserDefaults
    private func saveHistory(_ history: [HistoryEntry]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(history)
            userDefaults.set(data, forKey: historyKey)
            print("💾 HistoryManager: Saved \(history.count) entries")
        } catch {
            print("❌ HistoryManager: Failed to encode history - \(error)")
        }
    }
    
    /// Clear all history
    func clearHistory() {
        userDefaults.removeObject(forKey: historyKey)
        print("🗑️ HistoryManager: Cleared all history")
    }
    
    /// Delete a specific history entry
    func deleteEntry(id: String) {
        var history = loadHistory()
        history.removeAll { $0.id == id }
        saveHistory(history)
        print("🗑️ HistoryManager: Deleted entry \(id)")
    }
    
    /// Get history grouped by date
    func getHistoryGroupedByDate() -> [String: [HistoryEntry]] {
        let history = loadHistory()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        var grouped: [String: [HistoryEntry]] = [:]
        
        for entry in history {
            let dateKey = dateFormatter.string(from: entry.timestamp)
            if grouped[dateKey] == nil {
                grouped[dateKey] = []
            }
            grouped[dateKey]?.append(entry)
        }
        
        return grouped
    }
}

/// Represents a single text transformation in history
struct HistoryEntry: Codable, Identifiable {
    let id: String
    let hotkeyId: String
    let hotkeyName: String
    let originalText: String
    let transformedText: String
    let modelName: String
    let actionType: String
    let timestamp: Date
}

