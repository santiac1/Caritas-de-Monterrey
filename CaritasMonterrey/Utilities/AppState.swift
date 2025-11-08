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
    
    // --- INICIO DE LA CORRECCIÓN ---
    // 1. Se elimina la propiedad 'private let client: SupabaseClient'
    // 2. Se reemplaza el 'init' complejo por uno simple.
    
    init() {
        authTask = Task { [weak self] in
            await self?.listenToAuthChanges()
        }
        Task { await refreshSession() }
    }
    // --- FIN DE LA CORRECCIÓN ---

    deinit {
        authTask?.cancel()
    }

    func refreshSession() async {
        authError = nil
        do {
            // 3. Se llama al 'shared' manager directamente
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
        // 3. Se llama al 'shared' manager directamente
        let response = try await SupabaseManager.shared.client.auth.signIn(email: email, password: password)
        session = response
        await loadProfile(for: response.user.id)
    }

    func signUp(email: String, password: String) async throws -> AuthResponse {
        authError = nil
        // 3. Se llama al 'shared' manager directamente
        return try await SupabaseManager.shared.client.auth.signUp(email: email, password: password)
    }

    func signOut() async {
        do {
            // 3. Se llama al 'shared' manager directamente
            try await SupabaseManager.shared.client.auth.signOut()
        } catch {
            authError = error.localizedDescription
        }
        session = nil
        profile = nil
    }

    func loadProfile(for userId: UUID) async {
        isLoadingProfile = true
        defer { isLoadingProfile = false }
        do {
            // 3. Se llama al 'shared' manager directamente
            let profile: Profile = try await SupabaseManager.shared.client
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            
            print("--- ✅ PERFIL CARGADO CON ÉXITO ---")
            print("Perfil decodificado: \(profile)")
            print("Rol del perfil: \(profile.role)")
            
            self.profile = profile
        } catch {
            print("--- ‼️ ERROR CRÍTICO AL CARGAR PERFIL ‼️ ---")
            print(error)
            authError = error.localizedDescription
            profile = nil
        }
    }

    private func listenToAuthChanges() async {
        // 3. Se llama al 'shared' manager directamente
        for await event in SupabaseManager.shared.client.auth.authStateChanges {
            switch event.event {
            case .signedIn, .initialSession, .tokenRefreshed:
                if let session = event.session {
                    await MainActor.run {
                        self.session = session
                    }
                    await loadProfile(for: session.user.id)
                }
            case .signedOut:
                await MainActor.run {
                    self.session = nil
                    self.profile = nil
                }
            default:
                break
            }
        }
    }
}
