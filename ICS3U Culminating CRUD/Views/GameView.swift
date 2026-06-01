import SwiftUI

// MARK: - GameView
struct GameView: View {
    // MARK: - Stored properties
    @State private var viewModel = GameViewModel()
    
    // MARK: - Computed properties
    var body: some View {
        VStack {
            // HUD
            HStack {
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
            
            Spacer()
            
            // Game Area
            ZStack {
                TableView(tableSize: viewModel.tableSize)
                
                BallView(ball: viewModel.objectBall)
                BallView(ball: viewModel.shooterBall)
                
                // Hands (simplified)
                if viewModel.gameState == .waitingToServe {
                    HandView(isRightHand: true)
                        .position(x: viewModel.tableSize.width / 2, y: viewModel.tableSize.height + 20)
                }
            }
            .frame(width: viewModel.tableSize.width, height: viewModel.tableSize.height)
            
            Spacer()
            
            // Controls
            HStack {
                Button("Reset Table") {
                    viewModel.resetTable()
                }
                .buttonStyle(.bordered)
                
                Button("Add Life") {
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

#Preview {
    GameView()
}
