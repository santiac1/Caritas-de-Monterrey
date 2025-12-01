import SwiftUI

struct AdminHelpRequestsView: View {
    @StateObject private var viewModel = AdminHelpRequestsViewModel()
    @Namespace private var animationNamespace
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // Filtro
                DonationsFilterBar(selection: $viewModel.currentFilter, namespace: animationNamespace)
                    .padding(.vertical, 10)
                    .background(Color(UIColor.systemBackground))
                
                // Lista de solicitudes
                if viewModel.isLoading && viewModel.donations.isEmpty {
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
                            ZStack {
                                AdminDonationRow(donation: donation)
                                NavigationLink(value: AppRoute.adminDonationDetail(donation)) {
                                    EmptyView()
                                }
                                .opacity(0)
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
            .background(Color(.secondarySystemBackground))
            .navigationTitle("Solicitudes")
            .navigationBarTitleDisplayMode(.large)
            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(value: AppRoute.profile) {
                        Image(systemName: "person.crop.circle")
        
                    }
                }
                
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
            
            .task {
                await viewModel.loadHelpRequests()
            }
            .onChange(of: viewModel.currentFilter) { _, _ in
                Task {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    await viewModel.loadHelpRequests()
                }
            }
            .onChange(of: viewModel.currentSort) { _, _ in
                Task {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    await viewModel.loadHelpRequests()
                }
            }
            // Navegación
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .profile:
                    ProfileView()
                case .settings:
                    SettingsView()
                case .adminDonationDetail(let donation):
                    AdminSolicitudDetailView(donation: donation)
                case .aboutCaritas:
                    AboutCaritasView()
                case .bazaarForm, .donateAction, .donationDetail, .campaignDetail, .map, .myDonations, .notifications:
                    EmptyView()
                }
            }
        }
    }
}

// Donación para admin
private struct AdminDonationRow: View {
    let donation: Donation
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(width: 48, height: 48)
                Image(systemName: iconForType(donation.type))
                    .foregroundStyle(Color("AccentColor"))
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
                // Borrar
                // Badge de estado
                Text(donation.statusDisplay.rawValue)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(donation.statusDisplay.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(donation.statusDisplay.color.opacity(0.1))
                    .clipShape(Capsule())
                
                if let date = donation.created_at {
                    Text(date, format: .dateTime.day().month())
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary.opacity(0.5))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    func iconForType(_ type: String) -> String {
        switch type.lowercased() {
        case "alimentos": return "carrot.fill"
        case "ropa": return "tshirt.fill"
        case "medicinas": return "cross.case.fill"
        case "muebles": return "sofa.fill"
        case "equipo": return "wrench.and.screwdriver"
        default: return "archivebox.fill"
        }
    }
}
