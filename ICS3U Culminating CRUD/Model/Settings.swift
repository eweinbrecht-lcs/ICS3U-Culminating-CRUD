import Foundation

// MARK: - Difficulty
// An enum to represent the different challenge levels.
enum Difficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var id: String { self.rawValue }
}

// MARK: - Settings
// This model manages the user's preferences and persists them using UserDefaults.
@Observable
class Settings {
    // MARK: - Stored properties
    
    var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: "isSoundEnabled")
        }
    }
    
    var isMusicEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isMusicEnabled, forKey: "isMusicEnabled")
        }
    }
    
    var difficulty: Difficulty {
        didSet {
            UserDefaults.standard.set(difficulty.rawValue, forKey: "difficulty")
        }
    }
    
    // MARK: - Initializer
    
    init() {
        // READ: Load values from UserDefaults, or use defaults if they don't exist.
        self.isSoundEnabled = UserDefaults.standard.object(forKey: "isSoundEnabled") as? Bool ?? true
        self.isMusicEnabled = UserDefaults.standard.object(forKey: "isMusicEnabled") as? Bool ?? true
        
        let savedDifficulty = UserDefaults.standard.string(forKey: "difficulty") ?? "Medium"
        self.difficulty = Difficulty(rawValue: savedDifficulty) ?? .medium
    }
    
    // MARK: - Functions
    
    // DELETE (Reset): Resets settings to their default values.
    func resetToDefaults() {
        isSoundEnabled = true
        isMusicEnabled = true
        difficulty = .medium
    }
}
