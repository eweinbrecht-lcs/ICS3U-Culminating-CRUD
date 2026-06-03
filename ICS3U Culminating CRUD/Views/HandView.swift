import SwiftUI

// MARK: - HandView
// A custom subview that renders a hand icon.
struct HandView: View {
    // MARK: - Stored properties
    
    // INPUT: Tracks if we should show a right or left hand (optional feature).
    var isRightHand: Bool
    
    // MARK: - Computed properties
    
    var body: some View {
        // We use a SF Symbol for the hand.
        Image(systemName: "hand.raised.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .foregroundColor(.peach) // A custom skin-tone color
    }
}

// Custom color extension to add a 'peach' color for skin tones.
extension Color {
    static let peach = Color(red: 1.0, green: 0.8, blue: 0.7)
}
