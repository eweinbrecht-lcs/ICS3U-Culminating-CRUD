import SwiftUI

// MARK: - SettingsView
// The screen for adjusting game preferences.
struct SettingsView: View {
    // INPUT: Shared ViewModel for navigation.
    var viewModel: GameViewModel
    
    var body: some View {
        // We use @Bindable to create bindings to the @Observable settings model.
        @Bindable var settings = viewModel.settings
        
        BaseSubScreen(title: "Settings", viewModel: viewModel) {
            VStack(alignment: .leading, spacing: 25) {
                Text("Adjust sound, difficulty, and physics to your liking.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Divider()
                
                // UPDATE: Sound toggle
                Toggle(isOn: $settings.isSoundEnabled) {
                    Label("Sound Effects", systemImage: settings.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .foregroundColor(.white)
                }
                .tint(.brown)
                
                // UPDATE: Music toggle
                Toggle(isOn: $settings.isMusicEnabled) {
                    Label("Music", systemImage: settings.isMusicEnabled ? "music.note" : "music.note.list")
                        .foregroundColor(.white)
                }
                .tint(.brown)
                
                Divider()
                
                // UPDATE: Difficulty picker
                VStack(alignment: .leading, spacing: 10) {
                    Text("Difficulty")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Picker("Difficulty", selection: $settings.difficulty) {
                        ForEach(Difficulty.allCases) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                    // Segmented picker background is tricky in SwiftUI, so we keep it simple
                }
                
                Spacer()
                    .frame(height: 40)
                
                // DELETE (Reset): A way to clear custom settings and return to defaults.
                Button(role: .destructive) {
                    withAnimation {
                        settings.resetToDefaults()
                    }
                } label: {
                    Text("Reset to Defaults")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(GameButtonStyle())
            }
            .padding()
        }
    }
}

#Preview {
    SettingsView(viewModel: GameViewModel())
}
