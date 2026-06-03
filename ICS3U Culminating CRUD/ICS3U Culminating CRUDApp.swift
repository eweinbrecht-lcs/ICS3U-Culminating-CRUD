import SwiftUI

// MARK: - ICS3U_Culminating_CRUDApp
// This is the starting point of the entire application.
@main
struct ICS3U_Culminating_CRUDApp: App {
    // We create one instance of the ViewModel to manage our app's state.
    @State private var viewModel = GameViewModel()
    
    var body: some Scene {
        WindowGroup {
            // RootView handles switching between the menu and the game.
            RootView(viewModel: viewModel)
        }
    }
}

// MARK: - RootView
// A controller view that decides which screen to show.
struct RootView: View {
    // INPUT: The shared ViewModel for navigation.
    var viewModel: GameViewModel
    
    var body: some View {
        Group {
            switch viewModel.currentScreen {
            case .menu:
                // Displays the main landing screen with Play, Shop, etc.
                MainMenuView(viewModel: viewModel)
            case .game:
                // Displays the active pool table and players.
                GameView(viewModel: viewModel)
            case .shop:
                // Displays the store for customization.
                ShopView(viewModel: viewModel)
            case .settings:
                // Displays options to change game behavior.
                SettingsView(viewModel: viewModel)
            case .howToPlay:
                // Displays the rules of Crud.
                HowToPlayView(viewModel: viewModel)
            }
        }
        // Smooth transition animation when switching screens.
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    }
}
