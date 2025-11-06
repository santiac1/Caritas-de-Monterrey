import SwiftUI
import Supabase

struct CompanyTabView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showNewDonation = false

    var body: some View {
        TabView {
            NavigationStack {
                CompanyDashboardView()
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
            .sheet(isPresented: $showNewDonation) {
                DonationSheet(viewModel: DonationSheetViewModel())
                    .environmentObject(appState)
            }
            .tabItem { Label("Donar", systemImage: "gift.fill") }

            NavigationStack {
                CompanyDonationsListView()
            }
            .tabItem { Label("Mis donaciones", systemImage: "tray.fill") }

            NavigationStack {
                CompanyProfileView()
            }
            .tabItem { Label("Perfil", systemImage: "person.crop.square") }
        }
    }
}

private struct CompanyDashboardView: View {
    @EnvironmentObject private var appState: AppState
    @State private var donations: [Donation] = []
    @State private var isLoading = false

    var totalDonations: Int { donations.count }
    var pendingDonations: Int { donations.filter { $0.statusDisplay == .enProceso || $0.statusDisplay == .solicitudAyuda }.count }
    var completedDonations: Int { donations.filter { $0.statusDisplay == .completada || $0.statusDisplay == .ayudaAprobada }.count }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack(spacing: 16) {
                    StatCard(title: "Totales", value: totalDonations)
                    StatCard(title: "Pendientes", value: pendingDonations)
                }
                StatCard(title: "Completadas", value: completedDonations)
                if isLoading {
                    ProgressView().padding()
                }
            }
            .padding()
        }
        .navigationTitle("Panel de empresa")
        .task { await loadDonations() }
        .refreshable { await loadDonations() }
    }

    private func loadDonations() async {
        guard let userId = appState.session?.user.id else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            donations = try await SupabaseManager.shared.client.database
                .from("Donations")
                .select()
                .eq("user_id", value: userId)
                .order(column: "created_at", ascending: false)
                .execute()
                .value
        } catch {
            // Keep silent for now, could show toast
        }
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
    @State private var donations: [Donation] = []
    @State private var isLoading = false

    var body: some View {
        List {
            if isLoading {
                ProgressView().frame(maxWidth: .infinity, alignment: .center)
            }
            ForEach(donations) { donation in
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
        .task { await loadDonations() }
        .refreshable { await loadDonations() }
    }

    private func loadDonations() async {
        guard let userId = appState.session?.user.id else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            donations = try await SupabaseManager.shared.client.database
                .from("Donations")
                .select()
                .eq("user_id", value: userId)
                .order(column: "created_at", ascending: false)
                .execute()
                .value
        } catch {
            // handle silently for now
        }
    }
}

private struct CompanyProfileView: View {
    @EnvironmentObject private var appState: AppState
    @State private var companyName: String = ""
    @State private var rfc: String = ""
    @State private var address: String = ""
    @State private var isSaving = false
    @State private var showConfirmation = false

    var body: some View {
        Form {
            Section("Información de la empresa") {
                TextField("Nombre de la empresa", text: $companyName)
                TextField("RFC", text: $rfc)
                TextField("Dirección", text: $address)
            }

            Button {
                Task { await saveProfile() }
            } label: {
                if isSaving {
                    ProgressView()
                } else {
                    Text("Guardar cambios")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("Perfil")
        .onAppear { loadProfile() }
        .alert("Perfil actualizado", isPresented: $showConfirmation) {
            Button("Aceptar", role: .cancel) { }
        }
    }

    private func loadProfile() {
        companyName = appState.profile?.companyName ?? ""
        rfc = appState.profile?.rfc ?? ""
        address = appState.profile?.address ?? ""
    }

    private func saveProfile() async {
        guard let userId = appState.profile?.id else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            try await SupabaseManager.shared.client.database
                .from("profiles")
                .update([
                    "company_name": companyName,
                    "rfc": rfc,
                    "address": address
                ])
                .eq("id", value: userId)
                .execute()
            await appState.loadProfile(for: userId)
            showConfirmation = true
        } catch {
            // handle error silently or show alert
        }
    }
}
