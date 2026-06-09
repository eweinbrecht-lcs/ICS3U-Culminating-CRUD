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
            
            // CRUD Rules: Only 4 pockets in the corners.
            ForEach(0..<4) { index in
                pocket(for: index)
            }
        }
        .frame(width: tableSize.width, height: tableSize.height)
    }
    
    // MARK: - Functions
    
    @ViewBuilder
    private func pocket(for index: Int) -> some View {
        let pocketRadius: CGFloat = 30 // Increased from 25 for easier scoring
        Circle()
            .fill(Color.black)
            .frame(width: pocketRadius * 2, height: pocketRadius * 2)
            .position(pocketPosition(for: index))
    }
    
    private func pocketPosition(for index: Int) -> CGPoint {
        switch index {
        case 0: return CGPoint(x: 0, y: 0)                     // Top left
        case 1: return CGPoint(x: tableSize.width, y: 0)       // Top right
        case 2: return CGPoint(x: 0, y: tableSize.height)      // Bottom left
        case 3: return CGPoint(x: tableSize.width, y: tableSize.height) // Bottom right
        default: return .zero
        }
    }
}
