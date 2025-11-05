//
//  HomeView.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Campañas destacadas")
                Button("Donar ahora") {}
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Inicio")
            .toolbar {

                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.fill")
                            .font(.title2)
                    }
                    .tint(Color(red: 0.05, green: 0.1, blue: 0.2)) // Color oscuro
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                            .font(.title2)
                    }
                    .tint(Color(red: 0.05, green: 0.1, blue: 0.2)) // Color oscuro
                }
            }
        }
    }
}

#Preview{
    HomeView()
}
