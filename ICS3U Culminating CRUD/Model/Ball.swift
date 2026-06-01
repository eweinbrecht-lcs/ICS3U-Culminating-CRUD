import Foundation
import CoreGraphics

// MARK: - BallType
enum BallType {
    case shooter
    case object
}

// MARK: - Ball
@Observable
class Ball {
    // MARK: - Stored properties
    var type: BallType
    var position: CGPoint
    var velocity: CGVector
    var radius: CGFloat
    
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
