import SwiftUI

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
            .padding()
        }
    }
}

#Preview {
    HowToPlayView(viewModel: GameViewModel())
}
