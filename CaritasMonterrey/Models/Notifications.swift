import Foundation
import SwiftUI

enum NotificationCategory: String, Codable {
    case donation
    case event
    case alert

    var iconName: String {
        switch self {
        case .donation: return "gift.fill"
        case .event: return "calendar"
        case .alert: return "bell.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .donation: return .accentColor
        case .event: return .orange
        case .alert: return .pink
        }
    }
}

struct NotificationItem: Identifiable, Codable {
    let id: UUID
    let user_id: UUID
    var title: String
    var message: String
    var type: NotificationCategory
    var created_at: Date?
    var isRead: Bool
}

struct NotificationData {
    static let mockNotifications: [NotificationItem] = [
        NotificationItem(
            id: UUID(),
            user_id: UUID(),
            title: "Donación aprobada",
            message: "Tu donación fue aprobada por el administrador.",
            type: .donation,
            created_at: Date(),
            isRead: false
        )
    ]
}
