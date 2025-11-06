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
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootRouterView()
                .environmentObject(appState)
                .environmentObject(HomeViewModel())
                .environmentObject(DonationsViewModel())
                .environmentObject(NotificationsViewModel())
                .environmentObject(ProfileViewModel())
                .environmentObject(SupabaseManager.shared)
        }
    }
}
