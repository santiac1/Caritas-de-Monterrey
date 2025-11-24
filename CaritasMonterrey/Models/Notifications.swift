//
//  NotificationsModel.swift
//  CaritasMonterrey
//
//  Creado el 06/11/25 adaptado con datos corregidos.
//

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

// MARK: - Modelo de Notificación
struct AppNotification: Identifiable, Codable {
    let id: UUID
    let user_id: UUID
    var title: String
    var message: String
    var type: NotificationCategory
    var created_at: Date?
    var isRead: Bool
    
    enum CodingKeys: String, CodingKey {
            case id
            case user_id
            case title
            case message
            case type
            case created_at
            case isRead = "is_read"
        }
}
