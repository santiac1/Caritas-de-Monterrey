//
//  ContentView.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Inicio", systemImage: "house.fill") }
            mapaView()
                .tabItem { Label("Mapa", systemImage: "map.fill") }
            NavigationStack { DonationsView() }
                .tabItem { Label("Donaciones", systemImage: "heart.fill") }
            NotificationsView()
                .tabItem { Label("Notifs", systemImage: "bell.fill") }
        }
    }
}

