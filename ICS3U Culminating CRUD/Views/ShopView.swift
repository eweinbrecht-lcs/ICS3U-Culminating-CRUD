import SwiftUI

// MARK: - ShopView
// The screen where players can buy custom items.
struct ShopView: View {
    // INPUT: Shared ViewModel for navigation.
    var viewModel: GameViewModel
    
    var body: some View {
        BaseSubScreen(title: "Shop", viewModel: viewModel) {
            VStack(spacing: 20) {
                Text("Customize your balls and table here! (Coming Soon)")
                    .font(.body)
                    .foregroundColor(.white)
                
                // Placeholder shop items
                ForEach(1...3, id: \.self) { item in
                    HStack {
                        Image(systemName: "cart.fill")
                            .foregroundColor(.yellow)
                        Text("Cool Item #\(item)")
                            .foregroundColor(.white)
                        Spacer()
                        Text("100 Coins")
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
    }
}

#Preview {
    ShopView(viewModel: GameViewModel())
}
