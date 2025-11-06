//
//  AdminHelpRequestsViewModel.swift
//  CaritasMonterrey
//
//  Created by OpenAI on 2024.
//

import Foundation
import Supabase
import Combine

@MainActor
final class AdminHelpRequestsViewModel: ObservableObject {
    @Published private(set) var donations: [Donation] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    func loadHelpRequests() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetched: [Donation] = try await SupabaseManager.shared.client
                .from("Donations")
                .select()
                .eq("status", value: "solicitud_ayuda")
                .order("created_at", ascending: false)
                .execute()
                .value

            let userIds = Array(Set(fetched.map { $0.user_id }))
            var profiles: [UUID: Profile] = [:]
            if !userIds.isEmpty {
                let profileList: [Profile] = try await SupabaseManager.shared.client
                    .from("profiles")
                    .select()
                    .in("id", values: userIds)
                    .execute()
                    .value
                profileList.forEach { profiles[$0.id] = $0 }
            }

            donations = fetched.map { donation in
                var donation = donation
                if let profile = profiles[donation.user_id] {
                    let fullName = [profile.firstName, profile.lastName]
                        .compactMap { $0 }
                        .joined(separator: " ")
                        .trimmingCharacters(in: .whitespaces)
                    donation.donorName = fullName.isEmpty ? profile.username : fullName
                }
                return donation
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
