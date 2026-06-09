import Foundation
import SwiftUI

// MARK: - AppState
// This enum defines the different screens available in our app.
enum AppScreen {
    case menu
    case game
    case shop
    case settings
    case howToPlay
    case localMultiplayer
    case aiGame
}

// MARK: - GameMode
// This enum defines whether we are playing against a computer or another person.
enum GameMode {
    case ai
    case local
}

// MARK: - GameState
// This enum tracks the specific phase of the pool match.
enum GameState {
    case waitingToServe // The very start of the match
    case inPlay         // The ball has been hit and is moving
    case gameOver       // A player has won the match
}

@Observable
class GameViewModel {
    // MARK: - Stored properties
    
    // Navigation and Mode
    var currentScreen: AppScreen = .menu
    var gameMode: GameMode = .local
    
    // Players: This is our central array for turn management.
    var players: [Player] = []
    var activePlayerIndex: Int = 0
    
    // Models: These hold the actual data for the game objects.
    var settings: Settings = Settings()
    var shooterBall: Ball
    var objectBall: Ball
    
    // Game Physics and Rules
    var gameState: GameState = .waitingToServe
    var tableSize: CGSize = CGSize(width: 300, height: 600)
    var servingAttempts: Int = 0
    var isAiThinking: Bool = false
    
    // Tracks if the current throw has already hit the object ball
    var hasHitThisThrow: Bool = false
    
    // Slingshot aiming properties
    var isDragging: Bool = false
    var dragStartPoint: CGPoint = .zero
    var currentDragPoint: CGPoint = .zero
    
    // Controls the "Dead Ball" popup visibility
    var showDeadBall: Bool = false
    
    // The winner's name to display on the win screen
    var winnerName: String = ""
    
    // Pocket settings
    let pocketRadius: CGFloat = 25.0
    
    // MARK: - Initializer
    
    init() {
        // We set up the balls with default positions.
        self.shooterBall = Ball(type: .shooter, position: CGPoint(x: 150, y: 500))
        self.objectBall = Ball(type: .object, position: CGPoint(x: 150, y: 150))
        setupPlayers(for: .local)
    }
    
    // MARK: - Functions
    
    /// Prepares the players list based on the selected game mode.
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
        activePlayerIndex = 0
        updateActiveStatus()
        resetTable()
    }
    
    /// Resets only the shooter (cue) ball to its home position.
    func resetShooter() {
        shooterBall.position = CGPoint(x: tableSize.width / 2, y: tableSize.height * 0.8)
        shooterBall.velocity = .zero
        shooterBall.isPocketed = false
        hasHitThisThrow = false
    }
    
    /// Resets the entire table for a brand new serve.
    func resetTable() {
        resetShooter()
        
        objectBall.position = CGPoint(x: tableSize.width / 2, y: tableSize.height * 0.2)
        objectBall.velocity = .zero
        objectBall.isPocketed = false
        
        gameState = .waitingToServe
        servingAttempts = 0
        isAiThinking = false
    }
    
    /// Updates which player is visually marked as "active".
    func updateActiveStatus() {
        for i in 0..<players.count {
            players[i].isActive = (i == activePlayerIndex)
        }
    }
    
    /// Switches the turn to the next player who still has lives.
    func nextTurn() {
        // GRADE 11 RULE: Use a loop instead of .filter to find alive players.
        var aliveCount: Int = 0
        for player in players {
            if player.lives > 0 {
                aliveCount += 1
            }
        }
        
        // If only 1 player is left, the game is over, so don't switch turns.
        if aliveCount <= 1 { return }
        
        // Move to the next index in the array.
        activePlayerIndex = (activePlayerIndex + 1) % players.count
        
        // Keep skipping players until we find one that is still in the game.
        while players[activePlayerIndex].lives <= 0 {
            activePlayerIndex = (activePlayerIndex + 1) % players.count
        }
        
        updateActiveStatus()
    }
    
    /// Removes a life from a player and checks if the game should continue.
    func loseLife(playerIndex: Int) {
        players[playerIndex].lives -= 1
        
        if players[playerIndex].lives <= 0 {
            checkWinner()
        }
        
        // After losing a life, we reset the table for a new serve if the game isn't over.
        if gameState != .gameOver {
            if players[activePlayerIndex].lives <= 0 {
                nextTurn()
            }
            resetTable()
        }
    }
    
    /// Shows the "Dead Ball" alert and penalizes the current player.
    func triggerDeadBall() {
        if showDeadBall { return }
        showDeadBall = true
        
        // The current player loses a life because they failed to hit it before it stopped.
        loseLife(playerIndex: activePlayerIndex)
        
        // Hide the popup after a brief moment.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showDeadBall = false
        }
    }
    
    /// Checks if there is only one player left with lives.
    func checkWinner() {
        // GRADE 11 RULE: Use a loop instead of .filter.
        var alivePlayers: [Player] = []
        for player in players {
            if player.lives > 0 {
                alivePlayers.append(player)
            }
        }
        
        if alivePlayers.count == 1 {
            winnerName = alivePlayers[0].name
            gameState = .gameOver
        }
    }
    
    /// Determines if a ball is in the "serving" zones (top or bottom 20%).
    func isValidShootPosition(_ point: CGPoint) -> Bool {
        let threshold = tableSize.height * 0.2
        return point.y < threshold || point.y > (tableSize.height - threshold)
    }
    
    // MARK: - Drag and Shoot Functions
    
    /// Called when the player first touches the cue ball to start a slingshot throw.
    func startDragging(at point: CGPoint) {
        if gameState == .gameOver || showDeadBall { return }
        if players[activePlayerIndex].name == "CPU" { return }
        
        // Stop the ball when grabbed so the player can aim.
        shooterBall.velocity = .zero
        isDragging = true
        dragStartPoint = shooterBall.position
        currentDragPoint = point
    }
    
    /// Called as the player moves their finger across the screen.
    func dragBall(to point: CGPoint) {
        if !isDragging { return }
        currentDragPoint = point
    }
    
    /// Called when the player releases their finger, launching the ball.
    func releaseBall() {
        if !isDragging { return }
        
        // MATH: We calculate the difference between where they started and ended.
        // Because it's a slingshot, pulling left (negative x) makes the ball go right (positive x).
        let dx = dragStartPoint.x - currentDragPoint.x
        let dy = dragStartPoint.y - currentDragPoint.y
        
        // We multiply by a sensitivity factor to make the throw feel natural.
        let sensitivity: CGFloat = 0.15
        let velocity = CGVector(dx: dx * sensitivity, dy: dy * sensitivity)
        
        shootBall(with: velocity)
        isDragging = false
    }
    
    /// Handles the logic of launching the ball and updating game rules.
    func shootBall(with velocity: CGVector) {
        if gameState == .gameOver || showDeadBall { return }
        
        // Set the ball's velocity to the calculated vector.
        shooterBall.velocity = velocity
        
        // Reset the hit tracker for this specific throw.
        hasHitThisThrow = false
        
        if gameState == .waitingToServe {
            servingAttempts += 1
        }
    }
    
    // MARK: - Physics Updates
    
    /// The main \"loop\" function that moves balls and checks for collisions.
    /// EXAM TIP: This is where all the math and physics happen!
    func updatePhysics() {
        if gameState == .gameOver || showDeadBall { return }
        
        // FRICTION: We multiply velocity by these numbers to make balls slow down over time.
        // MATH: New Velocity = Current Velocity * Friction (e.g., 10 * 0.975 = 9.75)
        // A value of 1.0 would mean no friction (infinite rolling).
        let shooterFriction: CGFloat = 0.975
        let objectFriction: CGFloat = 0.992 // Low friction means the yellow ball slides a long way!
        
        // We update each ball separately.
        updateBallPhysics(shooterBall, friction: shooterFriction)
        updateBallPhysics(objectBall, friction: objectFriction)
        
        // Check for interactions between balls and pockets.
        checkBallCollision()
        checkPockets()
        
        // RULE: Dead Ball (If the ball stops moving while in play).
        // If the balls aren't moving, the game can't progress, so we trigger a penalty.
        if gameState == .inPlay && !objectBall.isMoving && !shooterBall.isMoving {
            triggerDeadBall()
        }
        
        // RULE: Serving tries (If they missed 3 times).
        // This prevents a player from just shooting into space forever during a serve.
        if gameState == .waitingToServe && !shooterBall.isMoving && !hasHitThisThrow && servingAttempts > 0 {
            if servingAttempts >= 3 {
                triggerDeadBall()
            } else {
                // If they missed but still have tries, just reset the cue ball for another attempt.
                resetShooter()
            }
        }
        
        // AI Logic: The computer takes its shot automatically.
        if gameMode == .ai && activePlayerIndex == 1 && !isAiThinking && !showDeadBall {
            if !shooterBall.isMoving && !objectBall.isMoving {
                triggerAiShot()
            }
        }
    }
    
    /// Moves a single ball based on its current speed and applies friction.
    /// EXAM TIP: This function updates the 'State' (position and velocity) of a ball object.
    private func updateBallPhysics(_ ball: Ball, friction: CGFloat) {
        if ball.isPocketed { return }
        
        // Update position based on velocity.
        // MATH: Position = Position + Velocity
        ball.position.x += ball.velocity.dx
        ball.position.y += ball.velocity.dy
        
        // Slow down the ball by applying friction.
        ball.velocity.dx *= friction
        ball.velocity.dy *= friction
        
        // THRESHOLD: If the ball is moving incredibly slow, just stop it completely.
        // This prevents the ball from jittering or moving at 0.00001 speed forever.
        if abs(ball.velocity.dx) < 0.1 { ball.velocity.dx = 0 }
        if abs(ball.velocity.dy) < 0.1 { ball.velocity.dy = 0 }
        
        // BOUNCING LOGIC: Bouncing off the side walls.
        // If the ball's edge (position +/- radius) hits a wall, reverse its velocity.
        if ball.position.x - ball.radius <= 0 {
            ball.position.x = ball.radius
            ball.velocity.dx *= -0.7 // Multiply by -1 to reverse direction, 0.7 to lose 30% energy.
        } else if ball.position.x + ball.radius >= tableSize.width {
            ball.position.x = tableSize.width - ball.radius
            ball.velocity.dx *= -0.7
        }
        
        // Bouncing off the top and bottom walls.
        if ball.position.y - ball.radius <= 0 {
            ball.position.y = ball.radius
            ball.velocity.dy *= -0.7
        } else if ball.position.y + ball.radius >= tableSize.height {
            ball.position.y = tableSize.height - ball.radius
            ball.velocity.dy *= -0.7
        }
    }
    
    /// Handles what happens when two balls hit each other.
    /// EXAM TIP: This uses the Pythagorean Theorem (a^2 + b^2 = c^2) to find distance!
    private func checkBallCollision() {
        if shooterBall.isPocketed || objectBall.isPocketed { return }
        
        // Calculate the difference in X and Y between the two balls.
        let dx = objectBall.position.x - shooterBall.position.x
        let dy = objectBall.position.y - shooterBall.position.y
        
        // MATH: Distance = Square Root of (dx^2 + dy^2)
        let distance = sqrt(dx*dx + dy*dy)
        
        // If the distance is less than their combined radii, they are touching/overlapping.
        let minDistance = shooterBall.radius + objectBall.radius
        
        if distance < minDistance {
            // MATH: This is basic Vector Math for an Elastic Collision.
            // We calculate a 'Normal Vector' (the direction of the hit).
            let nx = dx / distance
            let ny = dy / distance
            
            // Calculate the relative velocity between the two balls.
            let rdx = objectBall.velocity.dx - shooterBall.velocity.dx
            let rdy = objectBall.velocity.dy - shooterBall.velocity.dy
            
            // The Dot Product tells us how much they are moving towards each other.
            let dotProduct = rdx * nx + rdy * ny
            
            // Only resolve the collision if they are actually moving towards each other.
            if dotProduct < 0 {
                // The 'Impulse' is the force of the hit.
                let impulse = -1.5 * dotProduct
                
                // Update both velocities based on the impulse and the hit direction.
                shooterBall.velocity.dx -= impulse * nx * 0.5
                shooterBall.velocity.dy -= impulse * ny * 0.5
                objectBall.velocity.dx += impulse * nx * 0.5
                objectBall.velocity.dy += impulse * ny * 0.5
                
                // Add a tiny bit of \"pop\" so they don't get stuck inside each other.
                if !shooterBall.isMoving { shooterBall.velocity = CGVector(dx: -nx * 2, dy: -ny * 2) }
                if !objectBall.isMoving { objectBall.velocity = CGVector(dx: nx * 2, dy: ny * 2) }
            }
            
            // PREVENTION: Push the balls apart slightly so they don't overlap on the next frame.
            let overlap = minDistance - distance
            shooterBall.position.x -= nx * overlap / 2
            shooterBall.position.y -= ny * overlap / 2
            objectBall.position.x += nx * overlap / 2
            objectBall.position.y += ny * overlap / 2
            
            // TURN TRACKING:
            if !hasHitThisThrow {
                hasHitThisThrow = true
                
                if gameState == .waitingToServe {
                    // Start the game officially after a successful serve hit.
                    gameState = .inPlay
                    nextTurn()
                    servingAttempts = 0
                } else {
                    // Turn switches after every successful hit in normal play.
                    nextTurn()
                }
            }
        }
    }
    
    /// Checks if either ball has entered one of the four corner pockets.
    private func checkPockets() {
        let pockets = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: tableSize.width, y: 0),
            CGPoint(x: 0, y: tableSize.height),
            CGPoint(x: tableSize.width, y: tableSize.height)
        ]
        
        for pocket in pockets {
            // Check the object ball (The one we are trying NOT to pocket).
            if !objectBall.isPocketed {
                let dist = sqrt(pow(objectBall.position.x - pocket.x, 2) + pow(objectBall.position.y - pocket.y, 2))
                if dist < pocketRadius {
                    objectBall.isPocketed = true
                    objectBall.velocity = .zero
                    loseLife(playerIndex: activePlayerIndex)
                }
            }
            
            // Check the cue ball (The white one).
            if !shooterBall.isPocketed {
                let dist = sqrt(pow(shooterBall.position.x - pocket.x, 2) + pow(shooterBall.position.y - pocket.y, 2))
                if dist < pocketRadius {
                    shooterBall.isPocketed = true
                    shooterBall.velocity = .zero
                    // Scratch! The cue ball disappears and respawns after a delay.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.shooterBall.isPocketed = false
                        self.shooterBall.position = CGPoint(x: self.tableSize.width / 2, y: self.tableSize.height * 0.8)
                    }
                }
            }
        }
    }
    
    /// AI Logic: Calculates where to aim to hit the object ball.
    private func triggerAiShot() {
        // Prevent the AI from shooting multiple times at once.
        if isAiThinking { return }
        isAiThinking = true
        
        // Add a delay so the CPU feels more like a real player \"thinking\" and \"aiming\".
        // The delay is slightly randomized for a more natural feel.
        let thinkTime = Double.random(in: 0.8...1.5)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + thinkTime) { [weak self] in
            guard let self = self else { return }
            
            // 1. CALCULATE DIRECTION: Aim from shooter to object ball.
            let dx = self.objectBall.position.x - self.shooterBall.position.x
            let dy = self.objectBall.position.y - self.shooterBall.position.y
            let distance = sqrt(dx*dx + dy*dy)
            
            // Avoid division by zero if they are somehow on top of each other.
            if distance == 0 {
                self.isAiThinking = false
                return
            }
            
            // 2. DEFINE SKILL: Determine accuracy and power based on settings.
            let speed: CGFloat
            let maxError: CGFloat
            
            switch self.settings.difficulty {
            case .easy:
                // Easy: Slower shots and can miss by quite a bit.
                speed = CGFloat.random(in: 5.0...8.0)
                maxError = 40.0
            case .medium:
                // Medium: Faster shots and decent aim.
                speed = CGFloat.random(in: 10.0...14.0)
                maxError = 20.0
            case .hard:
                // Hard: Strong shots and very precise aim.
                speed = CGFloat.random(in: 15.0...20.0)
                maxError = 5.0
            }
            
            // 3. APPLY ERROR: Add some \"human error\" to the aim.
            let errorX = CGFloat.random(in: -maxError...maxError)
            let errorY = CGFloat.random(in: -maxError...maxError)
            
            // 4. CALCULATE FINAL VELOCITY: Normalize the direction and multiply by speed.
            let velocity = CGVector(
                dx: ((dx / distance) * speed) + errorX,
                dy: ((dy / distance) * speed) + errorY
            )
            
            // 5. SHOOT: The CPU takes its shot!
            self.shootBall(with: velocity)
            
            // The AI is done thinking for now.
            self.isAiThinking = false
        }
    }
}
