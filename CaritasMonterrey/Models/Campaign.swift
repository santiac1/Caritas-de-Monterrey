import Foundation

struct Campaign: Identifiable, Codable, Hashable {
    let id: Int
    let created_at: Date?
    let title: String
    let description: String
    let image_url: String?
    let start_date: Date
    let end_date: Date
    let is_active: Bool
    
    var isCurrentlyActive: Bool {
        guard is_active else { return false }
        let now = Date()
        return now >= start_date && now <= end_date
    }
    
    var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let start = formatter.string(from: start_date)
        let end = formatter.string(from: end_date)
        return "\(start) - \(end)"
    }
}

struct CampaignPayload: Encodable {
    let title: String
    let description: String
    let image_url: String?
    let start_date: Date
    let end_date: Date
    let is_active: Bool
}
