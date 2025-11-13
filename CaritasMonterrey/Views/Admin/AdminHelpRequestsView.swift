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
                        AdminDonationCard(donation: donation)
                    }
                    .buttonStyle(.plain)
                }

            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Donaciones")
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

// MARK: - Card principal (glass, borde sutil, sombra)

private struct AdminDonationCard: View {
    let donation: Donation

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Encabezado: nombre + estado
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(donation.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Spacer()
            }

            // Donante (si existe)
            if let donor = donation.donorName, !donor.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "person.fill")
                        .foregroundStyle(Color("AccentColor"))
                    Text(donor)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            // Sección de Tags (igual estilo a bazares)
            let tags = donationTagModels(from: donation)
            if !tags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Detalles:")
                        .font(.footnote).bold()
                        .foregroundStyle(.secondary)

                    let rows = chunk(tags, by: 3)
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                            HStack(spacing: 8) {
                                ForEach(row, id: \.title) { t in
                                    GrayTag(title: t.title, systemName: t.systemName)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(glassBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08))
        }
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
    }

    @ViewBuilder
    private var glassBackground: some View {
        if #available(iOS 18.0, *) {
            RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.thinMaterial)
        } else {
            RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.ultraThinMaterial)
        }
    }
}



// MARK: - Tags estilo bazares (gris translúcido + SF Symbol)

private struct GrayTag: View {
    let title: String
    let systemName: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemName).font(.caption)
            Text(title).font(.caption).bold().lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .foregroundStyle(.primary)                        // texto neutro (igual que bazaar)
        .background(Capsule().fill(Color.primary.opacity(0.08)))
    }
}


// MARK: - Tag models a partir del Donation (sin hardcodear vista)

private struct DonationTagModel {
    let title: String
    let systemName: String
}

private func donationTagModels(from d: Donation) -> [DonationTagModel] {
    var tags: [DonationTagModel] = []

    // Peso (si viene string como en tu modelo)
    if let w = d.shipping_weight, !w.isEmpty {
        tags.append(.init(title: w, systemName: "scalemass"))
    }

    // Tipo
    let typeTitle = d.type.isEmpty ? "Tipo desconocido" : d.type.capitalized
    tags.append(.init(title: typeTitle, systemName: "square.stack.3d.up"))

    // Puedes sumar más si existen en tu modelo, por ejemplo ciudad, urgencia, etc.
    // if let city = d.city { tags.append(.init(title: city, systemName: "mappin.circle")) }

    return tags
}

// Igual que en bazares: filas de 3 para “envolver”
private func chunk<T>(_ array: [T], by size: Int) -> [[T]] {
    guard size > 0 else { return [array] }
    var result: [[T]] = []
    var current: [T] = []
    current.reserveCapacity(size)

    for item in array {
        current.append(item)
        if current.count == size {
            result.append(current)
            current.removeAll(keepingCapacity: true)
        }
    }
    if !current.isEmpty { result.append(current) }
    return result
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AdminHelpRequestsView()
            .environmentObject(AdminHelpRequestsViewModel())
            .environmentObject(AppState())
    }
}

