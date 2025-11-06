//
//  NotificationsModel.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import Foundation
import SwiftUI

// MARK: - 1. Modelo de Datos de Notificación

// Esto define cómo se ve una notificación.
// En el futuro, lo cargarás desde tu base de datos.

/// Define el tipo de notificación para mostrar el icono y color correctos.
enum NotificationType {
    case donacion
    case evento
    case alerta
    
    /// El icono SFSymbol a usar
    var iconName: String {
        switch self {
        case .donacion: return "gift.fill"
        case .evento:   return "calendar"
        case .alerta:   return "bell.fill"
        }
    }
    
    /// El color de fondo para el icono
    var iconColor: Color {
        switch self {
        case .donacion: return .accentColor
        case .evento:   return .orangeCaritas
        case .alerta:   return .magentaCaritas
        }
    }
}

/// El modelo de datos principal para una notificación.
/// Esta estructura será la que cargues desde Supabase o tu BD.
struct NotificationItem: Identifiable {
    let id = UUID() // Opcional: Podrías usar el ID de tu base de datos
    let type: NotificationType
    let title: String
    let message: String
    let date: Date
    var isRead: Bool = false
}


// MARK: - 2. Datos de Muestra (Mock Data)

// Aquí centralizamos los datos de muestra.
// En el futuro, un ViewModel reemplazará esto con datos reales de la BD.
struct NotificationData {
    
    /// Lista estática de notificaciones para usar en Vistas y Previews
    static let mockNotifications: [NotificationItem] = [
        NotificationItem(
            type: .donacion,
            title: "Donación Completada",
            message: "Tu donación de 'Ropa de invierno' fue recibida. ¡Muchas gracias!",
            date: Date().addingTimeInterval(-300), // Hace 5 minutos
            isRead: false
        ),
        NotificationItem(
            type: .evento,
            title: "Evento Próximo",
            message: "No olvides la colecta en el Bazar Emilio Carranza mañana a las 10:00 a.m.",
            date: Date().addingTimeInterval(-3600 * 4), // Hace 4 horas
            isRead: false
        ),
        NotificationItem(
            type: .alerta,
            title: "Actualización de Perfil",
            message: "Tu número de teléfono ha sido actualizado exitosamente.",
            date: Date().addingTimeInterval(-3600 * 24), // Ayer
            isRead: true
        ),
        NotificationItem(
            type: .donacion,
            title: "Donación en Camino",
            message: "Tu donación de 'Artículos personales' ha sido recolectada.",
            date: Date().addingTimeInterval(-3600 * 48), // Hace 2 días
            isRead: true
        ),
        NotificationItem(
            type: .alerta,
            title: "No fue aceptada tu donacion",
            message: "Tu donación de 'Ropa' no ha pasado los filtros de calidad.",
            date: Date().addingTimeInterval(-3600 * 57), // Hace 2 días
            isRead: false
        )
    ]
}

