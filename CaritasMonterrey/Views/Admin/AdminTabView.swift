import SwiftUI

struct AdminTabView: View {
    @StateObject private var helpRequestsVM = AdminHelpRequestsViewModel()
    @StateObject private var bazaarVM = BazaarManagementViewModel()

    var body: some View {
        TabView {
            NavigationStack {
                AdminHelpRequestsView()
                    .environmentObject(helpRequestsVM)
            }
            .tabItem { Label("Solicitudes", systemImage: "tray.full.fill") }

            NavigationStack {
                BazaarManagementView()
                    .environmentObject(bazaarVM)
            }
            .tabItem { Label("Bazares", systemImage: "building.2.fill") }
        }
    }
}