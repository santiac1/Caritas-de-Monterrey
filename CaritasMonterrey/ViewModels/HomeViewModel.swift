// ViewModels/HomeViewModel.swift
import Foundation
import Supabase
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published private(set) var donations: [Donation] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false
    
    func loadStats(for userId: UUID?) async {
        guard let userId else {
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let fetched: [Donation] = try await SupabaseManager.shared.client
                .from("Donations")
                .select("*")
                .eq("user_id", value: userId.uuidString)
                .order("created_at", ascending: false)
                .execute()
                .value
            donations = fetched
            recompute()
        } catch {
            errorMessage = "Stats error: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    private func recompute() {
        let total = donations.count
        let inProcess = donations.filter { $0.status == .in_process }.count
        totalText = "\(total) donaciones"
        inProgressText = "\(inProcess) en proceso"
        if let last = donations.compactMap({ $0.created_at }).max() {
            lastDonationText = format(date: last)
        } else {
            lastDonationText = "—"
        }
    }

    // CORRECCIÓN: Eliminamos el enum Route interno y usamos AppRoute global
    // enum Route: Hashable { ... } <- ELIMINADO

    struct Promo: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let assetName: String?
        let systemFallback: String
        let route: AppRoute // <-- Usamos AppRoute
    }

    // UI copy
    @Published private(set) var screenTitle = "Inicio"
    @Published private(set) var headline = "Acciones rápidas"

    // Banner principal
    @Published private(set) var banner: Promo = .init(
        title: "Se parte del cambio, ¡Haz una donación ahora!",
        assetName: "polla_dona",
        systemFallback: "heart.circle.fill",
        route: .donateAction
    )

    // Tarjetas de acción
    @Published private(set) var secondaryCards: [Promo] = [
        .init(title: "Ver bazares cercanos", assetName: nil, systemFallback: "mappin.and.ellipse", route: .map),
        .init(title: "Mis donaciones",       assetName: nil, systemFallback: "gift.fill",          route: .myDonations)
    ]

    // Resumen (para el Home)
    @Published private(set) var totalText = "0 donaciones"
    @Published private(set) var inProgressText = "0 en proceso"
    @Published private(set) var lastDonationText = "—"

    // Permite inyectar desde fuera (por ejemplo, desde DonationsViewModel)
    func setDonations(_ donations: [Donation]) {
        self.donations = donations
        recompute()
    }

    private func format(date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateStyle = .medium
        return f.string(from: date)
    }
}
