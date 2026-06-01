import SwiftUI

// MARK: - BallView
struct BallView: View {
    // MARK: - Stored properties
    var ball: Ball
    
    // MARK: - Computed properties
    var body: some View {
        Circle()
            .fill(ballColor)
            .frame(width: ball.radius * 2, height: ball.radius * 2)
            .overlay(
                Circle()
                    .stroke(Color.black, lineWidth: 1)
            )
            .overlay(
                ballOverlay
            )
            .position(ball.position)
    }
    
    private var ballColor: Color {
        switch ball.type {
        case .shooter:
            return .white
        case .object:
            return .yellow
        }
    }
    
    @ViewBuilder
    private var ballOverlay: some View {
        if ball.type == .object {
            // Give the striped ball a stripe
            Rectangle()
                .fill(Color.white)
                .frame(height: ball.radius * 0.8)
        }
    }
}
