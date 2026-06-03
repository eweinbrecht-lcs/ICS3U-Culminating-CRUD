import SwiftUI

// MARK: - GameButtonStyle
// A custom button style that looks like a pool table rail.
struct GameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.bold())
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.brown)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.black.opacity(0.3), lineWidth: 4)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .shadow(radius: configuration.isPressed ? 2 : 5)
    }
}

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
                            viewModel.setupPlayers(for: .ai)
                            viewModel.currentScreen = .game
                        }
                    }
                    
                    Button("Local Multiplayer") {
                        withAnimation {
                            viewModel.setupPlayers(for: .local)
                            viewModel.currentScreen = .game
                        }
                    }
                    
                    Button("Shop") {
                        withAnimation { viewModel.currentScreen = .shop }
                    }
                    
                    Button("Settings") {
                        withAnimation { viewModel.currentScreen = .settings }
                    }
                    
                    Button("How to Play") {
                        withAnimation { viewModel.currentScreen = .howToPlay }
                    }
                }
                .padding(.horizontal, 50)
                .buttonStyle(GameButtonStyle())
            }
        }
    }
}

// MARK: - ShopView
// The screen where players can buy custom items.
struct ShopView: View {
    // INPUT: Shared ViewModel for navigation.
    var viewModel: GameViewModel
    
    var body: some View {
        BaseSubScreen(title: "Shop", viewModel: viewModel) {
            Text("Customize your balls and table here! (Coming Soon)")
                .font(.body)
                .foregroundColor(.white)
        }
    }
}

// MARK: - SettingsView
// The screen for adjusting game preferences.
struct SettingsView: View {
    // INPUT: Shared ViewModel for navigation.
    var viewModel: GameViewModel
    
    var body: some View {
        BaseSubScreen(title: "Settings", viewModel: viewModel) {
            Text("Adjust sound, difficulty, and physics! (Coming Soon)")
                .font(.body)
                .foregroundColor(.white)
        }
    }
}

// MARK: - HowToPlayView
// The screen that explains the rules of the game.
struct HowToPlayView: View {
    // INPUT: Shared ViewModel for navigation.
    var viewModel: GameViewModel
    
    var body: some View {
        BaseSubScreen(title: "How to Play", viewModel: viewModel) {
            VStack(alignment: .leading, spacing: 15) {
                Text("CRUD RULES:")
                    .font(.headline)
                    .foregroundColor(.yellow)
                
                Text("1. The shooter must hit the object ball.")
                Text("2. The object ball must hit a rail to stay 'alive'.")
                Text("3. If you miss, you lose a life.")
                Text("4. Last player standing wins!")
            }
            .font(.body)
            .foregroundColor(.white)
        }
    }
}

// MARK: - BaseSubScreen
// A shared layout used by Shop, Settings, and How to Play.
// It includes the green background and the back button.
struct BaseSubScreen<Content: View>: View {
    var title: String
    var viewModel: GameViewModel
    let content: Content
    
    init(title: String, viewModel: GameViewModel, @ViewBuilder content: () -> Content) {
        self.title = title
        self.viewModel = viewModel
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Color.green.ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: {
                        withAnimation { viewModel.currentScreen = .menu }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.brown))
                    }
                    Spacer()
                }
                .padding()
                
                Text(title)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                ScrollView {
                    content
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.black.opacity(0.2))
                        )
                }
                .padding()
                
                Spacer()
            }
        }
    }
}

#Preview {
    MainMenuView(viewModel: GameViewModel())
}
