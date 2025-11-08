//
//  SettingsView.swift
//  CaritasMonterrey
//
//  Created by Gemini on 04/11/25.
//

import SwiftUI

struct SettingsView: View {
    
    // Variable de estado de ejemplo
    @State private var notificationsOn = true

    var body: some View {
        // Usamos una Lista para el estilo clásico de "Configuración"
        List {
            Section(header: Text("Notificaciones")) {
                Toggle("Recibir notificaciones", isOn: $notificationsOn)
            }
            
            Section(header: Text("Cuenta")) {
                Button(action: {}) {
                    Text("Gestionar cuenta")
                }
                Button(action: {}) {
                    Text("Privacidad y seguridad")
                }
            }
            
            Section(header: Text("Soporte")) {
                Button(action: {}) {
                    Text("Ayuda y soporte")
                }
                Button(action: {}) {
                    Text("Acerca de la app")
                }
            }
            
            Section {
                Button(role: .destructive, action: {
                    // Lógica para cerrar sesión
                }) {
                    Text("Cerrar Sesión")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Configuración") // Título que se mostrará
        .navigationBarTitleDisplayMode(.inline) // Estilo de título más pequeño
    }
}

#Preview {
    // Envolvemos en NavigationStack solo para el preview
    NavigationStack {
        SettingsView()
    }
}
