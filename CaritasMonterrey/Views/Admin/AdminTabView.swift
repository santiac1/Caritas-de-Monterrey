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

private struct AdminHelpRequestsView: View {
    @EnvironmentObject private var viewModel: AdminHelpRequestsViewModel

    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            ForEach(viewModel.donations) { donation in
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
        .task { await viewModel.loadHelpRequests() }
        .refreshable { await viewModel.loadHelpRequests() }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in }
        )) {
            Button("Aceptar", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

private struct BazaarManagementView: View {
    @EnvironmentObject private var viewModel: BazaarManagementViewModel
    @State private var isPresentingForm = false
    @State private var editingLocation: Location?

    var body: some View {
        List {
            ForEach(viewModel.locations) { location in
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
                    let location = viewModel.locations[index]
                    Task { await viewModel.deleteLocation(location.id) }
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
        .task { await viewModel.loadLocations() }
        .sheet(isPresented: $isPresentingForm, onDismiss: { Task { await viewModel.loadLocations() } }) {
            NavigationStack {
                LocationForm(location: editingLocation) { payload in
                    Task {
                        if let editingLocation {
                            await viewModel.updateLocation(editingLocation.id, with: payload)
                        } else {
                            await viewModel.createLocation(payload)
                        }
                    }
                }
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in }
        )) {
            Button("Aceptar", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
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
