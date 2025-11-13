import SwiftUI

struct BazaarManagementView: View {
    @EnvironmentObject private var viewModel: BazaarManagementViewModel
    @State private var isPresentingForm = false
    @State private var editingLocation: Location?
    @State private var deletingLocation: Location?
    @State private var isDeleteAlertPresented = false
    
    

    var body: some View {
        List {
            ForEach(viewModel.locations) { location in
                BazaarCard(
                    location: location,
                    onEdit: {
                        editingLocation = location
                        isPresentingForm = true
                    },
                    onDelete: {
                        deletingLocation = location
                        isDeleteAlertPresented = true
                    }
                )
                .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .contextMenu {
                    Button(role: .destructive) {
                        deletingLocation = location
                        isDeleteAlertPresented = true
                    } label: {
                        Label("Eliminar bazar", systemImage: "trash")
                    }
                    Button {
                        editingLocation = location
                        isPresentingForm = true
                    } label: {
                        Label("Editar bazar", systemImage: "pencil")
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        deletingLocation = location
                        isDeleteAlertPresented = true
                    } label: {
                        Label("Eliminar", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button {
                        editingLocation = location
                        isPresentingForm = true
                    } label: {
                        Label("Editar", systemImage: "pencil")
                    }
                    .tint(Color("AccentColor"))
                }
            }
            .listSectionSeparator(.hidden)
        }
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .listStyle(.plain)
        .navigationTitle("Gestión de bazares")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    editingLocation = nil
                    isPresentingForm = true
                } label: {
                    Label("Nuevo bazar", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("AccentColor"))
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
                .toolbarTitleDisplayMode(.inline)
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
        .alert("Eliminar bazar", isPresented: $isDeleteAlertPresented, presenting: deletingLocation) { location in
            Button("Cancelar", role: .cancel) {
                deletingLocation = nil
            }
            Button("Eliminar", role: .destructive) {
                Task { await viewModel.deleteLocation(location.id) }
            }
        } message: { _ in
            Text("Esta acción eliminará el bazar de forma permanente de la base de datos.")
        }
    }
}

private struct BazaarCard: View {
    @Environment(\.colorScheme) private var scheme

    let location: Location
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(location.name)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Group {
                            if location.isActive {
                                Image(systemName: "checkmark.circle.fill")
                                    .symbolRenderingMode(.monochrome)
                                    .foregroundStyle(scheme == .dark ? .white : Color.secondaryBlue)
                            } else {
                                Image(systemName: "xmark.circle.fill")
                                    .symbolRenderingMode(.monochrome)
                                    .foregroundStyle(Color(.systemGray3))
                            }
                        }
                        .font(.headline)

                    }
                    
                    Text(location.address)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                Menu {
                    Button { onEdit() } label: { Label("Editar bazar", systemImage: "pencil") }
                    Button(role: .destructive) { onDelete() } label: { Label("Eliminar bazar", systemImage: "trash") }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .foregroundStyle(Color("AccentColor"))
                }
            }


            let models = acceptingTagModels(from: location)
            if !models.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Aceptando:")
                        .font(.footnote).bold()
                        .foregroundStyle(.secondary)

                    // filas de hasta 3 tags
                    let rows = chunk(models, by: 3)
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                            HStack(spacing: 8) {
                                ForEach(row, id: \.title) { m in
                                    AcceptTag(title: m.title, systemName: m.systemName)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(glassBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08))
        }
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
    }

    @ViewBuilder
    private var glassBackground: some View {
        if #available(iOS 18.0, *) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.thinMaterial)
        } else {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
        }
    }
}

// MARK: - Helpers para tags

private struct AcceptTagModel {
    let title: String
    let systemName: String
}

private func acceptingTagModels(from l: Location) -> [AcceptTagModel] {
    var result: [AcceptTagModel] = []

    if l.food       { result.append(.init(title: "Alimentos",         systemName: "fork.knife")) }
    if l.clothes    { result.append(.init(title: "Ropa",              systemName: "tshirt.fill")) }
    if l.equipment  { result.append(.init(title: "Equipo",            systemName: "wrench.and.screwdriver")) }
    if l.furniture  { result.append(.init(title: "Muebles",           systemName: "sofa.fill")) }
    if l.appliances { result.append(.init(title: "Electrodomésticos", systemName: "powerplug")) }
    if l.cleaning   { result.append(.init(title: "Limpieza",          systemName: "sparkles")) }
    if l.medicine   { result.append(.init(title: "Medicinas",         systemName: "cross.case.fill")) }

    return result
}

private func chunk<T>(_ array: [T], by size: Int) -> [[T]] {
    guard size > 0 else { return [array] }
    var result: [[T]] = []
    var current: [T] = []
    current.reserveCapacity(size)

    for item in array {
        current.append(item)
        if current.count == size {
            result.append(current)
            current.removeAll(keepingCapacity: true)
        }
    }
    if !current.isEmpty { result.append(current) }
    return result
}

private struct AcceptTag: View {
    let title: String
    let systemName: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemName)
                .font(.caption)
            Text(title)
                .font(.caption).bold()
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .foregroundStyle(.primary)
        .background(
            Capsule()
                .fill(Color.primary.opacity(0.08)) // gris translúcido adaptado a Light/Dark
        )
    }
}

// MARK: - Form

private struct LocationForm: View {
    var location: Location?
    var onSave: (LocationPayload) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var address: String = ""
    @State private var isActive: Bool = true
    @State private var food: Bool = false
    @State private var clothes: Bool = false
    @State private var equipment: Bool = false
    @State private var furniture: Bool = false
    @State private var appliances: Bool = false
    @State private var cleaning: Bool = false
    @State private var medicine: Bool = false

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
            Section("Estatus") {
                Toggle("Bazar abierto", isOn: $isActive)
                    .tint(Color("AccentColor"))
            }
            Section("Tipos de donación aceptada") {
                Toggle("Alimentos", isOn: $food).tint(Color("AccentColor"))
                Toggle("Ropa", isOn: $clothes).tint(Color("AccentColor"))
                Toggle("Equipo", isOn: $equipment).tint(Color("AccentColor"))
                Toggle("Muebles", isOn: $furniture).tint(Color("AccentColor"))
                Toggle("Electrodomésticos", isOn: $appliances).tint(Color("AccentColor"))
                Toggle("Limpieza", isOn: $cleaning).tint(Color("AccentColor"))
                Toggle("Medicinas", isOn: $medicine).tint(Color("AccentColor"))
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
                    let payload = LocationPayload(
                        name: name,
                        latitude: lat,
                        longitude: lon,
                        address: address,
                        isActive: isActive,
                        food: food,
                        clothes: clothes,
                        equipment: equipment,
                        furniture: furniture,
                        appliances: appliances,
                        cleaning: cleaning,
                        medicine: medicine
                    )
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
                isActive = location.isActive
                food = location.food
                clothes = location.clothes
                equipment = location.equipment
                furniture = location.furniture
                appliances = location.appliances
                cleaning = location.cleaning
                medicine = location.medicine
            }
        }
    }
}
