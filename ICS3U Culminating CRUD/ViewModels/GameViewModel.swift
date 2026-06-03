import Foundation
import SwiftUI

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
    
    // ARRAY: This stores all the players in the game.
    // It's a collection of 'Player' objects.
    var players: [Player] = []
    
    // The two balls used in Crud.
    var shooterBall: Ball
    var objectBall: Ball
    
    // The current phase of the game.
    var gameState: GameState = .waitingToServe
    
    // The size of our virtual pool table.
    var tableSize: CGSize = CGSize(width: 300, height: 600)
    
    // MARK: - Initializer
    
    init() {
        // Initialize the balls at their starting positions.
        self.shooterBall = Ball(type: .shooter, position: CGPoint(x: 150, y: 550))
        self.objectBall = Ball(type: .object, position: CGPoint(x: 150, y: 100))
        
        // Add two default players to the 'players' array so we have someone to play.
        self.players = [
            Player(name: "Player 1"),
            Player(name: "Player 2")
        ]
        
        // Set the first player in the array as the active one.
        self.players[0].isActive = true
    }
    
    // MARK: - Functions
    
    /// Resets the balls to their starting spots and clears their speed.
    func resetTable() {
        shooterBall.position = CGPoint(x: tableSize.width / 2, y: tableSize.height * 0.9)
        shooterBall.velocity = .zero
        
        objectBall.position = CGPoint(x: tableSize.width / 2, y: tableSize.height * 0.1)
        objectBall.velocity = .zero
        
        gameState = .waitingToServe
    }
    
    /// Called when the user drags their finger on the screen.
    /// - Parameter point: The new (x, y) coordinate where the finger is.
    func dragBall(to point: CGPoint) {
        // When dragging, we snap the shooter ball directly to the finger's position.
        shooterBall.position = point
        shooterBall.velocity = .zero // Stop it from rolling while held.
    }
    
    /// Called when the user releases their finger (the "Flick").
    /// - Parameter velocity: How fast and in what direction the flick happened.
    func shootBall(with velocity: CGVector) {
        shooterBall.velocity = velocity
        gameState = .inPlay
    }
    
    /// This function is called 60 times per second by the View's Timeline.
    /// It updates the position of all moving objects.
    func updatePhysics() {
        // Friction: We multiply velocity by 0.985 each frame to slow it down (air/cloth resistance).
        let friction: CGFloat = 0.985 
        
        // Update both balls.
        updateBallPhysics(shooterBall, friction: friction)
        updateBallPhysics(objectBall, friction: friction)
        
        // Check if the two balls hit each other.
        checkBallCollision()
    }
    
    /// Updates a single ball's position based on its speed and handles wall bounces.
    /// - Parameters:
    ///   - ball: The ball object to update.
    ///   - friction: The multiplier to slow it down.
    private func updateBallPhysics(_ ball: Ball, friction: CGFloat) {
        // 1. Move the ball: New Position = Old Position + Speed
        ball.position.x += ball.velocity.dx
        ball.position.y += ball.velocity.dy
        
        // 2. Apply Friction: Speed = Old Speed * 0.985
        ball.velocity.dx *= friction
        ball.velocity.dy *= friction
        
        // 3. Stop if too slow: If it's barely moving, just set it to zero.
        if abs(ball.velocity.dx) < 0.1 { ball.velocity.dx = 0 }
        if abs(ball.velocity.dy) < 0.1 { ball.velocity.dy = 0 }
        
        // 4. Wall collisions (Bouncing)
        // Check Left and Right walls
        if ball.position.x - ball.radius <= 0 {
            ball.position.x = ball.radius // Keep it inside the wall
            ball.velocity.dx *= -0.8      // Flip direction and lose 20% speed
        } else if ball.position.x + ball.radius >= tableSize.width {
            ball.position.x = tableSize.width - ball.radius
            ball.velocity.dx *= -0.8
        }
        
        // Check Top and Bottom walls
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
