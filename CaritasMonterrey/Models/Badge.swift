import Foundation

struct Badge: Identifiable, Codable, Hashable {
    let id: Int
    let slug: String
    let name: String
    let description: String
    let icon_name: String // Puede ser un SF Symbol o emoji
    
    // Propiedad opcional para saber si el usuario la tiene (join result)
    var earned_at: Date?
    
    var isEarned: Bool {
        return earned_at != nil
    }
    
    enum CodingKeys: String, CodingKey {
        case id, slug, name, description, icon_name, earned_at
    }
}

