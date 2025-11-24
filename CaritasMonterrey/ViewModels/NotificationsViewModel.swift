//
//  OnboardingViewModel.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import Foundation
import Supabase
import Combine

@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published var notifications: [AppNotification] = []

    private let client = SupabaseManager.shared.client

    func loadNotifications() async {
        guard let user = client.auth.currentUser else { return }

        do {
            let result: [AppNotification] = try await client
                .from("notifications")
                .select()
                .eq("user_id", value: user.id)
                .order("created_at", ascending: false)
                .execute()
                .value

            self.notifications = result

        } catch {
            print("Error loading notifications:", error)
        }
    }
    
    func deleteNotification(id: UUID) async throws {
        try await client
            .from("notifications")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }


}
