import SwiftUI

struct CompanySettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button(role: .destructive) {
                        Task {
                            await appState.signOut()
                        }
                    } label: {
                        Text("Cerrar Sesión")
                    }
                }
            }
            .navigationTitle("Ajustes")
        }
    }
}
