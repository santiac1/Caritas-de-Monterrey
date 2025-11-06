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

    private let client: SupabaseClient
    private var authTask: Task<Void, Never>?

    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
        authTask = Task { [weak self] in
            await self?.listenToAuthChanges()
        }
        Task { await refreshSession() }
    }

    deinit {
        authTask?.cancel()
    }

    func refreshSession() async {
        authError = nil
        if let currentSession = try? await client.auth.session {
            session = currentSession
            await loadProfile(for: currentSession.user.id)
        } else {
            session = nil
            profile = nil
        }
    }

    func signIn(email: String, password: String) async throws {
        authError = nil
        let response = try await client.auth.signIn(email: email, password: password)
        session = response.session
        if let user = response.user {
            await loadProfile(for: user.id)
        } else if let userId = response.session?.user.id {
            await loadProfile(for: userId)
        }
    }

    func signUp(email: String, password: String) async throws -> AuthResponse {
        authError = nil
        return try await client.auth.signUp(email: email, password: password)
    }

    func signOut() async {
        do {
            try await client.auth.signOut()
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
            let profile: Profile = try await client.database
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
        for await event in client.auth.authStateChanges {
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
