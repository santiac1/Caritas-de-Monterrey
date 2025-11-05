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
            .navigationTitle("Inicio NUEVO")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: NotificationsView()) {
                        Image(systemName: "bell.fill")
                            .font(.title2)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.fill")
                            .font(.title2)
                    }
                }
            }
        }
    }
}

#Preview{
    HomeView()
}
