//
//  NotificationsView.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//
//  Rediseñado por Gemini con un estilo minimalista y moderno.
//

import SwiftUI

struct NotificationsView: View {
    @State private var notifications: [NotificationItem] = NotificationData.mockNotifications
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(notifications) { notification in
                    NotificationRowView(notification: notification)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color(.systemGray4).opacity(0.5), lineWidth: 0.6)
                                )
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                .padding(.vertical, 0)
                        )
                        .listRowBackground(Color.clear)
                }
                .onDelete(perform: deleteNotification)
            }
            .listStyle(.plain)
            .navigationTitle("Notificaciones")
        }
    }
    
    //Funcion para eliminar la notificcion
    private func deleteNotification(at offsets: IndexSet) {
        notifications.remove(atOffsets: offsets)
        // Aquí también llamarías a tu ViewModel para borrarlo de la BD
    }
}

// Componente de fila (sin cambios)
struct NotificationRowView: View {
    let notification: NotificationItem
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(notification.type.iconColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: notification.type.iconName)
                    .font(.headline)
                    .foregroundColor(notification.type.iconColor)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.headline)
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                Text(notification.date, style: .relative)
                    .font(.caption)
            }
            Spacer()
            if !notification.isRead {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NotificationsView()
}
