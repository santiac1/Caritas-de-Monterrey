import SwiftUI

// Este es tu "enrutador"
struct ContentView: View {
    
    // Pide el "cerebro"
    @EnvironmentObject var appState: AppState
    
    // Revisa si ya pasó el onboarding
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false

    var body: some View {
        Group {
            // 1. Revisa si el perfil ya cargó
            if appState.isLoadingProfile {
                ProgressView() // Muestra pantalla de carga
            } 
            // 2. Si hay perfil, decide por ROL
            else if let profile = appState.profile {
                switch profile.role {
                case "user":
                    UserTabView()
                case "company":
                    CompanyTabView()
                case "admin":
                    AdminTabView()
                default:
                    // Perfil sin rol (caso de seguridad)
                    LoginView() 
                }
            } 
            // 3. Si no hay perfil, revisa el onboarding
            else if !hasCompletedOnboarding {
                OnboardingView()
            } 
            // 4. Si no, al Login
            else {
                LoginView()
            }
        }
        // Pasa el "cerebro" a las vistas hijas (UserTabView, etc.)
        .environmentObject(appState) 
    }
}
