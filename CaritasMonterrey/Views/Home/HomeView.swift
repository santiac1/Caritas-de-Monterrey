import SwiftUI
import Auth

struct HomeView: View {
    @EnvironmentObject private var vm: HomeViewModel
    @EnvironmentObject private var donationsVM: DonationsViewModel
    @EnvironmentObject private var mapaVM: MapaViewModel
    @EnvironmentObject private var appState: AppState

    @State private var navPath = NavigationPath()
    @State private var activeSheet: HomeSheet?

    private enum HomeSheet: Identifiable {
        case donation
        var id: String { "donation" }
    }

    var body: some View {
        NavigationStack(path: $navPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // 1. Banner Principal
                    BannerCard(
                        title: vm.banner.title,
                        assetName: vm.banner.assetName,
                        systemFallback: vm.banner.systemFallback
                    ) {
                        activeSheet = .donation
                    }
                    .padding(.top, 10)

                    // 2. Estadísticas
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tus estadísticas")
                            .font(.title3).bold()
                        
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
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .navigationTitle(vm.screenTitle)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { navPath.append(AppRoute.notifications) } label: {
                        Image(systemName: "bell.fill").font(.title3).foregroundStyle(.primary)
                    }
                }
                ToolbarSpacer(.fixed, placement: .primaryAction)
                ToolbarItem(placement: .primaryAction) {
                    Button { navPath.append(AppRoute.profile) } label: {
                        Image(systemName: "person.crop.circle").font(.title3).foregroundStyle(.primary)
                    }
                }
            }
            .onAppear {
                Task { await vm.loadStats(for: appState.session?.user.id) }
            }
            // --- MANEJADOR DE RUTAS GLOBAL ---
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .map:
                    MapView()
                        .environmentObject(mapaVM)
                        .environmentObject(appState)
                        .navigationTitle("Mapa")
                        .navigationBarTitleDisplayMode(.inline)

                case .myDonations:
                    DonationsView()
                        .environmentObject(donationsVM)
                        .navigationTitle("Mis donaciones")
                        .navigationBarTitleDisplayMode(.inline)
                        
                case .notifications:
                    NotificationsView()
                        .navigationTitle("Notificaciones")
                        
                case .profile:
                    ProfileView()
                        // No ponemos título aquí porque ProfileView tiene el suyo propio
                
                case .settings:
                    SettingsView()
                        // SettingsView tiene su propio título definido internamente
                        
                case .donateAction:
                    EmptyView()
                }
            }
            .sheet(item: $activeSheet, onDismiss: {
                Task { await vm.loadStats(for: appState.session?.user.id) }
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
