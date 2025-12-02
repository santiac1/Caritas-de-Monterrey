import Foundation
import Supabase
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var companyName: String = ""
    @Published var rfc: String = ""
    @Published var address: String = ""
    @Published private(set) var isSaving = false
    @Published private(set) var showConfirmation = false
    @Published private(set) var errorMessage: String?
    
    // Badges
    @Published var badges: [Badge] = []
    @Published var isLoadingBadges = false

    func load(from profile: Profile?) {
        companyName = profile?.companyName ?? ""
        rfc = profile?.rfc ?? ""
        address = profile?.address ?? ""
    }

    func saveProfile(for profileId: UUID?, appState: AppState) async {
        guard let profileId else { return }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        do {
            try await SupabaseManager.shared.client
                .from("profiles")
                .update([
                    "company_name": companyName,
                    "rfc": rfc,
                    "address": address
                ])
                .eq("id", value: profileId)
                .execute()
            await appState.loadProfile(for: profileId)
            showConfirmation = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Badges Logic
    
    func loadBadges(for userId: UUID?) async {
        guard let userId else { return }
        isLoadingBadges = true
        defer { isLoadingBadges = false }
        
        do {
            // 1. Cargar todas las definiciones de insignias
            let allBadges: [Badge] = try await SupabaseManager.shared.client
                .from("badges")
                .select()
                .order("id", ascending: true)
                .execute()
                .value
            
            // 2. Cargar las insignias que el usuario ya ganó
            struct UserBadge: Decodable {
                let badge_id: Int
                let earned_at: Date
            }
            
            let userBadges: [UserBadge] = try await SupabaseManager.shared.client
                .from("user_badges")
                .select("badge_id, earned_at")
                .eq("user_id", value: userId)
                .execute()
                .value
            
            // 3. Combinar la información
            self.badges = allBadges.map { badge in
                var modifiedBadge = badge
                if let earned = userBadges.first(where: { $0.badge_id == badge.id }) {
                    modifiedBadge.earned_at = earned.earned_at
                }
                return modifiedBadge
            }
            
        } catch {
            print("Error loading badges: \(error)")
            // No mostramos error en UI para no bloquear la vista principal por algo secundario
        }
    }

    func dismissConfirmation() {
        showConfirmation = false
    }
}
