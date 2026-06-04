import SwiftUI

// MARK: - MainMenuView
// The primary entry screen for the game.
struct MainMenuView: View {
    // INPUT: The shared view model for navigation.
    var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            // Background: Green felt
            Color.green.ignoresSafeArea()
            
            // Decorative table border
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.brown, lineWidth: 15)
                .padding()
            
            VStack(spacing: 30) {
                Text("CRUD POOL")
                    .font(.system(size: 50, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                
                VStack(spacing: 15) {
                    Button("Play vs AI") {
                        withAnimation {
                            viewModel.currentScreen = .aiGame
                        }
                    }
                    
                    Button("Local Multiplayer") {
                        withAnimation {
                            viewModel.currentScreen = .localMultiplayer
                        }
                    }
                    
                    Button("Shop") {
                        withAnimation {
                            viewModel.currentScreen = .shop
                        }
                    }
                    
                    Button("Settings") {
                        withAnimation {
                            viewModel.currentScreen = .settings
                        }
                    }
                    
                    Button("How to Play") {
                        withAnimation {
                            viewModel.currentScreen = .howToPlay
                        }
                    }
                }
                .padding(.horizontal, 50)
                .buttonStyle(GameButtonStyle())
            }
        }
    }
}

#Preview {
    MainMenuView(viewModel: GameViewModel())
}
