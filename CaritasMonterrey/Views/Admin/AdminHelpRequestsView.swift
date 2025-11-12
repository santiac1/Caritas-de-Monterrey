import SwiftUI

struct AdminHelpRequestsView: View {
    @EnvironmentObject private var viewModel: AdminHelpRequestsViewModel
    @EnvironmentObject private var appState: AppState
    @State private var isSigningOut = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 32)
                }
                ForEach(viewModel.donations) { donation in
                    NavigationLink(value: donation) {
                        DonationRow(donation: donation)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Solicitudes de ayuda")
        .navigationDestination(for: Donation.self) { donation in
            AdminSolicitudDetailView(donation: donation)
        }
        .task { await viewModel.loadHelpRequests() }
        .refreshable { await viewModel.loadHelpRequests() }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        Task {
                            isSigningOut = true
                            await appState.signOut()
                            isSigningOut = false
                        }
                    } label: {
                        Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } label: {
                    if isSigningOut {
                        ProgressView()
                    } else {
                        Image(systemName: "gearshape.fill")
                    }
                }
                .disabled(isSigningOut)
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in }
        )) {
            Button("Aceptar", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

private struct DonationRow: View {
    let donation: Donation

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(donation.name)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                Spacer()
                StatusBadge(display: donation.statusDisplay)
            }

            HStack(spacing: 12) {
                InfoPill(icon: "scalemass", text: donation.shipping_weight ?? "Sin peso")
                InfoPill(icon: "square.stack.3d.up", text: donation.type.capitalized)
            }

            if let donor = donation.donorName {
                HStack(spacing: 6) {
                    Image(systemName: "person.fill")
                        .foregroundStyle(Color("AccentColor"))
                    Text(donor)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .shadow(color: Color(.black).opacity(0.12), radius: 18, x: 0, y: 12)
    }
}

private struct InfoPill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.callout)
            Text(text)
                .font(.subheadline)
        }
        .foregroundStyle(Color("AccentColor"))
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            Capsule().fill(Color("AccentColor").opacity(0.15))
        )
    }
}

private struct StatusBadge: View {
    let display: DonationStatusDisplay

    var body: some View {
        Text(display.rawValue)
            .font(.caption).bold()
            .padding(.vertical, 4)
            .padding(.horizontal, 12)
            .background(display.color.opacity(0.18), in: Capsule())
            .foregroundStyle(display.color)
    }
}

#Preview {
    NavigationStack {
        AdminHelpRequestsView()
            .environmentObject(AdminHelpRequestsViewModel())
    }
}

