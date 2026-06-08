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
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(player.isActive ? Color.white.opacity(0.2) : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(player.isActive ? Color.yellow : Color.clear, lineWidth: 3)
                                    )
                                    .shadow(color: player.isActive ? .yellow.opacity(0.3) : .clear, radius: 5)
                            )
                        }
                    }
                    .padding(.top, 5)
                    .onChange(of: timeline.date) { oldDate, newDate in
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
                        
                        // Aiming Line
                        if viewModel.isDragging {
                            Path { path in
                                path.move(to: viewModel.shooterBall.position)
                                // The line points in the direction the ball WILL go (opposite of drag)
                                let targetX = viewModel.shooterBall.position.x + (viewModel.dragStartPoint.x - viewModel.currentDragPoint.x)
                                let targetY = viewModel.shooterBall.position.y + (viewModel.dragStartPoint.y - viewModel.currentDragPoint.y)
                                path.addLine(to: CGPoint(x: targetX, y: targetY))
                            }
                            .stroke(Color.white.opacity(0.5), style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [10]))
                        }
                        
                        // 4. Input Area (Transparent layer to catch gestures)
                        if isHumanTurn {
                            Color.clear
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            if !viewModel.isDragging {
                                                // Only start dragging if the touch is near the shooter ball
                                                let dist = sqrt(pow(value.startLocation.x - viewModel.shooterBall.position.x, 2) + pow(value.startLocation.y - viewModel.shooterBall.position.y, 2))
                                                if dist < 40 {
                                                    viewModel.startDragging(at: value.location)
                                                }
                                            } else {
                                                viewModel.dragBall(to: value.location)
                                            }
                                        }
                                        .onEnded { _ in
                                            viewModel.releaseBall()
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
                
                // --- DEAD BALL POPUP ---
                if viewModel.showDeadBall {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack {
                        Text("DEAD BALL")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundColor(.red)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(radius: 10)
                            )
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
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
        if viewModel.gameState == .gameOver || viewModel.showDeadBall { return false }
        let activePlayer = viewModel.players[viewModel.activePlayerIndex]
        return activePlayer.name != "CPU"
    }
}

#Preview {
    GameView(viewModel: GameViewModel())
}
