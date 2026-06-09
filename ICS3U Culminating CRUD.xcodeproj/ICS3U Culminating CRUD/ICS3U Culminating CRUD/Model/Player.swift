import Foundation

// MARK: - Player
// This 'Model' class represents a single player (either Human or CPU).
// EXAM TIP: This is part of our central 'players' array, which is an 'Initialization Array'.
@Observable
class Player: Identifiable {
    // MARK: - Stored properties
    
    // id: A unique identifier for each player. 
    // This is required so SwiftUI can tell 'Player 1' apart from 'Player 2' in a loop.
    let id: UUID = UUID()
    
    // name: The string (text) that appears in the HUD (e.g., "Player 1" or "CPU").
    var name: String
    
    // lives: An Integer tracking how many turns the player has left.
    // Every time they miss or pocket the wrong ball, we decrease this by 1.
    var lives: Int = 3
    
    // isActive: A Boolean (True/False) that tells the program if it's currently this person's turn.
    // If true, the UI will highlight their name in yellow.
    var isActive: Bool = false
    
    // MARK: - Initializer
    
    // This function runs when we first create a player (e.g., 'Player(name: "Ethan")').
    init(name: String) {
        self.name = name
    }
}
