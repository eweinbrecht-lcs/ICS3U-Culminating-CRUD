import Foundation
import SwiftUI

// MARK: - GameState
enum GameState {
    case waitingToServe
    case inPlay
    case pointScored
    case gameOver
}

// MARK: - GameViewModel
@Observable
class GameViewModel {
    // MARK: - Stored properties
    var players: [Player] = []
    var shooterBall: Ball
    var objectBall: Ball
    var gameState: GameState = .waitingToServe
    var tableSize: CGSize = CGSize(width: 300, height: 600)
    
    // MARK: - Initializer
    init() {
        // Default balls
        self.shooterBall = Ball(type: .shooter, position: CGPoint(x: 150, y: 550))
        self.objectBall = Ball(type: .object, position: CGPoint(x: 150, y: 100))
        
        // Initial players for testing
        self.players = [
            Player(name: "Player 1"),
            Player(name: "Player 2")
        ]
        self.players[0].isActive = true
    }
    
    // MARK: - Functions
    func resetTable() {
        shooterBall.position = CGPoint(x: tableSize.width / 2, y: tableSize.height * 0.9)
        shooterBall.velocity = .zero
        
        objectBall.position = CGPoint(x: tableSize.width / 2, y: tableSize.height * 0.1)
        objectBall.velocity = .zero
        
        gameState = .waitingToServe
    }
    
    func updatePhysics() {
        // Placeholder for physics logic (movement, friction, collisions)
    }
    
    func addPlayer(name: String) {
        let newPlayer = Player(name: name)
        players.append(newPlayer)
    }
    
    func deletePlayer(at offsets: IndexSet) {
        players.remove(atOffsets: offsets)
    }
}
