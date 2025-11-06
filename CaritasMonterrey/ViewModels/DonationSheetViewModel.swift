//
//  DonationSheetViewModel.swift
//  CaritasMonterrey
//
//  Created by Alumno on 05/11/25.
//

// ViewModels/DonationSheetViewModel.swift
import Foundation
import SwiftUI
import Combine

@MainActor
final class DonationSheetViewModel: ObservableObject {
    enum Kind: String, CaseIterable, Identifiable {
        case monetaria = "Monetaria"
        case ropa = "Ropa"
        case alimentos = "Alimentos"
        case utiles = "Útiles escolares"
        var id: String { rawValue }
    }

    @Published var kind: Kind = .monetaria
    @Published var amount: String = ""              // solo para monetaria
    @Published var notes: String = ""
    @Published var preferPickupAtBazaar: Bool = true
    @Published var selectedBazaarName: String = "Bazar Cáritas Centro"
    @Published private(set) var isSubmitting = false
    @Published private(set) var submitOK = false
    @Published var errorMessage: String?

    // mock de bazaars (futuro: conectar a Locations)
    let bazaars = [
        "Bazar Cáritas Centro",
        "Bazar Cáritas San Pedro",
        "Bazar Cáritas San Gilberto"
    ]

    var isValid: Bool {
        switch kind {
        case .monetaria:
            // valida monto numérico positivo
            if let n = Double(amount.replacingOccurrences(of: ",", with: ".")), n > 0 {
                return true
            }
            return false
        default:
            // para especie no pedimos monto
            return true
        }
    }

    func submit() async {
        guard isValid else {
            errorMessage = "Revisa los datos de tu donación."
            return
        }
        isSubmitting = true; errorMessage = nil
        // mock de envío
        try? await Task.sleep(nanoseconds: 800_000_000)
        isSubmitting = false
        submitOK = true
    }
}
