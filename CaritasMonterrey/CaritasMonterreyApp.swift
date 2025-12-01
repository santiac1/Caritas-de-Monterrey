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
                // AQUÍ ESTÁ LA MAGIA:
                // Coordenadas (0 a 1) de dónde está la cruz "t" en tu imagen.
                // X: 0.42 (Un poco a la izquierda del centro)
                // Y: 0.35 (En la parte superior, donde está la cruz)
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
