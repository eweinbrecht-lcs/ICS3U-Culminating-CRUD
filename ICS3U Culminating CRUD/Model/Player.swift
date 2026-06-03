import Foundation

// MARK: - Player
// This model represents a person playing the game. 
// It uses @Observable so that the View updates automatically when lives or names change.
@Observable
class Player: Identifiable {
    // MARK: - Stored properties
    
    // Each player needs a unique ID so SwiftUI can track them in a List or ForEach loop.
    let id: UUID = UUID()
    
    // The player's display name.
    var name: String
    
    // The player starts with 3 lives. If they hit 0, they are out!
    var lives: Int = 3
    
    // This Boolean (True/False) tracks if it is currently this player's turn to shoot.
    var isActive: Bool = false
    
    // MARK: - Initializer
    
    /// Creates a new player with a name.
    /// - Parameter name: The string name of the player (e.g., "Ethan").
    init(name: String) {
        self.name = name
    }
}
