import SwiftUI

struct AdminTabView: View {
    @StateObject private var helpRequestsVM = AdminHelpRequestsViewModel()
    @StateObject private var bazaarVM = BazaarManagementViewModel()
    @StateObject private var campaignVM = CampaignViewModel()

    var body: some View {
        TabView {
            NavigationStack {
                AdminHelpRequestsView()
                    .environmentObject(helpRequestsVM)
            }
            .tabItem { Label("Solicitudes", systemImage: "tray.fill") }

            NavigationStack {
                BazaarManagementView()
                    .environmentObject(bazaarVM)
            }
            .tabItem { Label("Bazares", systemImage: "building.2.fill") }
            NavigationStack {
                CampaignView()
                    .environmentObject(campaignVM)
            }
            .tabItem { Label("Campañas", systemImage: "megaphone.fill") }
        }
    }
}
