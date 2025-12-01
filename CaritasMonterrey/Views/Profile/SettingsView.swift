import SwiftUI
import Auth

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = ProfileSettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showSuccessAlert = false
    @AppStorage("notificationsEnable") private var notificationsEnable = true
    
    var body: some View {
        Form {
            // Datos personales
            Section {
                HStack {
                    Image(systemName: "person.text.rectangle")
                        .foregroundStyle(Color("AccentColor"))
                        .frame(width: 24)
                    TextField("Nombre público", text: $viewModel.username)
                        .textInputAutocapitalization(.words)
                }
               
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.secondary)
                        .frame(width: 24)
                    TextField("Nombre", text: $viewModel.firstName)
                        .textInputAutocapitalization(.words)
                }
               
                HStack {
                    Image(systemName: "person")
                        .foregroundStyle(.secondary)
                        .frame(width: 24)
                    TextField("Apellido", text: $viewModel.lastName)
                        .textInputAutocapitalization(.words)
                }
               
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundStyle(.green)
                        .frame(width: 24)
                    TextField("Teléfono", text: $viewModel.phone)
                        .keyboardType(.phonePad)
                }
            } header: {
                Text("Información Personal")
            } footer: {
                Text("Esta información se utiliza para contactarte en caso de dudas sobre tus donaciones.")
            }
            
            // Preferencias
            Section("Preferencias") {
                Toggle(isOn: $notificationsEnable) {
                    Label {
                        Text("Notificaciones")
                    } icon: {
                        Image(systemName: "bell.badge.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
            
            // Cuenta
            Section {
                Button(role: .destructive) {
                    Task { await appState.signOut() }
                } label: {
                    Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                }
            } header: {
                Text("Cuenta")
            }
            
            if let error = viewModel.errorMessage {
                Section {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Ajustes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task { await saveProfile() }
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Text("Guardar")
                            .fontWeight(.semibold)
                    }
                }
                .disabled(viewModel.isSaving)
            }
        }
        .onAppear {
            viewModel.loadProfileData(appState: appState)
        }
        .onChange(of: appState.profile?.id) { _, _ in
            viewModel.loadProfileData(appState: appState)
        }
        .alert("¡Tus datos fueron modificados correctamente!", isPresented: $showSuccessAlert) {
            Button("Aceptar") {
                viewModel.resetSaveState()
            }
        } message: {
            Text("La información de tu perfil ha sido actualizada.")
        }
    }

    private func saveProfile() async {
        guard let userId = appState.session?.user.id else { return }
        await viewModel.saveProfile(userId: userId)
        if viewModel.didSave {
            await appState.loadProfile(for: userId, silent: true)
            viewModel.loadProfileData(appState: appState)
            showSuccessAlert = true
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppState())
    }
}
