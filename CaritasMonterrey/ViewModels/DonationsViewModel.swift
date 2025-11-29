import Foundation
import Supabase
import Combine

@MainActor
final class DonationsViewModel: ObservableObject {

    @Published private(set) var donations: [Donation] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var selectedFilter: DonationFilter = .all

    var filteredDonations: [Donation] {
        guard
            let rawStatus = selectedFilter.dbValue,
            let status = DonationDBStatus(rawValue: rawStatus)
        else { return donations }

        return donations.filter { $0.status == status }
    }

    func load(for userId: UUID?) async {
        guard let userId else { return }
        if isLoading { return }
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
            if (error as? CancellationError) != nil { return }
            errorMessage = error.localizedDescription
            print(errorMessage!)
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
