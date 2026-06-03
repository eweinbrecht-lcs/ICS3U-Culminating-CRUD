import Foundation
import SwiftUI

// MARK: - AppState
// Tracks which screen the user is currently looking at.
enum AppScreen {
    case menu
    case game
    case shop
    case settings
    case howToPlay
}

// Tracks the type of game being played.
enum GameMode {
    case ai
    case local
}

// MARK: - GameState
// Tracks the different phases of the game so the UI can change what it shows.
enum GameState {
    case waitingToServe // Game hasn't started yet
    case inPlay         // Balls are moving
    case pointScored    // Someone lost a life
    case gameOver       // Someone ran out of lives
}

// MARK: - GameViewModel
// This is the "Brain" of the application. It handles all the rules and math.
@Observable
class GameViewModel {
    // MARK: - Stored properties
    
    // NAVIGATION: Tracks the current screen.
    var currentScreen: AppScreen = .menu
    
    // NAVIGATION: Tracks the selected game mode.
    var gameMode: GameMode = .local
    
    // ARRAY: This stores all the players in the game.
    var players: [Player] = []
    
    // The two balls used in Crud.
    var shooterBall: Ball
    var objectBall: Ball
    
    // The current phase of the game.
    var gameState: GameState = .waitingToServe
    
    // The size of our virtual pool table.
    var tableSize: CGSize = CGSize(width: 300, height: 600)
    
    // AI: Tracks if the computer is currently "thinking" to avoid double shots.
    var isAiThinking: Bool = false
    
    // MARK: - Initializer
    
    init() {
        // Initialize the balls at their starting positions.
        self.shooterBall = Ball(type: .shooter, position: CGPoint(x: 150, y: 550))
        self.objectBall = Ball(type: .object, position: CGPoint(x: 150, y: 100))
        
        // Setup initial players for local mode.
        setupPlayers(for: .local)
    }
    
    // MARK: - Functions
    
    /// Sets up the player array based on the chosen game mode.
    /// - Parameter mode: INPUT: Either .ai or .local
    func setupPlayers(for mode: GameMode) {
        self.gameMode = mode
        if mode == .ai {
            self.players = [
                Player(name: "You"),
                Player(name: "CPU")
            ]
        } else {
            self.players = [
                Player(name: "Player 1"),
                Player(name: "Player 2")
            ]
        }
        self.players[0].isActive = true
        resetTable()
    }
    
    /// Resets the balls to their starting spots and clears their speed.
    func resetTable() {
        shooterBall.position = CGPoint(x: tableSize.width / 2, y: tableSize.height * 0.9)
        shooterBall.velocity = .zero
        
        objectBall.position = CGPoint(x: tableSize.width / 2, y: tableSize.height * 0.1)
        objectBall.velocity = .zero
        
        gameState = .waitingToServe
        isAiThinking = false
    }
    
    /// Called when the user drags their finger on the screen.
    /// - Parameter point: INPUT: The new (x, y) coordinate where the finger is.
    func dragBall(to point: CGPoint) {
        // Only allow dragging if it's a human's turn.
        if let activePlayer = players.first(where: { $0.isActive }), activePlayer.name != "CPU" {
            shooterBall.position = point
            shooterBall.velocity = .zero
        }
    }
    
    /// Called when the user releases their finger (the "Flick").
    /// - Parameter velocity: INPUT: How fast and in what direction the flick happened.
    func shootBall(with velocity: CGVector) {
        shooterBall.velocity = velocity
        gameState = .inPlay
    }
    
    /// This function is called 60 times per second by the View's Timeline.
    func updatePhysics() {
        let friction: CGFloat = 0.985 
        
        updateBallPhysics(shooterBall, friction: friction)
        updateBallPhysics(objectBall, friction: friction)
        
        checkBallCollision()
        
        // AI TURN: If it's the CPU's turn and balls have stopped, trigger the AI shot.
        if gameMode == .ai && players.indices.contains(1) && players[1].isActive {
            if !shooterBall.isMoving && !objectBall.isMoving && !isAiThinking {
                triggerAiShot()
            }
        }
    }
    
    /// AI Logic: Calculates a shot towards the object ball and executes it.
    private func triggerAiShot() {
        isAiThinking = true
        
        // Add a small delay so the CPU doesn't shoot instantly (feels more natural).
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // 1. Calculate direction to the object ball.
            let dx = self.objectBall.position.x - self.shooterBall.position.x
            let dy = self.objectBall.position.y - self.shooterBall.position.y
            
            // 2. Normalize and scale for speed.
            let distance = sqrt(dx*dx + dy*dy)
            let speed: CGFloat = 15.0 // CPU shot power
            
            // 3. Add a bit of "Human Error" so it's not perfect every time.
            let errorX = CGFloat.random(in: -10...10)
            let errorY = CGFloat.random(in: -10...10)
            
            let velocity = CGVector(
                dx: (dx / distance) * speed + errorX,
                dy: (dy / distance) * speed + errorY
            )
            
            // 4. Fire!
            self.shootBall(with: velocity)
            
            // 5. Switch back to player turn (normally handled by game rules, but for now we'll toggle)
            self.toggleActivePlayer()
            self.isAiThinking = false
        }
    }
    
    /// Simple helper to switch turns between players.
    private func toggleActivePlayer() {
        for player in players {
            player.isActive.toggle()
        }
    }
    
    /// Updates a single ball's position based on its speed and handles wall bounces.
    private func updateBallPhysics(_ ball: Ball, friction: CGFloat) {
        ball.position.x += ball.velocity.dx
        ball.position.y += ball.velocity.dy
        
        ball.velocity.dx *= friction
        ball.velocity.dy *= friction
        
        if abs(ball.velocity.dx) < 0.1 { ball.velocity.dx = 0 }
        if abs(ball.velocity.dy) < 0.1 { ball.velocity.dy = 0 }
        
        if ball.position.x - ball.radius <= 0 {
            ball.position.x = ball.radius
            ball.velocity.dx *= -0.8
        } else if ball.position.x + ball.radius >= tableSize.width {
            ball.position.x = tableSize.width - ball.radius
            ball.velocity.dx *= -0.8
        }
        
        if ball.position.y - ball.radius <= 0 {
            ball.position.y = ball.radius
            ball.velocity.dy *= -0.8
        } else if ball.position.y + ball.radius >= tableSize.height {
            ball.position.y = tableSize.height - ball.radius
            ball.velocity.dy *= -0.8
        }
    }
    
    /// Uses geometry to see if balls are overlapping, then bounces them.
    private func checkBallCollision() {
        // Pythagorean theorem to find the distance between ball centers.
        let dx = objectBall.position.x - shooterBall.position.x
        let dy = objectBall.position.y - shooterBall.position.y
        let distance = sqrt(dx*dx + dy*dy)
        let minDistance = shooterBall.radius + objectBall.radius
        
        // If distance is less than the sum of radii, they are touching!
        if distance < minDistance {
            // TRANSFER ENERGY: In this simple version, we swap their speeds.
            let tempVelocity = shooterBall.velocity
            shooterBall.velocity = objectBall.velocity
            objectBall.velocity = tempVelocity
            
            // PREVENT STICKING: Push them apart so they don't get stuck inside each other.
            let overlap = minDistance - distance
            let nx = dx / distance // Normal vector x
            let ny = dy / distance // Normal vector y
            shooterBall.position.x -= nx * overlap / 2
            shooterBall.position.y -= ny * overlap / 2
            objectBall.position.x += nx * overlap / 2
            objectBall.position.y += ny * overlap / 2
        }
    }
    
    // MARK: - CRUD Functions
    
    /// Adds a new player to our array.
    /// - Parameter name: The name of the new player.
    func addPlayer(name: String) {
        let newPlayer = Player(name: name)
        players.append(newPlayer) // ARRAY: Adding to the end of the list.
    }
    
    /// Removes a player from the array.
    /// - Parameter offsets: The position(s) in the list to remove.
    func deletePlayer(at offsets: IndexSet) {
        players.remove(atOffsets: offsets) // ARRAY: Removing from the list.
    }
}
