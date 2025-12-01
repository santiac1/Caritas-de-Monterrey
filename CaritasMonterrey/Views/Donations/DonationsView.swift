import SwiftUI
import Auth

struct DonationsView: View {
    @EnvironmentObject var viewModel: DonationsViewModel
    @EnvironmentObject var appState: AppState
    @State private var selectedFilter: DonationFilter = .all
    @Namespace private var animationNamespace

    var body: some View {
        VStack(spacing: 0) {
            
            DonationsFilterBar(selection: $selectedFilter, namespace: animationNamespace)
                .padding(.vertical, 10)
                .background(Color(UIColor.secondarySystemBackground))
            
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
                        ZStack {
                            DonationRow(donation: donation)
                            NavigationLink(value: AppRoute.donationDetail(donation)) {
                                EmptyView()
                            }
                            .opacity(0)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .refreshable {
                    await viewModel.refresh(for: appState.session?.user.id)
                }
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .navigationTitle("Mis donaciones")
        .navigationBarTitleDisplayMode(.large)
        .task(id: appState.session?.user.id) {
            guard let userId = appState.session?.user.id else { return }
            await viewModel.load(for: userId)
        }
    }
    
    // Filtros para el usuario
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

private struct DonationRow: View {
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
                
                Text(donation.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(donation.statusDisplay.rawValue)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(donation.statusDisplay.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(donation.statusDisplay.color.opacity(0.1))
                .clipShape(Capsule())
            
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
