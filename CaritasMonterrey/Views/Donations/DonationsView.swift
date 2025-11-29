import SwiftUI
import Auth

struct DonationsView: View {
    @EnvironmentObject var viewModel: DonationsViewModel
    @EnvironmentObject var appState: AppState // Necesario para el userId
    
    // Estado para el filtro seleccionado en la UI
    @State private var selectedFilter: DonationFilter = .all
    @Namespace private var animationNamespace

    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Barra de Filtros
            // Usamos el componente reutilizable que creamos
            DonationsFilterBar(selection: $selectedFilter, namespace: animationNamespace)
                .padding(.vertical, 10)
                .background(Color(UIColor.systemBackground))
            
            // MARK: - Lista de Donaciones
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if filteredDonations.isEmpty {
                ContentUnavailableView(
                    "Sin donaciones",
                    systemImage: "tray",
                    description: Text("No tienes donaciones con este filtro.")
                )
            } else {
                List {
                    ForEach(filteredDonations) { donation in
                        NavigationLink(destination: DetallesDonacionView(donation: donation)) {
                            DonationRow(donation: donation)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.refresh(for: appState.session?.user.id)
                }
            }
        }
        .navigationTitle("Mis donaciones")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: appState.session?.user.id) {
            guard let userId = appState.session?.user.id else { return }
            await viewModel.load(for: appState.session?.user.id)
        }
    }
    
    // Lógica de filtrado local para la vista de usuario
    var filteredDonations: [Donation] {
        switch selectedFilter {
        case .all:
            return viewModel.donations
        case .inProcess:
            return viewModel.donations.filter { $0.status == .in_process }
        case .accepted:
            return viewModel.donations.filter { $0.status == .accepted }
        case .received:
            return viewModel.donations.filter { $0.status == .received }
        case .rejected:
            return viewModel.donations.filter { $0.status == .rejected || $0.status == .returned }
        }
    }
}

// MARK: - Componente Row Local
private struct DonationRow: View {
    let donation: Donation
    
    var body: some View {
        HStack(spacing: 16) {
            // Icono con círculo de fondo
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
                
                Text(donation.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Badge de estado
            Text(donation.statusDisplay.rawValue)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(donation.statusDisplay.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(donation.statusDisplay.color.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
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
