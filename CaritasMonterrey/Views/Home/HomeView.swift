import SwiftUI
import Auth

struct HomeView: View {
    @EnvironmentObject private var vm: HomeViewModel
    @EnvironmentObject private var donationsVM: DonationsViewModel
    @EnvironmentObject private var mapaVM: MapaViewModel
    @EnvironmentObject private var appState: AppState

    @State private var navPath = NavigationPath()
    
    // Usamos un enum opcional para controlar el sheet principal
    @State private var activeSheet: HomeSheet?

    private enum HomeSheet: Identifiable {
        case donation
        var id: String { "donation" }
    }

    var body: some View {
        NavigationStack(path: $navPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    BannerCard(
                        title: vm.banner.title,
                        assetName: vm.banner.assetName,
                        systemFallback: vm.banner.systemFallback
                    ) {
                        activeSheet = .donation
                    }

                    Text("Acciones rápidas")
                        .font(.title3).bold()
                        .padding(.top, 8)

                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 14),
                                  GridItem(.flexible(), spacing: 14)],
                        spacing: 14
                    ) {
                        ForEach(vm.secondaryCards) { card in
                            ActionCard(
                                title: card.title,
                                assetName: card.assetName,
                                systemFallback: card.systemFallback
                            ) {
                                switch card.route {
                                case .mapV:       navPath.append(card.route)
                                case .donationsV: navPath.append(card.route)
                                case .donateV:    activeSheet = .donation
                                }
                            }
                        }
                    }

                    Text("Tus estadísticas")
                        .font(.title3).bold()
                        .padding(.top, 8)

                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 14),
                                  GridItem(.flexible(), spacing: 14)],
                        spacing: 14
                    ) {
                        StatCard(title: "Donaciones", value: vm.totalText, systemIcon: "chart.bar.fill")
                        StatCard(title: "En proceso", value: vm.inProgressText, systemIcon: "clock.badge.checkmark")
                        StatCard(title: "Última donación", value: vm.lastDonationText, systemIcon: "calendar")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .navigationTitle(vm.screenTitle)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: NotificationsView()) {
                        Image(systemName: "bell.fill")
                            .font(.title3)
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                }
                ToolbarSpacer(.fixed, placement: .primaryAction)
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.crop.circle")
                            .font(.title3)
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .task {
                // Carga inicial al abrir la app
                await vm.loadStats(for: appState.session?.user.id)
            }
            .navigationDestination(for: HomeViewModel.Route.self) { route in
                switch route {
                case .mapV:
                    MapView()
                        .environmentObject(mapaVM)
                        .navigationTitle("Mapa")
                        .navigationBarTitleDisplayMode(.inline)

                case .donationsV:
                    DonationsView()
                        .environmentObject(donationsVM)
                        .navigationTitle("Mis donaciones")
                        .navigationBarTitleDisplayMode(.inline)

                case .donateV:
                    EmptyView()
                }
            }
            // 👇 AQUÍ ESTÁ EL CAMBIO IMPORTANTE 👇
            .sheet(item: $activeSheet, onDismiss: {
                // Este bloque se ejecuta cuando DonationSheet desaparece de la pantalla.
                // Aquí forzamos la recarga de las estadísticas en el Home.
                Task {
                    await vm.loadStats(for: appState.session?.user.id)
                }
            }) { item in
                switch item {
                case .donation:
                    DonationSheet(viewModel: DonationSheetViewModel())
                        .environmentObject(appState)
                        .presentationDetents([.large])
                }
            }
        }
    }
}
