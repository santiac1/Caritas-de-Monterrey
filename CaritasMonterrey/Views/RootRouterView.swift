import SwiftUI

struct RootRouterView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if appState.isLoadingProfile {
                ProgressView()
            } else if let profile = appState.profile {
                switch profile.role {
                case "user":
                    UserTabView()
                case "company":
                    CompanyTabView()
                case "admin":
                    AdminTabView()
                default:
                    LoginView()
                        .environmentObject(appState)
                }
            } else if !hasCompletedOnboarding {
                OnboardingView()
            } else {
                LoginView()
                    .environmentObject(appState)
            }
        }
        .task {
            await appState.refreshSession()
        }
    }
}

struct RootRouterView_Previews: PreviewProvider {
    static var previews: some View {
        RootRouterView()
            .environmentObject(AppState())
    }
}
