// ViewModels/HomeViewModel.swift
import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    // Navegación (coincide con tu HomeView actual)
    enum Route: Hashable {
        case donateV
        case mapV
        case donationsV
    }

    struct Promo: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let assetName: String?
        let systemFallback: String
        let route: Route
    }

    // UI copy
    @Published private(set) var screenTitle = "Inicio"
    @Published private(set) var headline = "Acciones rápidas"

    // Banner principal
    @Published private(set) var banner: Promo = .init(
        title: "Se parte del cambio, ¡Haz una donación ahora!",
        assetName: "polla_dona",               // cambia si tu asset tiene otro nombre
        systemFallback: "heart.circle.fill",
        route: .donateV
    )

    // Tarjetas de acción
    @Published private(set) var secondaryCards: [Promo] = [
        .init(title: "Ver bazares cercanos", assetName: nil, systemFallback: "mappin.and.ellipse", route: .mapV),
        .init(title: "Mis donaciones",       assetName: nil, systemFallback: "gift.fill",          route: .donationsV)
    ]

    // Resumen (para el Home)
    @Published private(set) var totalText = "0 donaciones"
    @Published private(set) var inProgressText = "0 en proceso"
    @Published private(set) var lastDonationText = "—"

    // Fuente temporal (mock). Luego la jalas de tu capa de datos.
    private var allDonations: [Donation] = Donation.sampleDonations

    // Permite inyectar desde fuera (por ejemplo, desde DonationsViewModel)
    func setDonations(_ donations: [Donation]) {
        self.allDonations = donations
    }

    func onAppear() {
        // Totales
        let total = allDonations.count
        let inProcess = allDonations.filter { $0.status == .in_process }.count

        totalText = "\(total) "
        inProgressText = "\(inProcess)"

        if let last = allDonations
            .compactMap({ $0.created_at })
            .max() // encuentra la fecha más reciente
        {
            lastDonationText = format(date: last)
        } else {
            lastDonationText = "—"
        }
    }

    private func format(date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateStyle = .medium
        return f.string(from: date)
    }
}
