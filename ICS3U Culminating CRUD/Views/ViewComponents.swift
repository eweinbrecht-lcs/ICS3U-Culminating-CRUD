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
