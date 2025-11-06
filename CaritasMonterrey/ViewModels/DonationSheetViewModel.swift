import Foundation
import SwiftUI
import Supabase
import Combine

@MainActor
final class DonationSheetViewModel: ObservableObject {
    enum DonationType: String, CaseIterable, Identifiable {
        case monetaria = "Monetaria"
        case ropa = "Ropa"
        case alimentos = "Alimentos"
        case utiles = "Útiles escolares"

        var id: String { rawValue }
    }

    @Published var selectedType: DonationType = .monetaria
    @Published var amount: String = ""
    @Published var notes: String = ""
    @Published var preferPickupAtBazaar: Bool = true {
        didSet {
            if preferPickupAtBazaar && selectedBazaar == nil {
                selectedBazaar = bazaars.first
            }
        }
    }
    @Published var bazaars: [Location] = []
    @Published var selectedBazaar: Location?
    @Published var helpNeeded: Bool = false
    @Published var shippingWeight: String = ""
    @Published private(set) var isSubmitting = false
    @Published var submitOK = false
    @Published var errorMessage: String?

    var currentUserId: UUID?

    private let client = SupabaseManager.shared.client
    private var hasLoadedBazaars = false

    var isValid: Bool {
        if selectedType == .monetaria {
            guard let value = Double(amount.replacingOccurrences(of: ",", with: ".")), value > 0 else { return false }
        }
        if helpNeeded && shippingWeight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        if preferPickupAtBazaar && selectedBazaar == nil {
            return false
        }
        return currentUserId != nil
    }

    func loadBazaars() async {
        guard !hasLoadedBazaars else { return }
        hasLoadedBazaars = true
        errorMessage = nil

        do {
            let response: [Location] = try await client
                .from("Locations")
                .select()
                .order("name")
                .execute()
                .value
            bazaars = response
            if selectedBazaar == nil {
                selectedBazaar = response.first
            }
        } catch {
            errorMessage = error.localizedDescription
            hasLoadedBazaars = false
        }
    }

    func submit() async {
        guard isValid, let userId = currentUserId else {
            errorMessage = "Revisa los datos de tu donación."
            return
        }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        let status = helpNeeded ? "solicitud_ayuda" : "en_proceso"
        let donation = NewDonation(
            user_id: userId,
            name: selectedType.rawValue,
            type: selectedType.rawValue,
            status: status,
            help_needed: helpNeeded,
            shipping_weight: helpNeeded ? shippingWeight : nil,
            notes: notes.isEmpty ? nil : notes,
            amount: selectedType == .monetaria ? Double(amount.replacingOccurrences(of: ",", with: ".")) : nil,
            prefer_pickup_at_bazaar: preferPickupAtBazaar,
            location_id: preferPickupAtBazaar ? selectedBazaar?.id : nil
        )

        do {
            try await client
                .from("Donations")
                .insert(donation)
                .execute()
            submitOK = true
        } catch {
            errorMessage = error.localizedDescription
            submitOK = false
        }
    }
}

private struct NewDonation: Encodable {
    let user_id: UUID
    let name: String
    let type: String
    let status: String
    let help_needed: Bool
    let shipping_weight: String?
    let notes: String?
    let amount: Double?
    let prefer_pickup_at_bazaar: Bool
    let location_id: Int?
}
