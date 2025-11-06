import SwiftUI

struct CompanyTabView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var donationSheetVM = DonationSheetViewModel()
    @StateObject private var donationsVM = DonationsViewModel()
    @StateObject private var profileVM = ProfileViewModel()
    @State private var showNewDonation = false

    var body: some View {
        TabView {
            NavigationStack {
                CompanyDashboardView()
                    .environmentObject(donationsVM)
            }
            .tabItem { Label("Inicio", systemImage: "chart.bar.fill") }

            NavigationStack {
                VStack {
                    Button {
                        showNewDonation = true
                    } label: {
                        Label("Crear donación", systemImage: "plus.circle.fill")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("AccentColor"))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    Spacer()
                }
                .padding()
                .navigationTitle("Hacer donación")
            }
            .sheet(isPresented: $showNewDonation, onDismiss: {
                Task { await donationsVM.loadDonations(for: appState.session?.user.id) }
            }) {
                DonationSheet(viewModel: donationSheetVM)
                    .environmentObject(appState)
            }
            .tabItem { Label("Donar", systemImage: "gift.fill") }

            NavigationStack {
                CompanyDonationsListView()
                    .environmentObject(donationsVM)
            }
            .tabItem { Label("Mis donaciones", systemImage: "tray.fill") }

            NavigationStack {
                CompanyProfileView()
                    .environmentObject(profileVM)
            }
            .tabItem { Label("Perfil", systemImage: "person.crop.square") }
        }
        .task {
            await donationsVM.loadDonations(for: appState.session?.user.id)
            profileVM.load(from: appState.profile)
        }
    }
}

private struct CompanyDashboardView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var donationsVM: DonationsViewModel

    var totalDonations: Int { donationsVM.donations.count }
    var pendingDonations: Int { donationsVM.donations.filter { $0.statusDisplay == .enProceso || $0.statusDisplay == .solicitudAyuda }.count }
    var completedDonations: Int { donationsVM.donations.filter { $0.statusDisplay == .completada || $0.statusDisplay == .ayudaAprobada }.count }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack(spacing: 16) {
                    StatCard(title: "Totales", value: totalDonations)
                    StatCard(title: "Pendientes", value: pendingDonations)
                }
                StatCard(title: "Completadas", value: completedDonations)
                if donationsVM.isLoading {
                    ProgressView().padding()
                }
            }
            .padding()
        }
        .navigationTitle("Panel de empresa")
        .task { await donationsVM.loadDonations(for: appState.session?.user.id) }
        .refreshable { await donationsVM.loadDonations(for: appState.session?.user.id) }
    }
}

private struct StatCard: View {
    let title: String
    let value: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text("\(value)")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }
}

private struct CompanyDonationsListView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var donationsVM: DonationsViewModel

    var body: some View {
        List {
            if donationsVM.isLoading {
                ProgressView().frame(maxWidth: .infinity, alignment: .center)
            }
            ForEach(donationsVM.donations) { donation in
                VStack(alignment: .leading, spacing: 4) {
                    Text(donation.name)
                        .font(.headline)
                    Text(donation.statusDisplay.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Mis donaciones")
        .task { await donationsVM.loadDonations(for: appState.session?.user.id) }
        .refreshable { await donationsVM.loadDonations(for: appState.session?.user.id) }
    }
}

private struct CompanyProfileView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var profileVM: ProfileViewModel

    var body: some View {
        Form {
            Section("Información de la empresa") {
                TextField("Nombre de la empresa", text: $profileVM.companyName)
                TextField("RFC", text: $profileVM.rfc)
                TextField("Dirección", text: $profileVM.address)
            }

            Button {
                Task { await profileVM.saveProfile(for: appState.profile?.id, appState: appState) }
            } label: {
                if profileVM.isSaving {
                    ProgressView()
                } else {
                    Text("Guardar cambios")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("Perfil")
        .onAppear { profileVM.load(from: appState.profile) }
        .alert("Perfil actualizado", isPresented: Binding(
            get: { profileVM.showConfirmation },
            set: { newValue in
                if !newValue { profileVM.dismissConfirmation() }
            }
        )) {
            Button("Aceptar", role: .cancel) { profileVM.dismissConfirmation() }
        }
        message: {
            if let error = profileVM.errorMessage {
                Text(error)
            } else {
                Text("La información se guardó correctamente.")
            }
        }
    }
}
