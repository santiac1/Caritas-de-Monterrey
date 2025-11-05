//
//  CaritasMonterreyApp.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import SwiftUI
import Combine  

@main
struct CaritasMonterreyApp: App {
    @StateObject private var onboardingVM = OnboardingViewModel()

    var body: some Scene {
        WindowGroup {
            if onboardingVM.shouldShowOnboarding {
                OnboardingView(viewModel: onboardingVM)
            } else {
                MainTabView()
                    .environmentObject(HomeViewModel())
                    .environmentObject(DonationsViewModel())
                    .environmentObject(NotificationsViewModel())
                    .environmentObject(ProfileViewModel())
                    .environmentObject(SupabaseManager.shared)
            }
        }
    }
}


