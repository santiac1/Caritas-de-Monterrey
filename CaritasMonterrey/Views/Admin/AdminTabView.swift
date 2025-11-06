import SwiftUI
import Supabase

struct AdminTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                AdminHelpRequestsView()
            }
            .tabItem { Label("Solicitudes", systemImage: "tray.full.fill") }

            NavigationStack {
                BazaarManagementView()
            }
            .tabItem { Label("Bazares", systemImage: "building.2.fill") }
        }
    }
}

private struct AdminHelpRequestsView: View {
    @State private var donations: [Donation] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        List {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            ForEach(donations) { donation in
                NavigationLink(value: donation) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(donation.name)
                            .font(.headline)
                        if let weight = donation.shipping_weight {
                            Text("Peso estimado: \(weight)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        if let donor = donation.donorName {
                            Text("Donante: \(donor)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Solicitudes de ayuda")
        .navigationDestination(for: Donation.self) { donation in
            AdminSolicitudDetailView(donation: donation)
        }
        .task { await loadDonations() }
        .refreshable { await loadDonations() }
        .alert("Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { _ in errorMessage = nil }
        )) {
            Button("Aceptar", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func loadDonations() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetched: [Donation] = try await SupabaseManager.shared.client.database
                .from("Donations")
                .select()
                .eq("status", value: "solicitud_ayuda")
                .order(column: "created_at", ascending: false)
                .execute()
                .value

            let userIds = Array(Set(fetched.map { $0.user_id }))
            var profiles: [UUID: Profile] = [:]
            if !userIds.isEmpty {
                let profileList: [Profile] = try await SupabaseManager.shared.client.database
                    .from("profiles")
                    .select()
                    .in("id", values: userIds)
                    .execute()
                    .value
                profileList.forEach { profiles[$0.id] = $0 }
            }

            donations = fetched.map { donation in
                var donation = donation
                if let profile = profiles[donation.user_id] {
                    let fullName = [profile.firstName, profile.lastName].compactMap { $0 }.joined(separator: " ")
                    donation.donorName = !fullName.trimmingCharacters(in: .whitespaces).isEmpty ? fullName : profile.username
                }
                return donation
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

private struct BazaarManagementView: View {
    @State private var locations: [Location] = []
    @State private var isPresentingForm = false
    @State private var editingLocation: Location?
    @State private var errorMessage: String?

    var body: some View {
        List {
            ForEach(locations) { location in
                Button {
                    editingLocation = location
                    isPresentingForm = true
                } label: {
                    VStack(alignment: .leading) {
                        Text(location.name)
                            .font(.headline)
                        Text(location.address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    Task { await deleteLocation(locations[index]) }
                }
            }
        }
        .navigationTitle("Gestión de bazares")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    editingLocation = nil
                    isPresentingForm = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .task { await loadLocations() }
        .sheet(isPresented: $isPresentingForm, onDismiss: { Task { await loadLocations() } }) {
            NavigationStack {
                LocationForm(location: editingLocation) { payload in
                    Task {
                        if let editingLocation {
                            await updateLocation(editingLocation.id, with: payload)
                        } else {
                            await createLocation(payload)
                        }
                    }
                }
            }
        }
        .alert("Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { _ in errorMessage = nil }
        )) {
            Button("Aceptar", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func loadLocations() async {
        do {
            locations = try await SupabaseManager.shared.client.database
                .from("Locations")
                .select()
                .order(column: "name")
                .execute()
                .value
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func createLocation(_ payload: LocationPayload) async {
        do {
            try await SupabaseManager.shared.client.database
                .from("Locations")
                .insert(payload)
                .execute()
            await loadLocations()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func updateLocation(_ id: Int, with payload: LocationPayload) async {
        do {
            try await SupabaseManager.shared.client.database
                .from("Locations")
                .update(payload)
                .eq("id", value: id)
                .execute()
            await loadLocations()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deleteLocation(_ location: Location) async {
        do {
            try await SupabaseManager.shared.client.database
                .from("Locations")
                .delete()
                .eq("id", value: location.id)
                .execute()
            await loadLocations()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct LocationPayload: Encodable {
    var name: String
    var latitude: Double
    var longitude: Double
    var address: String
}

private struct LocationForm: View {
    var location: Location?
    var onSave: (LocationPayload) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var address: String = ""

    var body: some View {
        Form {
            Section("Detalles") {
                TextField("Nombre", text: $name)
                TextField("Dirección", text: $address)
                TextField("Latitud", text: $latitude)
                    .keyboardType(.decimalPad)
                TextField("Longitud", text: $longitude)
                    .keyboardType(.decimalPad)
            }
        }
        .navigationTitle(location == nil ? "Nuevo bazar" : "Editar bazar")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar") {
                    guard let lat = Double(latitude), let lon = Double(longitude) else { return }
                    let payload = LocationPayload(name: name, latitude: lat, longitude: lon, address: address)
                    onSave(payload)
                    dismiss()
                }
            }
        }
        .onAppear {
            if let location {
                name = location.name
                latitude = String(location.latitude)
                longitude = String(location.longitude)
                address = location.address
            }
        }
    }
}
