import SwiftUI

// MARK: - TableView
// A custom subview that renders the pool table.
struct TableView: View {
    // MARK: - Stored properties
    
    // INPUT: The size of the table, provided by the ViewModel.
    var tableSize: CGSize
    
    // MARK: - Computed properties
    
    var body: some View {
        ZStack {
            // The green felt surface.
            Rectangle()
                .fill(Color.green)
                .border(Color.brown, width: 10) // The brown wooden rails.
            
            // Pockets: We use a loop to draw 6 pockets.
            ForEach(0..<6) { index in
                pocket(for: index)
            }
        }
        .frame(width: tableSize.width, height: tableSize.height)
    }
    
    // MARK: - Functions
    
    /// Helper view to create a single black pocket.
    /// - Parameter index: Which pocket we are drawing (0 to 5).
    @ViewBuilder
    private func pocket(for index: Int) -> some View {
        let pocketRadius: CGFloat = 20
        Circle()
            .fill(Color.black)
            .frame(width: pocketRadius * 2, height: pocketRadius * 2)
            .position(pocketPosition(for: index))
    }
    
    /// Returns the (x, y) coordinates for each pocket based on the table size.
    /// - Parameter index: The index of the pocket.
    /// - Returns: A CGPoint representing the location on the table.
    private func pocketPosition(for index: Int) -> CGPoint {
        switch index {
        case 0: return CGPoint(x: 0, y: 0)                     // Top left
        case 1: return CGPoint(x: tableSize.width / 2, y: 0)   // Top middle
        case 2: return CGPoint(x: tableSize.width, y: 0)       // Top right
        case 3: return CGPoint(x: 0, y: tableSize.height)      // Bottom left
        case 4: return CGPoint(x: tableSize.width / 2, y: tableSize.height) // Bottom middle
        case 5: return CGPoint(x: tableSize.width, y: tableSize.height)      // Bottom right
        default: return .zero
        }
    }
}
