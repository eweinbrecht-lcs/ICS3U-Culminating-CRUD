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
            // Ensure the next active player is someone who is still in the game
            if players[activePlayerIndex].lives <= 0 {
                nextTurn()
            }
            resetTable()
        }
    }
    
    func checkWinner() {
        let alivePlayers = players.filter { $0.lives > 0 }
        if alivePlayers.count == 1 {
            winnerName = alivePlayers[0].name
            gameState = .gameOver
        }
    }
    
    // Restrict shooting to the short ends (Top 20% or Bottom 20%)
    func isValidShootPosition(_ point: CGPoint) -> Bool {
        let threshold = tableSize.height * 0.2
        return point.y < threshold || point.y > (tableSize.height - threshold)
    }
    
    func dragBall(to point: CGPoint) {
        if gameState == .gameOver { return }
        
        // Only allow dragging if it's a human turn
        if players[activePlayerIndex].name != "CPU" {
            // Restriction: Must shoot from short ends
            if isValidShootPosition(point) {
                shooterBall.position = point
                shooterBall.velocity = .zero
            }
        }
    }
    
    func shootBall(with velocity: CGVector) {
        if gameState == .gameOver { return }
        
        shooterBall.velocity = velocity
        
        if gameState == .waitingToServe {
            servingAttempts += 1
        }
    }
    
    func updatePhysics() {
        if gameState == .gameOver { return }
        
        let friction: CGFloat = 0.985
        updateBallPhysics(shooterBall, friction: friction)
        updateBallPhysics(objectBall, friction: friction)
        
        checkBallCollision()
        checkPockets()
        
        // RULE: If object ball stops moving inPlay, current player loses life
        if gameState == .inPlay && !objectBall.isMoving && !shooterBall.isMoving {
            loseLife(playerIndex: activePlayerIndex)
        }
        
        // RULE: Serving tries
        if gameState == .waitingToServe && !shooterBall.isMoving && servingAttempts >= 3 {
            loseLife(playerIndex: activePlayerIndex)
        }
        
        // AI Turn Logic
        if gameMode == .ai && activePlayerIndex == 1 && !isAiThinking {
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
    
    private func checkBallCollision() {
        if shooterBall.isPocketed || objectBall.isPocketed { return }
        
        let dx = objectBall.position.x - shooterBall.position.x
        let dy = objectBall.position.y - shooterBall.position.y
        let distance = sqrt(dx*dx + dy*dy)
        let minDistance = shooterBall.radius + objectBall.radius
        
        if distance < minDistance {
            // Collision detected!
            let tempVelocity = shooterBall.velocity
            shooterBall.velocity = objectBall.velocity
            objectBall.velocity = tempVelocity
            
            // Push apart
            let overlap = minDistance - distance
            let nx = dx / distance
            let ny = dy / distance
            shooterBall.position.x -= nx * overlap / 2
            shooterBall.position.y -= ny * overlap / 2
            objectBall.position.x += nx * overlap / 2
            objectBall.position.y += ny * overlap / 2
            
            // RULE CHANGE: If shooter hits object, it's now "inPlay" and turn changes
            if gameState == .waitingToServe || gameState == .inPlay {
                gameState = .inPlay
                nextTurn()
                servingAttempts = 0 // Reset tries for the next serve (if any)
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
            // Check object ball
            if !objectBall.isPocketed {
                let dist = sqrt(pow(objectBall.position.x - pocket.x, 2) + pow(objectBall.position.y - pocket.y, 2))
                if dist < pocketRadius {
                    objectBall.isPocketed = true
                    objectBall.velocity = .zero
                    
                    // RULE: If pocketed, the opponent (defending player) loses a life.
                    loseLife(playerIndex: activePlayerIndex)
                }
            }
            
            // Check shooter ball
            if !shooterBall.isPocketed {
                let dist = sqrt(pow(shooterBall.position.x - pocket.x, 2) + pow(shooterBall.position.y - pocket.y, 2))
                if dist < pocketRadius {
                    shooterBall.isPocketed = true
                    shooterBall.velocity = .zero
                    // Just reset shooter if it goes in
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
            
            // AI aims for the object ball
            let dx = self.objectBall.position.x - self.shooterBall.position.x
            let dy = self.objectBall.position.y - self.shooterBall.position.y
            let distance = sqrt(dx*dx + dy*dy)
            
            let speed: CGFloat = 18.0
            let error = CGFloat.random(in: -15...15)
            
            let velocity = CGVector(
                dx: (dx / distance) * speed + error,
                dy: (dy / distance) * speed + error
            )
            
            self.shootBall(with: velocity)
            self.isAiThinking = false
        }
    }
}
