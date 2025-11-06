import SwiftUI

struct UserTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Inicio", systemImage: "house.fill") }
            mapaView()
                .tabItem { Label("Mapa", systemImage: "map.fill") }
            NavigationStack { DonationsView() }
                .tabItem { Label("Donaciones", systemImage: "heart.fill") }
        }
    }
}

#Preview {
    UserTabView()
}
