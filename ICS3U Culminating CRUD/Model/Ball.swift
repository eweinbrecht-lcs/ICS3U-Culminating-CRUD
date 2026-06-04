import Foundation
import CoreGraphics

// MARK: - BallType
// An 'Enum' is a custom type that lets us choose from a list of specific options.
enum BallType {
    case shooter  // The white cue ball
    case object   // The yellow striped ball
}

// MARK: - Ball
// This model handles the physics data for a single ball on the table.
@Observable
class Ball {
    // MARK: - Stored properties
    
    // Is this the shooter or the target?
    var type: BallType
    
    // Position tracks where the ball is on the 2D screen (x, y).
    var position: CGPoint
    
    // Velocity tracks how fast the ball is moving in the x and y directions.
    var velocity: CGVector
    
    // The size of the ball.
    var radius: CGFloat
    
    // Tracks if the ball has fallen into a pocket.
    var isPocketed: Bool = false
    
    // MARK: - Initializer
    
    init(type: BallType, position: CGPoint, velocity: CGVector = .zero, radius: CGFloat = 15.0) {
        self.type = type
        self.position = position
        self.velocity = velocity
        self.radius = radius
    }
    
    // MARK: - Computed properties
    
    var isMoving: Bool {
        return abs(velocity.dx) > 0.1 || abs(velocity.dy) > 0.1
    }
}
