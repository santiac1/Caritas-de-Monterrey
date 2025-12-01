import SwiftUI

struct RootRouterView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            // 1️⃣ Si está cargando el perfil (por ejemplo al iniciar sesión)
            if appState.isLoadingProfile {
                ProgressView()
            }

            // 2️⃣ Si ya hay un perfil cargado, vamos directo al Home
            else if appState.profile != nil {
                // Usamos el rol efectivo normalizado desde AppState:
                // - "admin"  -> AdminTabView
                // - cualquier otro ("user", "company", desconocidos, etc.) -> UserTabView
                switch appState.effectiveRole {
                case .user:
                    UserTabView()
                case .admin:
                    AdminTabView()
                }
            }

            // 3️⃣ Si NO hay perfil y el usuario NO ha hecho el onboarding → mostrarlo
            else if !hasCompletedOnboarding {
                OnboardingView()
            }

            // 4️⃣ Si ya completó onboarding pero no tiene sesión → ir a MainRegistro
            else {
                MainRegistroView()
            }
        }
        .environmentObject(appState)
    }
}
