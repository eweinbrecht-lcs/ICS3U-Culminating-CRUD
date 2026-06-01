import SwiftUI

// MARK: - HandView
struct HandView: View {
    // MARK: - Stored properties
    var isRightHand: Bool
    
    // MARK: - Computed properties
    var body: some View {
        Image(systemName: "hand.raised.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .foregroundColor(.peach) // Custom color or just orange/pink
            .rotationEffect(.degrees(isRightHand ? 0 : 0)) // Adjust rotation as needed
    }
}

extension Color {
    static let peach = Color(red: 1.0, green: 0.8, blue: 0.7)
}
