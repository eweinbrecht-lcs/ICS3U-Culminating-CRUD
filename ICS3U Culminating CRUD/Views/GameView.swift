import SwiftUI

// MARK: - GameView
// This is the main screen of the app where the game is played.
struct GameView: View {
    // MARK: - Stored properties
    
    // INPUT: The shared ViewModel passed from RootView.
    var viewModel: GameViewModel
    
    // MARK: - Computed properties
    
    var body: some View {
        // TimelineView acts like a "Game Loop." It refreshes the screen constantly.
        TimelineView(.animation) { timeline in
            VStack {
                // --- TOP NAV ---
                HStack {
                    Button(action: {
                        withAnimation { viewModel.currentScreen = .menu }
                    }) {
                        Image(systemName: "house.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Circle().fill(Color.brown))
                    }
                    Spacer()
                    Text(viewModel.gameMode == .ai ? "VS AI" : "Local PvP")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.black.opacity(0.3)))
                }
                .padding(.horizontal)
                
                // --- HUD (Heads Up Display) ---
                HStack {
                    // ARRAY: We loop through the players array to show everyone's lives.
                    ForEach(viewModel.players) { player in
                        VStack {
                            Text(player.name)
                                .fontWeight(player.isActive ? .bold : .regular)
                                .foregroundColor(player.isActive ? .yellow : .white)
                            Text("Lives: \(player.lives)")
                                .foregroundColor(player.lives == 1 ? .red : .white.opacity(0.8))
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(player.isActive ? Color.white.opacity(0.2) : Color.clear)
                        )
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
                    // We only show the hand if it's a HUMAN player's turn and balls are stopped.
                    if isHumanTurn && (!viewModel.shooterBall.isMoving && !viewModel.objectBall.isMoving) {
                        HandView(isRightHand: true)
                            .position(viewModel.shooterBall.position)
                            .offset(y: 30)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        viewModel.dragBall(to: value.location)
                                    }
                                    .onEnded { value in
                                        let velocity = CGVector(
                                            dx: value.predictedEndLocation.x - value.location.x,
                                            dy: value.predictedEndLocation.y - value.location.y
                                        )
                                        viewModel.shootBall(with: velocity)
                                    }
                            )
                    }
                    
                    // AI Thinking Label
                    if viewModel.isAiThinking {
                        Text("CPU is thinking...")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Capsule().fill(Color.black.opacity(0.6)))
                            .position(x: viewModel.tableSize.width / 2, y: viewModel.tableSize.height / 2)
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
                    .tint(.white)
                    
                    Spacer()
                }
                .padding()
            }
            .background(Color.green.ignoresSafeArea())
        }
    }
    
    // Helper to check if it's a human's turn.
    private var isHumanTurn: Bool {
        if let activePlayer = viewModel.players.first(where: { $0.isActive }) {
            return activePlayer.name != "CPU"
        }
        return false
    }
}

#Preview {
    GameView(viewModel: GameViewModel())
}
