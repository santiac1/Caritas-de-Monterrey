//
//  ProfileViewModel.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import Foundation
import Supabase
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var companyName: String = ""
    @Published var rfc: String = ""
    @Published var address: String = ""
    @Published private(set) var isSaving = false
    @Published private(set) var showConfirmation = false
    @Published private(set) var errorMessage: String?

    func load(from profile: Profile?) {
        companyName = profile?.companyName ?? ""
        rfc = profile?.rfc ?? ""
        address = profile?.address ?? ""
    }

    func saveProfile(for profileId: UUID?, appState: AppState) async {
        guard let profileId else { return }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        do {
            try await SupabaseManager.shared.client
                .from("profiles")
                .update([
                    "company_name": companyName,
                    "rfc": rfc,
                    "address": address
                ])
                .eq("id", value: profileId)
                .execute()
            await appState.loadProfile(for: profileId)
            showConfirmation = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func dismissConfirmation() {
        showConfirmation = false
    }
}
