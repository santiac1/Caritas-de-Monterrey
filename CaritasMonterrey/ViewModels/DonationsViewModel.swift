import Foundation
import Supabase
import Combine

@MainActor
final class DonationsViewModel: ObservableObject {

    // Enum de filtros basado en tu enum de BD
    enum DBFilter: CaseIterable, Hashable {
        case all
        case inProcess
        case accepted
        case rejected
        case returned

        var title: String {
            switch self {
            case .all:       return "Todas"
            case .inProcess: return "En proceso"
            case .accepted:  return "Aceptadas"
            case .rejected:  return "Rechazadas"
            case .returned:  return "Devueltas"
            }
        }

        var status: DonationDBStatus? {
            switch self {
            case .all:       return nil
            case .inProcess: return .in_process
            case .accepted:  return .accepted
            case .rejected:  return .rejected
            case .returned:  return .returned
            }
        }
    }

    @Published private(set) var donations: [Donation] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var selectedFilter: DBFilter = .all

    var filteredDonations: [Donation] {
        guard let s = selectedFilter.status else { return donations }
        return donations.filter { $0.status == s }
    }

    func load(for userId: UUID?) async {
        guard let userId else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result: [Donation] = try await SupabaseManager.shared.client
                .from("Donations")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value

            donations = result
        } catch {
            errorMessage = error.localizedDescription
            donations = []
        }
    }

    func refresh(for userId: UUID?) async {
        await load(for: userId)
    }

    func reset() {
        donations = []
        selectedFilter = .all
        isLoading = false
        errorMessage = nil
    }
}
