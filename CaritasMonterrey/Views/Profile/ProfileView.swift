//
//  ProfileView.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//
//  Modificado por Gemini para adaptarse al diseño de la imagen.
//

import SwiftUI

struct ProfileView: View {
    
    // Variables de Estado
    @State private var nombrePublico: String = ""
    @State private var nombre: String = ""
    @State private var apellido: String = ""
    @State private var telefono: String = ""
    @State private var direccion: String = ""
    @State private var fechaNacimiento: Date = Date()
    // La variable 'rol' se ha eliminado

    var body: some View {
        // NOTA: Se eliminó el NavigationStack de esta vista
        // para que funcione correctamente dentro del de HomeView.
        ScrollView {
            VStack(spacing: 24) {
                
                // --- Sección Superior: Campos e Imagen ---
                HStack(alignment: .top, spacing: 16) {
                    
                    // --- Columna Izquierda: Campos Principales ---
                    VStack(spacing: 16) {
                        ProfileTextField(label: "Nombre Publico", text: $nombrePublico)
                        ProfileTextField(label: "Nombre", text: $nombre)
                        ProfileTextField(label: "Apellido", text: $apellido)
                        ProfileTextField(label: "Telefono", text: $telefono)
                            .keyboardType(.phonePad)
                        ProfileTextField(label: "Dirección", text: $direccion)
                        // El DatePicker se movió a la columna derecha
                    }
                    
                    // --- Columna Derecha: Imagen y Fecha de Nacimiento (MODIFICADO) ---
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(Color(.systemGray3))
                            .padding(.top, 5)
                        
                        // Campo 'Rol' reemplazado por 'Fecha de nacimiento'
                        ProfileDatePicker(label: "Fecha de nacimiento", selection: $fechaNacimiento)
                    }
                }
                
                // --- Botón de Guardar ---
                Button(action: guardarPerfil) {
                    Text("Guardar")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color(red: 0.05, green: 0.1, blue: 0.2))
                        .cornerRadius(30)
                }
                .padding(.top, 10)
                
            }
            .padding()
        }
        .navigationTitle("Perfil") // El título se mostrará en la barra de HomeView
        .toolbarTitleDisplayMode(.large)
    }
    
    // Función para guardar (MODIFICADA)
    private func guardarPerfil() {
        print("Guardando perfil...")
        
        // Datos a guardar (sin 'rol')
        print("- Nombre Público: \(nombrePublico)")
        print("- Nombre: \(nombre)")
        print("- Apellido: \(apellido)")
        print("- Teléfono: \(telefono)")
        print("- Dirección: \(direccion)")
        print("- Fecha de Nacimiento: \(fechaNacimiento)")
    }
}

// -----------------------------------------------------------------------------
// MARK: - Componentes de UI Reutilizables
// -----------------------------------------------------------------------------

struct ProfileTextField: View {
    var label: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextField("", text: $text)
                .padding(12)
                .frame(height: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray3), lineWidth: 1)
                )
        }
    }
}

struct ProfileDatePicker: View {
    var label: String
    @Binding var selection: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            DatePicker("", selection: $selection, displayedComponents: .date)
                .labelsHidden()
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray3), lineWidth: 1)
                )
        }
    }
}


// -----------------------------------------------------------------------------
// MARK: - Vista Previa (Preview)
// -----------------------------------------------------------------------------

#Preview {
    // Para que el Preview funcione solo, lo envolvemos en un NavigationStack
    NavigationStack {
        ProfileView()
    }
}
