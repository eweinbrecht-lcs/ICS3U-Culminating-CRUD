import SwiftUI

// MARK: - BallView
// A custom subview that renders a single ball.
struct BallView: View {
    // MARK: - Stored properties
    
    // INPUT: The Ball object containing position and type.
    var ball: Ball
    
    // MARK: - Computed properties
    
    var body: some View {
        Circle()
            .fill(ballColor)
            .frame(width: ball.radius * 2, height: ball.radius * 2)
            .overlay(
                Circle()
                    .stroke(Color.black, lineWidth: 1) // Outline for visibility
            )
            .overlay(
                ballOverlay // Adds the stripe for the object ball
            )
            .position(ball.position) // Places the ball at the correct coordinates
    }
    
    // Helper to determine color based on ball type.
    private var ballColor: Color {
        switch ball.type {
        case .shooter:
            return .white
        case .object:
            return .yellow
        }
    }
    
    // Helper to add visual details (like stripes).
    @ViewBuilder
    private var ballOverlay: some View {
        if ball.type == .object {
            // A white stripe across the middle of the yellow ball.
            Rectangle()
                .fill(Color.white)
                .frame(height: ball.radius * 0.8)
        }
    }
}
