import Foundation
import CoreGraphics

// MARK: - BallType
// An 'Enum' (Enumeration) is a custom type that lets us choose from a list of specific options.
// EXAM TIP: Enums make code more readable by using words instead of mysterious numbers.
enum BallType {
    case shooter  // Represents the white cue ball
    case object   // Represents the yellow target ball
}

// MARK: - Ball
// This 'Model' class holds the physical data for a single ball on the table.
// We use the @Observable macro so that the UI updates automatically whenever a ball moves.
@Observable
class Ball {
    // MARK: - Stored properties
    
    // type: Tells the program if this is the ball the player controls or the target.
    var type: BallType
    
    // position: Tracks the EXACT (x, y) coordinates of the ball's center on the screen.
    // MATH: (0,0) is the top-left corner of the table.
    var position: CGPoint
    
    // velocity: Tracks how fast the ball is moving and in what direction.
    // dx is speed left/right, dy is speed up/down.
    var velocity: CGVector
    
    // radius: The distance from the center of the ball to its edge.
    // This is used for collision detection (distance < radius1 + radius2).
    var radius: CGFloat
    
    // isPocketed: A Boolean (True/False) that tracks if the ball is still on the table.
    var isPocketed: Bool = false
    
    // MARK: - Initializer
    
    // This function creates a new Ball object and sets its starting values.
    init(type: BallType, position: CGPoint, velocity: CGVector = .zero, radius: CGFloat = 15.0) {
        self.type = type
        self.position = position
        self.velocity = velocity
        self.radius = radius
    }
    
    // MARK: - Computed properties
    
    // isMoving: A quick way to check if the ball is actually rolling.
    // If the velocity is extremely low (less than 0.1), we treat it as 'stopped'.
    var isMoving: Bool {
        return abs(velocity.dx) > 0.1 || abs(velocity.dy) > 0.1
    }
}
