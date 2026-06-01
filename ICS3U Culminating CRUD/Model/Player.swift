import Foundation

// MARK: - Player
@Observable
class Player: Identifiable {
    // MARK: - Stored properties
    let id: UUID = UUID()
    var name: String
    var lives: Int = 3
    var isActive: Bool = false
    
    // MARK: - Initializer
    init(name: String) {
        self.name = name
    }
}
