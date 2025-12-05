import Foundation
import Supabase
import Combine

@MainActor
final class AdminHelpRequestsViewModel: ObservableObject {
    @Published private(set) var donations: [Donation] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    // Filtros y Ordenamiento
    @Published var currentFilter: DonationFilter = .inProcess
    @Published var currentSort: SortOrder = .newest
    
    // Búsqueda
    @Published var searchText: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Debounce search text to avoid too many requests
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.loadHelpRequests()
                }
            }
            .store(in: &cancellables)
    }

    func loadHelpRequests() async {
        // If already loading, maybe we should cancel previous? 
        // For simplicity, we'll let it run but ideally we'd use a task handle.
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            // Construir filtros
            var query = SupabaseManager.shared.client
                .from("Donations")
                .select()
            
            // Lógica de búsqueda por ID (prioritaria)
            // Si hay texto y parece un ID (ej: "#123" o "123")
            let cleanedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "#", with: "")
            
            if !cleanedSearch.isEmpty, let searchId = Int(cleanedSearch) {
                // Si buscamos por ID, ignoramos el filtro de estado para buscar en TODAS
                query = query.eq("id", value: searchId)
            } else {
                // Comportamiento normal con filtros
                if let status = currentFilter.dbValue {
                    query = query.eq("status", value: status)
                }
            }

            // Se aplica orden
            let fetched: [Donation] = try await query
                .order("created_at", ascending: currentSort == .oldest)
                .execute()
                .value

            // Cargar donantes
            let userIds = Array(Set(fetched.map { $0.user_id }))
            print("DEBUG: User IDs to fetch: \(userIds)")
            var profiles: [UUID: Profile] = [:]
            
            if !userIds.isEmpty {
                let profileList: [Profile] = try await SupabaseManager.shared.client
                    .from("profiles")
                    .select()
                    .in("id", values: userIds)
                    .execute()
                    .value
                profileList.forEach { profiles[$0.id] = $0 }
                print("DEBUG: Fetched Profiles: \(profileList)")
            }

            // Unir donacion con respectivo donador
            donations = fetched.map { donation in
                var donation = donation
                if let profile = profiles[donation.user_id] {
                    let fullName = [profile.firstName, profile.lastName]
                        .compactMap { $0 }
                        .joined(separator: " ")
                        .trimmingCharacters(in: .whitespaces)
                    donation.donorName = fullName.isEmpty ? profile.username : fullName
                }
                return donation
            }
        } catch {
            if (error as? CancellationError) != nil { return }
            errorMessage = error.localizedDescription
            print(errorMessage!)
        }
    }

    @discardableResult
    func approveDonation(_ donation: Donation, pickupDate: Date?) async -> Bool {
        errorMessage = nil
        struct UpdatePayload: Encodable {
            let status: String
            let pickup_date: Date?
        }
        let payload = UpdatePayload(
            status: DonationDBStatus.accepted.rawValue,
            pickup_date: pickupDate
        )

        do {
            try await SupabaseManager.shared.client
                .from("Donations")
                .update(payload)
                .eq("id", value: donation.id)
                .execute()
            await loadHelpRequests()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @discardableResult
    func markAsReceived(_ donation: Donation) async -> Bool {
        errorMessage = nil
        struct UpdatePayload: Encodable {
            let status: String
        }
        let payload = UpdatePayload(status: DonationDBStatus.received.rawValue)

        do {
            try await SupabaseManager.shared.client
                .from("Donations")
                .update(payload)
                .eq("id", value: donation.id)
                .execute()
            await loadHelpRequests()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
