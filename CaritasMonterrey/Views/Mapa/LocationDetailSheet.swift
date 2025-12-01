import SwiftUI
import MapKit

// Detalles por bazar
struct LocationDetailSheet: View {
    let location: Location
    var onDonarAqui: () -> Void
    
    @State private var lookAroundScene: MKLookAroundScene?
    @Environment(\.dismiss) private var dismiss
    
    var isOpen: Bool {
        return location.isActive
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Vista de calle del bazar
                    if let scene = lookAroundScene {
                        LookAroundPreview(initialScene: scene)
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.tertiary, lineWidth: 1)
                            )
                            .transition(.opacity)
                    }
                    
                    // Dirección bazar
                    if !location.address.isEmpty {
                        Text(location.address)
                            .font(.caption) // Letra más pequeña
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Mostrar su estatus
                    HStack(spacing: 6) {
                        Circle()
                            .fill(isOpen ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        
                        Text(isOpen ? "Abierto" : "Cerrado")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(isOpen ? .green : .red)
                        
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Artículos aceptados")
                            .font(.headline)
                        
                        let acceptedItems = location.acceptedItemTags
                        if acceptedItems.isEmpty {
                            Text("Información general disponible.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            AcceptedItemsView(items: acceptedItems)
                        }
                    }
                    
                    // Acción de donación
                    Button(action: onDonarAqui) {
                        HStack {
                            if isOpen {
                                Text("Donar en este bazar")
                                Image(systemName: "arrow.right")
                            } else {
                                Text("No disponible")
                                Image(systemName: "nosign")
                            }
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 2)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(isOpen ? Color("AccentColor") : Color.gray)
                    .disabled(!isOpen)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12) //
                .padding(.bottom, 24)
            }
            .navigationTitle(location.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        openInMaps()
                    } label: {
                        Image(systemName: "map.fill")
                            .foregroundStyle(Color("AccentColor"))
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body)
                            .fontWeight(.regular)
                            .foregroundStyle(.secondary)
                            .padding(4)
                    }
                }
            }
            .task {
                await fetchLookAroundScene()
            }
            .onChange(of: location.id) {
                Task { await fetchLookAroundScene() }
            }
        }
    }
    
    private func openInMaps() {
        let locationObj = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let mapItem = MKMapItem(location: locationObj, address: nil)
        
        mapItem.name = location.name
        mapItem.openInMaps()
    }
    
    private func fetchLookAroundScene() async {
        lookAroundScene = nil
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let request = MKLookAroundSceneRequest(coordinate: coordinate)
        do {
            lookAroundScene = try await request.scene
        } catch { }
    }
}

struct AcceptedItemsView: View {
    let items: [Location.AcceptedItem]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items, id: \.name) { item in
                    Image(systemName: item.icon)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .padding(8)
                        .background(
                            Capsule()
                                .fill(Color.gray.opacity(0.1))
                        )
                }
            }
        }
    }
}

extension Location {
    struct AcceptedItem: Hashable {
        let name: String
        let icon: String
    }
    
    var acceptedItemTags: [AcceptedItem] {
        var items: [AcceptedItem] = []
        if food { items.append(.init(name: "Alimentos", icon: "cart.fill")) }
        if clothes { items.append(.init(name: "Ropa", icon: "tshirt.fill")) }
        if equipment { items.append(.init(name: "Equipo", icon: "wrench.and.screwdriver")) }
        if furniture { items.append(.init(name: "Muebles", icon: "sofa.fill")) }
        if appliances { items.append(.init(name: "Electrodomésticos", icon: "powerplug")) }
        if cleaning { items.append(.init(name: "Limpieza", icon: "sparkles")) }
        if medicine { items.append(.init(name: "Medicinas", icon: "cross.case.fill")) }
        return items
    }
}
