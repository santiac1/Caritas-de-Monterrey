import SwiftUI

struct RootRouterView: View {
    
    @EnvironmentObject var appState: AppState
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false

    var body: some View {
        Group {
            // 1. Revisa si el perfil ya cargó
            if appState.isLoadingProfile {
                ProgressView() // O tu pantalla de carga
            } 
            // 2. Si hay un perfil cargado, decide la vista por ROL
            else if let profile = appState.profile {
                switch profile.role {
                case "user":
                    UserTabView()
                case "company":
                    CompanyTabView()
                case "admin":
                    AdminTabView()
                default:
                    // Perfil cargado pero sin rol (raro, pero seguro)
                    LoginView() 
                }
            } 
            // 3. Si NO hay perfil, revisa si ya vio el onboarding
            else if !hasCompletedOnboarding {
                OnboardingView()
            } 
            // 4. Si no hay nada de lo anterior, muestra el Login
            else {
                LoginView()
            }
        }
        .environmentObject(appState) // Asegúrate de pasar el appState a las subvistas
    }
}
