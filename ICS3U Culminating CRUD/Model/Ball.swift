import Foundation
import CoreGraphics

// MARK: - BallType
// An 'Enum' is a custom type that lets us choose from a list of specific options.
// This prevents typos like "shooter" vs "Shooter".
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
    // If velocity is (0,0), the ball is stationary.
    var velocity: CGVector
    
    // The size of the ball.
    var radius: CGFloat
    
    // MARK: - Initializer
    
    /// Sets up a ball with its starting details.
    /// - Parameters:
    ///   - type: Which kind of ball this is.
    ///   - position: Where to put it on the table.
    ///   - velocity: How fast it starts (defaults to 0).
    ///   - radius: How big it is (defaults to 15 pixels).
    init(type: BallType, position: CGPoint, velocity: CGVector = .zero, radius: CGFloat = 15.0) {
        self.type = type
        self.position = position
        self.velocity = velocity
        self.radius = radius
    }
    
    // MARK: - Computed properties
    
    // This is a helper that tells us if the ball is currently moving.
    // We check if either dx or dy velocity is greater than a tiny amount (0.1).
    var isMoving: Bool {
        return abs(velocity.dx) > 0.1 || abs(velocity.dy) > 0.1
    }
}
