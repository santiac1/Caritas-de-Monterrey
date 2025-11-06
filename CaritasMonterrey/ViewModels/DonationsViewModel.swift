//
//  DonationsViewModel.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import Foundation
import Supabase
import Combine

@MainActor
final class DonationsViewModel: ObservableObject {
    @Published private(set) var donations: [Donation] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    func loadMockDonations() {
        donations = Donation.sampleDonations
    }

    func loadDonations(for userId: UUID?) async {
        guard let userId else { return }
        isLoading = true
        errorMessage = nil
        do {
            let result: [Donation] = try await SupabaseManager.shared.client.database
                .from("Donations")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value
            donations = result
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func reset() {
        donations.removeAll()
        errorMessage = nil
        isLoading = false
    }
}
