//
//  BazaarManagementViewModel.swift
//  CaritasMonterrey
//
//  Created by OpenAI on 2024.
//

import Foundation
import Supabase
import Combine

@MainActor
final class BazaarManagementViewModel: ObservableObject {
    @Published private(set) var locations: [Location] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    func loadLocations() async {
        isLoading = true
        errorMessage = nil
        do {
            locations = try await SupabaseManager.shared.client
                .from("Locations")
                .select()
                .order("name")
                .execute()
                .value
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func createLocation(_ payload: LocationPayload) async {
        do {
            try await SupabaseManager.shared.client
                .from("Locations")
                .insert(payload)
                .execute()
            await loadLocations()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateLocation(_ id: Int, with payload: LocationPayload) async {
        do {
            try await SupabaseManager.shared.client
                .from("Locations")
                .update(payload)
                .eq("id", value: id)
                .execute()
            await loadLocations()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteLocation(_ id: Int) async {
        do {
            try await SupabaseManager.shared.client
                .from("Locations")
                .delete()
                .eq("id", value: id)
                .execute()
            await loadLocations()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct LocationPayload: Encodable {
    var name: String
    var latitude: Double
    var longitude: Double
    var address: String
}
