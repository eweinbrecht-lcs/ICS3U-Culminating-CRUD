import SwiftUI

// MARK: - AIGameView
// This screen allows players to setup a game against the AI.
struct AIGameView: View {
    // INPUT: The shared view model for navigation and game state.
    var viewModel: GameViewModel
    
    var body: some View {
        BaseSubScreen(title: "Play vs AI", viewModel: viewModel) {
            VStack(spacing: 30) {
                Text("Think you can beat the computer?")
                    .foregroundColor(.white)
                
                Button("Start Game") {
                    withAnimation {
                        viewModel.setupPlayers(for: .ai)
                        viewModel.currentScreen = .game
                    }
                }
                .buttonStyle(GameButtonStyle())
            }
            .padding()
        }
    }
}

#Preview {
    AIGameView(viewModel: GameViewModel())
}
