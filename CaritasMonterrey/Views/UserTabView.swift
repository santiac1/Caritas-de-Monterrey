import SwiftUI

struct UserTabView: View {

    @StateObject private var homeVM = HomeViewModel()
    @StateObject private var donationsVM = DonationsViewModel()
    @StateObject private var mapaVM = MapaViewModel()

    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            HomeView()
                .environmentObject(homeVM)
                .environmentObject(donationsVM)
                .environmentObject(mapaVM)
                .tabItem { Label("Inicio", systemImage: "house.fill") }

            MapView()
                .environmentObject(mapaVM)
                .tabItem { Label("Mapa", systemImage: "map.fill") }

            NavigationStack { DonationsView() }
                .environmentObject(donationsVM)
                .tabItem { Label("Donaciones", systemImage: "heart.fill") }
        }
    }
}

#Preview {
    UserTabView()
        .environmentObject(AppState())
}
