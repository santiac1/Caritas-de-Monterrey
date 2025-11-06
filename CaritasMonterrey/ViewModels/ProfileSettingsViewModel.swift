import Foundation
import Supabase
import Combine

@MainActor
final class ProfileSettingsViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phone: String = ""

    @Published private(set) var isSaving = false
    @Published private(set) var didSave = false
    @Published var errorMessage: String?

    func loadProfileData(appState: AppState) {
        username = appState.profile?.username ?? ""
        firstName = appState.profile?.firstName ?? ""
        lastName = appState.profile?.lastName ?? ""
        phone = appState.profile?.phone ?? ""
        errorMessage = nil
    }

    func saveProfile(userId: UUID) async {
        isSaving = true
        didSave = false
        errorMessage = nil
        defer { isSaving = false }

        let payload = ProfileUpdatePayload(
            username: username.isEmpty ? nil : username,
            first_name: firstName.isEmpty ? nil : firstName,
            last_name: lastName.isEmpty ? nil : lastName,
            phone: phone.isEmpty ? nil : phone
        )

        do {
            try await SupabaseManager.shared.client
                .from("profiles")
                .update(payload)
                .eq("id", value: userId)
                .execute()
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetSaveState() {
        didSave = false
    }
}

private struct ProfileUpdatePayload: Encodable {
    let username: String?
    let first_name: String?
    let last_name: String?
    let phone: String?
}
