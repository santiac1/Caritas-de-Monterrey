import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            Form {
                Section("Cuenta") {
                    NavigationLink("Gestionar cuenta") {
                        EditProfileView()
                    }

                    Button(role: .destructive) {
                        Task { await appState.signOut() }
                    } label: {
                        Text("Cerrar sesión")
                    }
                }
            }
            .navigationTitle("Ajustes")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
