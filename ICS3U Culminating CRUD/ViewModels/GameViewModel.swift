import Foundation
import SwiftUI

// MARK: - AppState
enum AppScreen {
    case menu
    case game
    case shop
    case settings
    case howToPlay
    case localMultiplayer
    case aiGame
}

enum GameMode {
    case ai
    case local
}

enum GameState {
    case waitingToServe // Before first hit
    case inPlay         // Object ball is moving
    case gameOver       // Someone won
}

@Observable
class GameViewModel {
    // MARK: - Stored properties
    
    var currentScreen: AppScreen = .menu
    var gameMode: GameMode = .local
    var players: [Player] = []
    var activePlayerIndex: Int = 0
    
    var shooterBall: Ball
    var objectBall: Ball
    
    var gameState: GameState = .waitingToServe
    var tableSize: CGSize = CGSize(width: 300, height: 600)
    
    var servingAttempts: Int = 0
    var isAiThinking: Bool = false
    
    // Tracks if the current throw has already hit the object ball
    var hasHitThisThrow: Bool = false
    
    // Controls the "Dead Ball" popup visibility
    var showDeadBall: Bool = false
    
    // The winner's name to display on the win screen
    var winnerName: String = ""
    
    // Pocket settings
    let pocketRadius: CGFloat = 25.0
    
    // MARK: - Initializer
    
    init() {
        self.shooterBall = Ball(type: .shooter, position: CGPoint(x: 150, y: 500))
        self.objectBall = Ball(type: .object, position: CGPoint(x: 150, y: 150))
        setupPlayers(for: .local)
    }
    
    // MARK: - Functions
    
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
    
    func resetTable() {
        shooterBall.position = CGPoint(x: tableSize.width / 2, y: tableSize.height * 0.8)
        shooterBall.velocity = .zero
        shooterBall.isPocketed = false
        
        objectBall.position = CGPoint(x: tableSize.width / 2, y: tableSize.height * 0.2)
        objectBall.velocity = .zero
        objectBall.isPocketed = false
        
        gameState = .waitingToServe
        servingAttempts = 0
        isAiThinking = false
        hasHitThisThrow = false
    }
    
    func updateActiveStatus() {
        for i in 0..<players.count {
            players[i].isActive = (i == activePlayerIndex)
        }
    }
    
    func nextTurn() {
        let alivePlayers = players.filter { $0.lives > 0 }
        if alivePlayers.count <= 1 { return }
        
        activePlayerIndex = (activePlayerIndex + 1) % players.count
        while players[activePlayerIndex].lives <= 0 {
            activePlayerIndex = (activePlayerIndex + 1) % players.count
        }
        updateActiveStatus()
    }
    
    func loseLife(playerIndex: Int) {
        players[playerIndex].lives -= 1
        
        if players[playerIndex].lives <= 0 {
            checkWinner()
        }
        
        // After losing a life, we reset the table for a new serve
        if gameState != .gameOver {
            if players[activePlayerIndex].lives <= 0 {
                nextTurn()
            }
            resetTable()
        }
    }
    
    func triggerDeadBall() {
        if showDeadBall { return }
        showDeadBall = true
        
        // The current player loses a life because they failed to hit it before it stopped
        loseLife(playerIndex: activePlayerIndex)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showDeadBall = false
        }
    }
    
    func checkWinner() {
        let alivePlayers = players.filter { $0.lives > 0 }
        if alivePlayers.count == 1 {
            winnerName = alivePlayers[0].name
            gameState = .gameOver
        }
    }
    
    func isValidShootPosition(_ point: CGPoint) -> Bool {
        let threshold = tableSize.height * 0.2
        return point.y < threshold || point.y > (tableSize.height - threshold)
    }
    
    func dragBall(to point: CGPoint) {
        if gameState == .gameOver || showDeadBall { return }
        
        if players[activePlayerIndex].name != "CPU" {
            if isValidShootPosition(point) {
                shooterBall.position = point
                shooterBall.velocity = .zero
            }
        }
    }
    
    func shootBall(with velocity: CGVector) {
        if gameState == .gameOver || showDeadBall { return }
        
        // SLOW DOWN: Apply a reduction factor to the throw speed
        let speedReduction: CGFloat = 0.5
        shooterBall.velocity = CGVector(dx: velocity.dx * speedReduction, dy: velocity.dy * speedReduction)
        
        hasHitThisThrow = false
        
        if gameState == .waitingToServe {
            servingAttempts += 1
        } else if gameState == .inPlay {
            // TURN LOGIC: In CRUD, once the ball is in play, turn changes when you throw
            nextTurn()
        }
    }
    
    func updatePhysics() {
        if gameState == .gameOver || showDeadBall { return }
        
        // SLOW DOWN: Lower friction (higher friction value actually means slower decay in some engines, 
        // but here 0.985 is decay, so 0.97 is faster decay = slower game)
        let friction: CGFloat = 0.975
        updateBallPhysics(shooterBall, friction: friction)
        updateBallPhysics(objectBall, friction: friction)
        
        checkBallCollision()
        checkPockets()
        
        // RULE: Dead Ball
        if gameState == .inPlay && !objectBall.isMoving && !shooterBall.isMoving {
            triggerDeadBall()
        }
        
        // RULE: Serving tries
        if gameState == .waitingToServe && !shooterBall.isMoving && servingAttempts >= 3 {
            triggerDeadBall()
        }
        
        // AI Turn Logic
        if gameMode == .ai && activePlayerIndex == 1 && !isAiThinking && !showDeadBall {
            if !shooterBall.isMoving && !objectBall.isMoving {
                triggerAiShot()
            }
        }
    }
    
    private func updateBallPhysics(_ ball: Ball, friction: CGFloat) {
        if ball.isPocketed { return }
        
        ball.position.x += ball.velocity.dx
        ball.position.y += ball.velocity.dy
        
        ball.velocity.dx *= friction
        ball.velocity.dy *= friction
        
        if abs(ball.velocity.dx) < 0.1 { ball.velocity.dx = 0 }
        if abs(ball.velocity.dy) < 0.1 { ball.velocity.dy = 0 }
        
        // Wall Bounces
        if ball.position.x - ball.radius <= 0 {
            ball.position.x = ball.radius
            ball.velocity.dx *= -0.7 // Bounce loss
        } else if ball.position.x + ball.radius >= tableSize.width {
            ball.position.x = tableSize.width - ball.radius
            ball.velocity.dx *= -0.7
        }
        
        if ball.position.y - ball.radius <= 0 {
            ball.position.y = ball.radius
            ball.velocity.dy *= -0.7
        } else if ball.position.y + ball.radius >= tableSize.height {
            ball.position.y = tableSize.height - ball.radius
            ball.velocity.dy *= -0.7
        }
    }
    
    private func checkBallCollision() {
        if shooterBall.isPocketed || objectBall.isPocketed { return }
        
        let dx = objectBall.position.x - shooterBall.position.x
        let dy = objectBall.position.y - shooterBall.position.y
        let distance = sqrt(dx*dx + dy*dy)
        let minDistance = shooterBall.radius + objectBall.radius
        
        if distance < minDistance {
            // Collision physics: Standard elastic collision
            let nx = dx / distance
            let ny = dy / distance
            
            let rdx = objectBall.velocity.dx - shooterBall.velocity.dx
            let rdy = objectBall.velocity.dy - shooterBall.velocity.dy
            let dotProduct = rdx * nx + rdy * ny
            
            if dotProduct < 0 {
                let impulse = -1.5 * dotProduct // Coefficient of restitution (1.5 for a bit of pop)
                
                shooterBall.velocity.dx -= impulse * nx * 0.5
                shooterBall.velocity.dy -= impulse * ny * 0.5
                objectBall.velocity.dx += impulse * nx * 0.5
                objectBall.velocity.dy += impulse * ny * 0.5
                
                // Ensure they don't stop instantly
                if !shooterBall.isMoving { shooterBall.velocity = CGVector(dx: -nx * 2, dy: -ny * 2) }
                if !objectBall.isMoving { objectBall.velocity = CGVector(dx: nx * 2, dy: ny * 2) }
            }
            
            // Push apart
            let overlap = minDistance - distance
            shooterBall.position.x -= nx * overlap / 2
            shooterBall.position.y -= ny * overlap / 2
            objectBall.position.x += nx * overlap / 2
            objectBall.position.y += ny * overlap / 2
            
            // TURN LOGIC: 
            if !hasHitThisThrow {
                hasHitThisThrow = true
                
                if gameState == .waitingToServe {
                    // Successful serve!
                    gameState = .inPlay
                    nextTurn()
                    servingAttempts = 0
                }
                // If already inPlay, turn already changed on shootBall
            }
        }
    }
    
    private func checkPockets() {
        let pockets = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: tableSize.width, y: 0),
            CGPoint(x: 0, y: tableSize.height),
            CGPoint(x: tableSize.width, y: tableSize.height)
        ]
        
        for pocket in pockets {
            if !objectBall.isPocketed {
                let dist = sqrt(pow(objectBall.position.x - pocket.x, 2) + pow(objectBall.position.y - pocket.y, 2))
                if dist < pocketRadius {
                    objectBall.isPocketed = true
                    objectBall.velocity = .zero
                    loseLife(playerIndex: activePlayerIndex)
                }
            }
            
            if !shooterBall.isPocketed {
                let dist = sqrt(pow(shooterBall.position.x - pocket.x, 2) + pow(shooterBall.position.y - pocket.y, 2))
                if dist < pocketRadius {
                    shooterBall.isPocketed = true
                    shooterBall.velocity = .zero
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.shooterBall.isPocketed = false
                        self.shooterBall.position = CGPoint(x: self.tableSize.width / 2, y: self.tableSize.height * 0.8)
                    }
                }
            }
        }
    }
    
    private func triggerAiShot() {
        isAiThinking = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self = self else { return }
            
            let dx = self.objectBall.position.x - self.shooterBall.position.x
            let dy = self.objectBall.position.y - self.shooterBall.position.y
            let distance = sqrt(dx*dx + dy*dy)
            
            let speed: CGFloat = 12.0 // AI also slowed down
            let error = CGFloat.random(in: -10...10)
            
            let velocity = CGVector(
                dx: (dx / distance) * speed + error,
                dy: (dy / distance) * speed + error
            )
            
            self.shootBall(with: velocity)
            self.isAiThinking = false
        }
    }
}
