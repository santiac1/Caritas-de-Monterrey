import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState

    private var profile: Profile? { appState.profile }
    private var placeholder: String { appState.isLoadingProfile ? "Cargando..." : "Sin información" }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if profile == nil {
                    ProfilePlaceholderView(isLoading: appState.isLoadingProfile)
                }

                HStack(alignment: .top, spacing: 16) {
                    VStack(spacing: 16) {
                        ProfileTextField(label: "Nombre público", text: profile?.username ?? placeholder)
                        ProfileTextField(label: "Nombre", text: profile?.firstName ?? placeholder)
                        ProfileTextField(label: "Apellido", text: profile?.lastName ?? placeholder)
                        ProfileTextField(label: "Teléfono", text: profile?.phone ?? placeholder)
                        ProfileTextField(label: "Dirección", text: profile?.address ?? placeholder)
                    }

                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(Color(.systemGray3))
                            .padding(.top, 5)

                        ProfileTextField(label: "Fecha de nacimiento", text: formattedBirthdate)
                    }
                }

                if let companyName = profile?.companyName, !companyName.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Información de la empresa")
                            .font(.headline)
                        ProfileTextField(label: "Empresa", text: companyName)
                        ProfileTextField(label: "RFC", text: profile?.rfc ?? placeholder)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .navigationTitle("Perfil")
        .toolbarTitleDisplayMode(.large)
    }

    private var formattedBirthdate: String {
        guard let date = profile?.birthdate else { return placeholder }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}

private struct ProfileTextField: View {
    var label: String
    var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .frame(height: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray3), lineWidth: 1)
                )
        }
    }
}

private struct ProfilePlaceholderView: View {
    let isLoading: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isLoading ? "hourglass" : "exclamationmark.circle")
                .foregroundColor(.secondary)
                .font(.title3)
            Text(isLoading ? "Cargando perfil..." : "No encontramos la información de tu perfil.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray3), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AppState())
    }
}
