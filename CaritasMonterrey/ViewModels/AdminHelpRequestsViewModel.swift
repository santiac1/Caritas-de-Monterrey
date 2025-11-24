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
    @Published var currentFilter: DonationFilter = .inProcess
    @Published var currentSort: SortOrder = .newest

    func loadHelpRequests() async {
        isLoading = true
        errorMessage = nil
        do {
            var query = SupabaseManager.shared.client
                .from("Donations")
                .select()

            if let status = currentFilter.dbValue {
                query = query.eq("status", value: status)
            }

            query = query.order("created_at", ascending: currentSort == .oldest) as! PostgrestFilterBuilder

            let fetched: [Donation] = try await query
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

    @discardableResult
    func approveDonation(_ donation: Donation, pickupDate: Date?) async -> Bool {
        errorMessage = nil
        struct UpdatePayload: Encodable {
            let status: String
            let pickup_date: Date?
        }
        let payload = UpdatePayload(
            status: DonationDBStatus.accepted.rawValue,
            pickup_date: pickupDate
        )

        do {
            try await SupabaseManager.shared.client
                .from("Donations")
                .update(payload)
                .eq("id", value: donation.id)
                .execute()
            await loadHelpRequests()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @discardableResult
    func markAsReceived(_ donation: Donation) async -> Bool {
        errorMessage = nil
        struct UpdatePayload: Encodable {
            let status: String
        }
        let payload = UpdatePayload(status: DonationDBStatus.received.rawValue)

        do {
            try await SupabaseManager.shared.client
                .from("Donations")
                .update(payload)
                .eq("id", value: donation.id)
                .execute()
            await loadHelpRequests()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
