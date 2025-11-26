//
//  NotificationsView.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//
//
//  NotificationsView.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import SwiftUI

struct NotificationsView: View {
    @StateObject var viewModel = NotificationsViewModel()

    var body: some View {
        List {
            if viewModel.notifications.isEmpty {
                // ✅ CORRECCIÓN: description espera un Text(), no un String directo.
                ContentUnavailableView(
                    "Sin notificaciones",
                    systemImage: "bell.slash",
                    description: Text("Te avisaremos cuando haya actualizaciones sobre tus donaciones.")
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } else {
                ForEach(viewModel.notifications) { notification in
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
        }
        .listStyle(.plain)
        .navigationTitle("Notificaciones")
        .task {
            await viewModel.loadNotifications()
        }
        .refreshable {
            await viewModel.loadNotifications()
        }
    }

    private func deleteNotification(at offsets: IndexSet) {
        let idsToDelete = offsets.map { viewModel.notifications[$0].id }

        Task {
            do {
                for id in idsToDelete {
                    try await viewModel.deleteNotification(id: id)
                }
                viewModel.notifications.remove(atOffsets: offsets)
            } catch {
                print("Error deleting:", error)
            }
        }
    }
}
