//
//  NotificationsView.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//
//  Rediseñado por Gemini con un estilo minimalista y moderno.
//

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
        case .donacion: return .blue
        case .evento:   return .orange
        case .alerta:   return .red
        }
    }
}

/// El modelo de datos principal para una notificación.
struct NotificationItem: Identifiable {
    let id = UUID()
    let type: NotificationType
    let title: String
    let message: String
    let date: Date
    var isRead: Bool = false
}



// MARK: - 2. Vista Principal de Notificaciones


struct NotificationsView: View {
    
    // --- Datos de Muestra (Mock Data) ---
    // Esto será reemplazado por tu ViewModel o conexión a la base de datos.
    @State private var notifications: [NotificationItem] = [
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
            message: "Tu númxero de teléfono ha sido actualizado exitosamente.",
            date: Date().addingTimeInterval(-3600 * 24), // Ayer
            isRead: true
        ),
        NotificationItem(
            type: .donacion,
            title: "Donación en Camino",
            message: "Tu donación de 'Artículos personales' ha sido recolectada.",
            date: Date().addingTimeInterval(-3600 * 48), // Hace 2 días
            isRead: true
        )
    ]
    
    // --- Cuerpo de la Vista ---
    var body: some View {
        NavigationStack {
            // Usamos una Lista para un estilo nativo y limpio
            List {
                ForEach(notifications) { notification in
                    NotificationRowView(notification: notification)
                }
                .onDelete(perform: deleteNotification) // Funcionalidad extra
            }
            .listStyle(.plain) // Estilo minimalista, sin bordes
            .navigationTitle("Notificaciones")
        }
    }
    
    /// Función para manejar el borrado de notificaciones
    private func deleteNotification(at offsets: IndexSet) {
        notifications.remove(atOffsets: offsets)
        // Aquí también llamarías a tu ViewModel para borrarlo de la BD
    }
}


// MARK: - 3. Componente de Fila de Notificación (Reusable View)

// Esta es la vista para CADA fila en la lista.

struct NotificationRowView: View {
    let notification: NotificationItem
    
    var body: some View {
        HStack(spacing: 16) {
            
            // --- Icono Semántico ---
            ZStack {
                Circle()
                    .fill(notification.type.iconColor.opacity(0.1)) // Fondo sutil
                    .frame(width: 44, height: 44)
                
                Image(systemName: notification.type.iconName)
                    .font(.headline)
                    .foregroundColor(notification.type.iconColor)
            }
            
            // --- Contenido de Texto ---
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.headline) // Título en negrita
                
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2) // Limita el mensaje a 2 líneas
                
                Text(notification.date, style: .relative) // "hace 5 min", "ayer"
                    .font(.caption)
                    
            }
            
            Spacer()
            
            // --- Indicador de No Leído ---
            if !notification.isRead {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.vertical, 8) // Espaciado vertical para que "respire"
    }
}


// MARK: - 4. Vista Previa (Preview)


#Preview {
    NotificationsView()
}
