import SwiftUI

struct RootRouterView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            // Checar perfil 
            if appState.isLoadingProfile {
                ProgressView()
            }

            // Directo al Home
            else if appState.profile != nil {
                // Usar el rol
                switch appState.effectiveRole {
                case .user:
                    UserTabView()
                case .admin:
                    AdminTabView()
                }
            }

            else if !hasCompletedOnboarding {
                OnboardingView()
            }

            // ir a MainRegistro
            else {
                MainRegistroView()
            }
        }
        .environmentObject(appState)
    }
}
