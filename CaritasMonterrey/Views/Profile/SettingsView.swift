import SwiftUI
import Auth

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = ProfileSettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showSuccessAlert = false
    // Notifications toggle (simulado o real según tu lógica)
    @AppStorage("notificationsEnable") private var notificationsEnable = true
    
    var body: some View {
        Form {
            // --- SECCIÓN 1: DATOS PERSONALES ---
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
            
            // --- SECCIÓN 2: PREFERENCIAS ---
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
            
            // --- SECCIÓN 3: CUENTA ---
            Section {
                Button(role: .destructive) {
                    Task { await appState.signOut() }
                } label: {
                    Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                }
            } header: {
                Text("Cuenta")
            }
            
            // --- MENSAJES DE ERROR ---
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
        .onChange(of: appState.profile?.id) { _ in
            viewModel.loadProfileData(appState: appState)
        }
        .alert("Perfil actualizado", isPresented: $showSuccessAlert) {
            Button("Aceptar") {
                viewModel.resetSaveState()
                dismiss()
            }
        } message: {
            Text("Tus datos se guardaron correctamente.")
        }
    }

    private func saveProfile() async {
        guard let userId = appState.session?.user.id else { return }
        await viewModel.saveProfile(userId: userId)
        if viewModel.didSave {
            await appState.loadProfile(for: userId)
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
