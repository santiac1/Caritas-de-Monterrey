import Combine
import Foundation
import SwiftUI
import Supabase

@MainActor
final class AppState: ObservableObject {
    @Published var session: Session?
    @Published var profile: Profile?
    @Published var isLoadingProfile = false
    @Published var authError: String?

    private var authTask: Task<Void, Never>?

    // ✅ Rol efectivo para routing (company -> user)
    enum EffectiveRole { case user, admin }

    /// Usa el perfil cargado y normaliza el rol:
    /// - "admin" => .admin
    /// - cualquier otro ("user", "company", nil, etc.) => .user
    var effectiveRole: EffectiveRole {
        guard let role = profile?.role.lowercased() else { return .user }
        return role == "admin" ? .admin : .user
    }

    /// Helpers por si te sirven en otras vistas
    var isAdmin: Bool { effectiveRole == .admin }
    var isUser:  Bool { effectiveRole == .user }

    init() {
        authTask = Task { [weak self] in
            await self?.listenToAuthChanges()
        }
        Task { await refreshSession() }
    }

    deinit { authTask?.cancel() }

    func refreshSession() async {
        authError = nil
        do {
            let currentSession = try await SupabaseManager.shared.client.auth.session
            session = currentSession
            await loadProfile(for: currentSession.user.id)
        } catch {
            authError = error.localizedDescription
            session = nil
            profile = nil
        }
    }

    func signIn(email: String, password: String) async throws {
        authError = nil
        let response = try await SupabaseManager.shared.client.auth.signIn(email: email, password: password)
        session = response
        await loadProfile(for: response.user.id)
    }

    func signUp(email: String, password: String) async throws -> AuthResponse {
        authError = nil
        return try await SupabaseManager.shared.client.auth.signUp(email: email, password: password)
    }

    func signOut() async {
        do { try await SupabaseManager.shared.client.auth.signOut() }
        catch { authError = error.localizedDescription }
        session = nil
        profile = nil
    }

    func loadProfile(for userId: UUID, silent: Bool = false) async {
        if !silent { isLoadingProfile = true }
        defer { if !silent { isLoadingProfile = false } }
        do {
            let profile: Profile = try await SupabaseManager.shared.client
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value

            self.profile = profile
        } catch {
            authError = error.localizedDescription
            profile = nil
        }
    }

    private func listenToAuthChanges() async {
        for await event in SupabaseManager.shared.client.auth.authStateChanges {
            switch event.event {
            case .signedIn, .initialSession, .tokenRefreshed:
                if let session = event.session {
                    await MainActor.run { self.session = session }
                    await loadProfile(for: session.user.id)
                }
            case .signedOut:
                await MainActor.run {
                    self.session = nil
                    self.profile = nil
                }
            default: break
            }
        }
    }
}
