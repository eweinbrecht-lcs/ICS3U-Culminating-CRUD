import SwiftUI

// MARK: - GameView
// This is the main screen of the app where the game is played.
struct GameView: View {
    // MARK: - Stored properties
    
    // INPUT: The shared ViewModel passed from RootView.
    var viewModel: GameViewModel
    
    // MARK: - Computed properties
    
    var body: some View {
        TimelineView(.animation) { timeline in
            ZStack {
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
                        ForEach(viewModel.players) { player in
                            VStack {
                                Text(player.name)
                                    .fontWeight(player.isActive ? .bold : .regular)
                                    .foregroundColor(player.isActive ? .yellow : .white)
                                
                                // Life Counter (Hearts)
                                HStack(spacing: 2) {
                                    ForEach(0..<3) { i in
                                        Image(systemName: i < player.lives ? "heart.fill" : "heart")
                                            .foregroundColor(i < player.lives ? .red : .gray)
                                            .font(.caption)
                                    }
                                }
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(player.isActive ? Color.white.opacity(0.2) : Color.clear)
                            )
                        }
                    }
                    .padding(.top, 5)
                    .onChange(of: timeline.date) {
                        viewModel.updatePhysics()
                    }
                    
                    // Serving Tries indicator
                    if viewModel.gameState == .waitingToServe {
                        Text("Serving Tries: \(viewModel.servingAttempts)/3")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Capsule().fill(Color.blue.opacity(0.6)))
                    }
                    
                    Spacer()
                    
                    // --- GAME AREA ---
                    ZStack {
                        // 1. The Table (Background)
                        TableView(tableSize: viewModel.tableSize)
                        
                        // 2. Shooting Zones (Visual hints)
                        VStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: viewModel.tableSize.height * 0.2)
                            Spacer()
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: viewModel.tableSize.height * 0.2)
                        }
                        
                        // 3. The Balls
                        BallView(ball: viewModel.objectBall)
                        BallView(ball: viewModel.shooterBall)
                        
                        // 4. The Hand (Top layer)
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
                    
                    Text("Shoot from the highlighted ends!")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.bottom)
                }
                .background(Color.green.ignoresSafeArea())
                
                // --- WIN SCREEN OVERLAY ---
                if viewModel.gameState == .gameOver {
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 25) {
                        Text("🏆")
                            .font(.system(size: 80))
                        
                        Text("\(viewModel.winnerName) WINS!")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        
                        Button("Back to Menu") {
                            withAnimation {
                                viewModel.currentScreen = .menu
                            }
                        }
                        .buttonStyle(GameButtonStyle())
                        .padding(.horizontal, 50)
                    }
                }
            }
        }
    }
    
    private var isHumanTurn: Bool {
        if viewModel.gameState == .gameOver { return false }
        let activePlayer = viewModel.players[viewModel.activePlayerIndex]
        return activePlayer.name != "CPU"
    }
}

#Preview {
    GameView(viewModel: GameViewModel())
}
