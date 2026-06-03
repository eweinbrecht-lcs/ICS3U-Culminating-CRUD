import SwiftUI

// MARK: - GameView
// This is the main screen of the app where the game is played.
struct GameView: View {
    // MARK: - Stored properties
    
    // We create one instance of the ViewModel to manage our game logic.
    @State private var viewModel = GameViewModel()
    
    // MARK: - Computed properties
    
    var body: some View {
        // TimelineView acts like a "Game Loop." It refreshes the screen constantly.
        TimelineView(.animation) { timeline in
            VStack {
                // --- HUD (Heads Up Display) ---
                HStack {
                    // ARRAY: We loop through the players array to show everyone's lives.
                    ForEach(viewModel.players) { player in
                        VStack {
                            Text(player.name)
                                .fontWeight(player.isActive ? .bold : .regular)
                            Text("Lives: \(player.lives)")
                                .foregroundColor(player.lives == 1 ? .red : .primary)
                        }
                        .padding()
                    }
                }
                // Every time the timeline "ticks," we tell the ViewModel to update the physics.
                .onChange(of: timeline.date) {
                    viewModel.updatePhysics()
                }
                
                Spacer()
                
                // --- GAME AREA ---
                ZStack {
                    // 1. The Table (Background)
                    TableView(tableSize: viewModel.tableSize)
                    
                    // 2. The Balls (Middle layer)
                    BallView(ball: viewModel.objectBall)
                    BallView(ball: viewModel.shooterBall)
                    
                    // 3. The Hand (Top layer)
                    // We only show the hand if the ball is still or we are waiting to start.
                    if viewModel.gameState == .waitingToServe || viewModel.shooterBall.velocity == .zero {
                        HandView(isRightHand: true)
                            .position(viewModel.shooterBall.position)
                            .offset(y: 30) // Position the hand slightly below the ball
                            .gesture(
                                // GESTURE: This allows the user to touch and move the hand.
                                DragGesture()
                                    .onChanged { value in
                                        // While dragging, update the ball's position.
                                        viewModel.dragBall(to: value.location)
                                    }
                                    .onEnded { value in
                                        // When released, calculate the "flick" speed.
                                        let velocity = CGVector(
                                            dx: value.predictedEndLocation.x - value.location.x,
                                            dy: value.predictedEndLocation.y - value.location.y
                                        )
                                        viewModel.shootBall(with: velocity)
                                    }
                            )
                    }
                }
                .frame(width: viewModel.tableSize.width, height: viewModel.tableSize.height)
                
                Spacer()
                
                // --- CONTROLS ---
                HStack {
                    Button("Reset Table") {
                        viewModel.resetTable()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Add Life") {
                        // Find the first player who is active and give them a life.
                        if let activePlayer = viewModel.players.first(where: { $0.isActive }) {
                            activePlayer.lives += 1
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
        }
    }
}

#Preview {
    GameView()
}
