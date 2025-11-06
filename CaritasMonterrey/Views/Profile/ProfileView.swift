//
//  ProfileView.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//
//  Modificado por Gemini para adaptarse al diseño de la imagen
//  y refactorizado para usar un Modelo de Datos (UserProfile).
//

import SwiftUI

// NOTA: El modelo 'UserProfile' y 'ProfileData'
// ahora viven en el archivo "ProfileModel.swift"

struct ProfileView: View {
    @State private var user: UserProfile = UserProfile()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // --- Sección Superior: Campos e Imagen ---
                HStack(alignment: .top, spacing: 16) {
                    
                    // --- Columna Izquierda: Campos Principales ---
                    VStack(spacing: 16) {

                        ProfileTextField(label: "Nombre Publico", text: $user.nombrePublico)
                        ProfileTextField(label: "Nombre", text: $user.nombre)
                        ProfileTextField(label: "Apellido", text: $user.apellido)
                        ProfileTextField(label: "Telefono", text: $user.telefono)
                            .keyboardType(.phonePad)
                        ProfileTextField(label: "Dirección", text: $user.direccion)
                    }
                    
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(Color(.systemGray3))
                            .padding(.top, 5)

                        ProfileDatePicker(label: "Fecha de nacimiento", selection: $user.fechaNacimiento)
                    }
                }
                
                // --- Botón de Guardar ---
                Button(action: guardarPerfil) {
                    Text("Guardar")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(UIColor.systemBackground))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color(UIColor.label))
                        .cornerRadius(30)
                }
                .padding(.top, 10)
                
            }
            .padding()
        }
        .navigationTitle("Perfil")
        .toolbarTitleDisplayMode(.large)
        .onAppear {
        }
    }
    
    private func guardarPerfil() {
        print("Guardando perfil...")
        
        // --- CAMBIO: Se imprime el objeto 'user' completo ---
        print("- Nombre Público: \(user.nombrePublico)")
        print("- Nombre: \(user.nombre)")
        print("- Apellido: \(user.apellido)")
        print("- Teléfono: \(user.telefono)")
        print("- Dirección: \(user.direccion)")
        print("- Fecha de Nacimiento: \(user.fechaNacimiento)")
        
    }
}

// -----------------------------------------------------------------------------
// MARK: - Componentes de UI Reutilizables
// (Estas vistas no necesitan cambios, ya que funcionan con Bindings)
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
