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
struct NotificationItem: Identifiable, Codable {
    let id: UUID
    let user_id: UUID
    var title: String
    var message: String
    var type: NotificationCategory
    var created_at: Date?
    var isRead: Bool
}

// MARK: - Datos de muestra (mock)
struct NotificationData {
    static let mockNotifications: [NotificationItem] = [
        NotificationItem(
            id: UUID(),
            user_id: UUID(),
            title: "Donación Completada",
            message: "Tu donación de 'Ropa de invierno' fue recibida. ¡Muchas gracias!",
            type: .donation,
            created_at: Date().addingTimeInterval(-300), // Hace 5 minutos
            isRead: false
        ),
        NotificationItem(
            id: UUID(),
            user_id: UUID(),
            title: "Evento Próximo",
            message: "No olvides la colecta en el Bazar Emilio Carranza mañana a las 10:00 a.m.",
            type: .event,
            created_at: Date().addingTimeInterval(-3600 * 4), // Hace 4 horas
            isRead: false
        ),
        NotificationItem(
            id: UUID(),
            user_id: UUID(),
            title: "Actualización de Perfil",
            message: "Tu número de teléfono ha sido actualizado exitosamente.",
            type: .alert,
            created_at: Date().addingTimeInterval(-3600 * 24), // Ayer
            isRead: true
        ),
        NotificationItem(
            id: UUID(),
            user_id: UUID(),
            title: "Donación en Camino",
            message: "Tu donación de 'Artículos personales' ha sido recolectada.",
            type: .donation,
            created_at: Date().addingTimeInterval(-3600 * 48), // Hace 2 días
            isRead: true
        ),
        NotificationItem(
            id: UUID(),
            user_id: UUID(),
            title: "Donación No Aceptada",
            message: "Tu donación de 'Ropa' no ha pasado los filtros de calidad.",
            type: .alert,
            created_at: Date().addingTimeInterval(-3600 * 57), // Hace 2 días
            isRead: false
        )
    ]
}
