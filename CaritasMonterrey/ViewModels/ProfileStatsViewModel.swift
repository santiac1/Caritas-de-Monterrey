import Foundation
import Supabase
import Combine

@MainActor
final class ProfileStatsViewModel: ObservableObject {
    struct ProfileStat: Identifiable {
        let id = UUID()
        let title: String
        let value: String
        let systemIcon: String
    }

    @Published private(set) var stats: [ProfileStat] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    func loadStats(for userId: UUID?) async {
        guard let userId else {
            stats = []
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let donations: [Donation] = try await SupabaseManager.shared.client
                .from("Donations")
                .select()
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value

            let total = donations.count
            let inProcess = donations.filter { $0.status == "en_proceso" }.count
            let completed = donations.filter { $0.status == "completada" }.count

            stats = [
                ProfileStat(title: "Donaciones totales", value: "\(total)", systemIcon: "hands.sparkles.fill"),
                ProfileStat(title: "En proceso", value: "\(inProcess)", systemIcon: "clock.badge.checkmark"),
                ProfileStat(title: "Completadas", value: "\(completed)", systemIcon: "checkmark.seal.fill")
            ]
        } catch {
            errorMessage = error.localizedDescription
            stats = []
        }
    }
}
