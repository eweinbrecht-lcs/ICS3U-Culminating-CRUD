import SwiftUI

// MARK: - SettingsView
// The screen for adjusting game preferences.
struct SettingsView: View {
    // INPUT: Shared ViewModel for navigation.
    var viewModel: GameViewModel
    
    var body: some View {
        BaseSubScreen(title: "Settings", viewModel: viewModel) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Adjust sound, difficulty, and physics! (Coming Soon)")
                    .font(.body)
                    .foregroundColor(.white)
                
                Divider()
                
                Toggle("Sound Effects", isOn: .constant(true))
                    .foregroundColor(.white)
                
                Toggle("Music", isOn: .constant(false))
                    .foregroundColor(.white)
                
                HStack {
                    Text("Difficulty")
                        .foregroundColor(.white)
                    Spacer()
                    Text("Medium")
                        .foregroundColor(.yellow)
                }
            }
            .padding()
        }
    }
}

#Preview {
    SettingsView(viewModel: GameViewModel())
}
