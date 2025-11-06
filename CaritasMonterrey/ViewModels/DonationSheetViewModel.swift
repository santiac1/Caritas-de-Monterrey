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
    @Published var preferPickupAtBazaar: Bool = true
    @Published var selectedBazaarName: String = "Bazar Cáritas Centro"
    @Published var helpNeeded: Bool = false
    @Published var shippingWeight: String = ""
    @Published private(set) var isSubmitting = false
    @Published var submitOK = false
    @Published var errorMessage: String?

    var currentUserId: UUID?

    let bazaars = [
        "Bazar Cáritas Centro",
        "Bazar Cáritas San Pedro",
        "Bazar Cáritas San Gilberto"
    ]

    private let client = SupabaseManager.shared.client

    var isValid: Bool {
        if selectedType == .monetaria {
            guard let value = Double(amount.replacingOccurrences(of: ",", with: ".")), value > 0 else { return false }
        }
        if helpNeeded && shippingWeight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        return currentUserId != nil
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
            bazaar_name: preferPickupAtBazaar ? selectedBazaarName : nil
        )

        do {
            try await client.database
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
    let bazaar_name: String?
}
