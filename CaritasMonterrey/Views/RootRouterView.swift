import SwiftUI

struct RootRouterView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if let role = appState.profile?.role, appState.session != nil {
                switch role {
                case "user":
                    UserTabView()
                case "company":
                    CompanyTabView()
                case "admin":
                    AdminTabView()
                default:
                    LoginOrOnboardingView()
                }
            } else {
                LoginOrOnboardingView()
            }
        }
        .task {
            await appState.refreshSession()
        }
    }
}

private struct LoginOrOnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool

    var body: some View {
        if hasCompletedOnboarding {
            LoginView()
                .environmentObject(appState)
        } else {
            OnboardingView()
        }
    }
}

struct RootRouterView_Previews: PreviewProvider {
    static var previews: some View {
        RootRouterView()
            .environmentObject(AppState())
    }
}
