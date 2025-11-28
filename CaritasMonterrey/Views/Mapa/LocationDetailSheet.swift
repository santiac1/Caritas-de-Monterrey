import SwiftUI
import MapKit

// MARK: - Vista de Detalle del Bazar
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
                VStack(alignment: .leading, spacing: 16) { // Reduje el espaciado general
                    
                    // 1. VISTA DE CALLE (Ahora al principio)
                    if let scene = lookAroundScene {
                        LookAroundPreview(initialScene: scene)
                            .frame(height: 160) // Un poco más compacto
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.tertiary, lineWidth: 1)
                            )
                            .transition(.opacity)
                    }
                    
                    // 2. DIRECCIÓN (Debajo de la vista de calle)
                    if !location.address.isEmpty {
                        Text(location.address)
                            .font(.caption) // Letra más pequeña
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // 3. STATUS (Abierto/Cerrado)
                    HStack(spacing: 6) {
                        Circle()
                            .fill(isOpen ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        
                        Text(isOpen ? "Abierto" : "Cerrado")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(isOpen ? .green : .red)
                        
                        Spacer() // Empuja al inicio si hubiera algo más, o solo alinea izq
                    }
                    
                    // 4. ARTÍCULOS ACEPTADOS (Tags más pequeños)
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
                    
                    // 5. BOTÓN DE DONAR (Al final)
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
                        .padding(.vertical, 2) // Padding vertical interno reducido
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(isOpen ? Color("AccentColor") : Color.gray)
                    .disabled(!isOpen)
                    .padding(.top, 8) // Separación extra antes del botón
                }
                .padding(.horizontal, 24)
                .padding(.top, 12) // ✅ Reduje mucho el espacio superior (antes 24)
                .padding(.bottom, 24)
            }
            // --- TOOLBAR (Acciones y Título) ---
            .navigationTitle(location.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Izquierda: Mapas
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        openInMaps()
                    } label: {
                        Image(systemName: "map.fill")
                            .foregroundStyle(Color("AccentColor"))
                    }
                }
                
                // Derecha: Cerrar
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
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
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

// MARK: - Componentes Auxiliares

struct AcceptedItemsView: View {
    let items: [Location.AcceptedItem]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items, id: \.name) { item in
                    Image(systemName: item.icon)
                        .font(.body) // ✅ Más pequeño (antes title3)
                        .foregroundStyle(.primary)
                        .padding(8) // ✅ Menos padding (antes 10)
                        .background(
                            Capsule()
                                .fill(Color.gray.opacity(0.1))
                        )
                }
            }
        }
    }
}

// Extensión de modelo (sin cambios)
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
