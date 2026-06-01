import SwiftUI

// MARK: - TableView
struct TableView: View {
    // MARK: - Stored properties
    var tableSize: CGSize
    
    // MARK: - Computed properties
    var body: some View {
        ZStack {
            // Table surface
            Rectangle()
                .fill(Color.green)
                .border(Color.brown, width: 10)
            
            // Pockets
            ForEach(0..<6) { index in
                pocket(for: index)
            }
        }
        .frame(width: tableSize.width, height: tableSize.height)
    }
    
    // MARK: - Functions
    @ViewBuilder
    private func pocket(for index: Int) -> some View {
        let pocketRadius: CGFloat = 20
        Circle()
            .fill(Color.black)
            .frame(width: pocketRadius * 2, height: pocketRadius * 2)
            .position(pocketPosition(for: index))
    }
    
    private func pocketPosition(for index: Int) -> CGPoint {
        switch index {
        case 0: return CGPoint(x: 0, y: 0) // Top left
        case 1: return CGPoint(x: tableSize.width / 2, y: 0) // Top middle? No, Crud usually has 6 pockets like standard pool.
        case 2: return CGPoint(x: tableSize.width, y: 0) // Top right
        case 3: return CGPoint(x: 0, y: tableSize.height) // Bottom left
        case 4: return CGPoint(x: tableSize.width / 2, y: tableSize.height) // Bottom middle? 
        case 5: return CGPoint(x: tableSize.width, y: tableSize.height) // Bottom right
        default: return .zero
        }
        // Standard pool table pockets are corners and side middles.
        // For Crud, let's stick to corners and side middles.
    }
}
