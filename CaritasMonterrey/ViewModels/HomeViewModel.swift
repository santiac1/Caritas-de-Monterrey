//
//  OnboardingViewModel.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

// ViewModels/HomeViewModel.swift
import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Navegación
    enum Route: Hashable {
        case donateV      // abre el DonationSheet (mock por ahora)
        case mapV           // mapaView
        case donationsV     // DonationsView existente
    }

    // MARK: - UI Models
    struct Promo: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let assetName: String?
        let systemFallback: String
        let route: Route
    }

    // MARK: - Textos de pantalla
    @Published private(set) var screenTitle: String = "Inicio"
    @Published private(set) var actionsHeadline: String = "Acciones rápidas"
    @Published private(set) var statsHeadline: String = "Tus estadísticas"

    // MARK: - Banner principal
    @Published private(set) var banner: Promo = .init(
        title: "Haz una donación ahora!",
        assetName: "home_heart",            // cambia si tu asset tiene otro nombre
        systemFallback: "heart.circle.fill",
        route: .donateV
    )

    // MARK: - Tarjetas de acción
    @Published private(set) var secondaryCards: [Promo] = [
        .init(title: "Ver bazares cercanos",
              assetName: nil,
              systemFallback: "mappin.and.ellipse",
              route: .mapV),
        .init(title: "Mis donaciones",
              assetName: nil,
              systemFallback: "gift.fill",
              route: .donationsV)
    ]

    // MARK: - Estadísticas (resumen Home)
    @Published private(set) var totalText: String = "0 donaciones"
    @Published private(set) var inProgressText: String = "0 en proceso"
    @Published private(set) var lastDonationText: String = "—"

    // MARK: - Fuente temporal (mock)
    private var allDonations: [Donation] = Donation.sampleDonations

    // MARK: - Lifecycle
    func onAppear() {
        recomputeStats()
    }

    // Si más adelante confirmas una donación desde el Sheet, puedes llamar esto:
    func registerDonation(_ donation: Donation) {
        allDonations.append(donation)
        recomputeStats()
    }

    // MARK: - Helpers
    private func recomputeStats() {
        let total = allDonations.count
        let inProcess = allDonations.filter { $0.status == .enProceso }.count

        totalText = "\(total) \(total == 1 ? "donación" : "donaciones")"
        inProgressText = "\(inProcess) \(inProcess == 1 ? "en proceso" : "en proceso")"

        if let last = allDonations.sorted(by: { $0.date > $1.date }).first {
            lastDonationText = formatted(date: last.date)   // solo fecha
        } else {
            lastDonationText = "—"
        }
    }

    private func formatted(date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateStyle = .medium
        return f.string(from: date)
    }
}
