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
        LaunchScreen(
            config: LaunchScreenConfig(
                backgroundColor: Color("LaunchScreenBackground"),
                scaling: 7, 
                zoomAnchor: UnitPoint(x: 0.46, y: 0.35)
            ),
            logo: {
                Image("launchlogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 203, height: 100)
            }
        ) {
            RootRouterView()
                .environmentObject(appState)
        }
    }
}
