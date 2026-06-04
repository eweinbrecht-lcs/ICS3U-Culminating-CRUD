import SwiftUI

// MARK: - LocalMultiplayerView
// This screen allows players to setup a local game.
struct LocalMultiplayerView: View {
    // INPUT: The shared view model for navigation and game state.
    var viewModel: GameViewModel
    
    var body: some View {
        BaseSubScreen(title: "Local Multiplayer", viewModel: viewModel) {
            VStack(spacing: 30) {
                Text("Setup your local game here!")
                    .foregroundColor(.white)
                
                Button("Start Game") {
                    withAnimation {
                        viewModel.setupPlayers(for: .local)
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
    LocalMultiplayerView(viewModel: GameViewModel())
}
