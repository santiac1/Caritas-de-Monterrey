import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = ProfileSettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showSuccessAlert = false

    var body: some View {
        Form {
            Section("Información personal") {
                TextField("Nombre público", text: $viewModel.username)
                    .textInputAutocapitalization(.words)

                TextField("Nombre", text: $viewModel.firstName)
                    .textInputAutocapitalization(.words)

                TextField("Apellido", text: $viewModel.lastName)
                    .textInputAutocapitalization(.words)

                TextField("Teléfono", text: $viewModel.phone)
                    .keyboardType(.phonePad)
            }

            Section("Cuenta") {
                Button(role: .destructive) {
                    Task { await appState.signOut() }
                } label: {
                    Text("Cerrar sesión")
                }
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Ajustes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task { await saveProfile() }
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Text("Guardar")
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
