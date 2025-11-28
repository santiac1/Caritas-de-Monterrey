import SwiftUI

struct AdminHelpRequestsView: View {
    @StateObject private var viewModel = AdminHelpRequestsViewModel()
    @Namespace private var animationNamespace
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // MARK: - Filtro Superior (Barra)
                DonationsFilterBar(selection: $viewModel.currentFilter, namespace: animationNamespace)
                    .padding(.vertical, 10)
                    .background(Color(UIColor.systemBackground))
                
                // MARK: - Lista de Solicitudes
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Cargando solicitudes...")
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(error))
                } else if viewModel.donations.isEmpty {
                    ContentUnavailableView(
                        "Sin solicitudes",
                        systemImage: "tray",
                        description: Text("No hay solicitudes en la categoría '\(viewModel.currentFilter.title)'.")
                    )
                } else {
                    List {
                        ForEach(viewModel.donations) { donation in
                            // Navegación al detalle
                            NavigationLink(destination: AdminSolicitudDetailView(donation: donation)) {
                                AdminDonationRow(donation: donation)
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.loadHelpRequests()
                    }
                }
            }
            .navigationTitle("Solicitudes")
            .navigationBarTitleDisplayMode(.large) // ✅ CAMBIO: Título grande y a la izquierda
            
            // MARK: - Toolbar (Perfil y Orden)
            .toolbar {
                // ✅ NUEVO: Botón de Perfil (Leading) para poder cerrar sesión
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(value: AppRoute.profile) {
                        Image(systemName: "person.crop.circle")
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }
                }
                
                // Botón de Ordenar (Trailing)
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Orden", selection: $viewModel.currentSort) {
                            ForEach(SortOrder.allCases) { order in
                                Label(order.title, systemImage: order == .newest ? "arrow.down" : "arrow.up")
                                    .tag(order)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.headline)
                    }
                }
            }
            
            // MARK: - Carga y Recarga
            .task {
                await viewModel.loadHelpRequests()
            }
            .onChange(of: viewModel.currentFilter) { _ in
                Task { await viewModel.loadHelpRequests() }
            }
            .onChange(of: viewModel.currentSort) { _ in
                Task { await viewModel.loadHelpRequests() }
            }
            // ✅ NUEVO: Manejo de navegación para ir al Perfil y Ajustes
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .profile:
                    ProfileView()
                case .settings:
                    SettingsView()
                default:
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - Fila de Donación (Admin)
private struct AdminDonationRow: View {
    let donation: Donation
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar con iniciales
            ZStack {
                Circle()
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(width: 48, height: 48)
                
                Text(initials(name: donation.donorName))
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(donation.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(donation.donorName ?? "Usuario desconocido")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // Badge de estado
                Text(donation.statusDisplay.rawValue)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(donation.statusDisplay.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(donation.statusDisplay.color.opacity(0.1))
                    .clipShape(Capsule())
                
                // Fecha
                if let date = donation.created_at {
                    Text(date, format: .dateTime.day().month())
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    func initials(name: String?) -> String {
        guard let name = name, !name.isEmpty else { return "?" }
        let parts = name.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.count > 1 ? parts.last?.prefix(1) ?? "" : ""
        return "\(first)\(last)".uppercased()
    }
}
