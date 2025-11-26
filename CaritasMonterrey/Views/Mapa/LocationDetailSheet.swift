import SwiftUI
import MapKit

// MARK: - Vista de Detalle del Bazar
struct LocationDetailSheet: View {
    let location: Location
    var onDonarAqui: () -> Void
    
    // Estado para la vista de 360 (Street View)
    @State private var lookAroundScene: MKLookAroundScene?
    @Environment(\.dismiss) private var dismiss
    
    var isOpen: Bool {
        return location.isActive
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 1. ENCABEZADO PERSONALIZADO (Nombre + Botón Cerrar Alineados)
                    // Usamos esto en lugar del Toolbar para tener control total del diseño
                    HStack(alignment: .top) {
                        Text(location.name)
                            .font(.title).bold()
                            .fixedSize(horizontal: false, vertical: true) // Permite múltiples líneas si es largo
                        
                        Spacer()
                        
                        // Botón "X" minimalista
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(.gray)  // Color discreto
                                .padding(8)              // Área de toque
                                
                        }
                        .buttonStyle(.glass) // Evita animaciones o estilos extraños
                        .buttonBorderShape(.circle)
                    }
                    
                    // 2. ESTADO
                    HStack(spacing: 6) {
                        Circle()
                            .fill(isOpen ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        
                        Text(isOpen ? "Abierto para recibir" : "No recibe donaciones")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(isOpen ? .green : .red)
                    }
                    // Quitamos padding top extra porque ya está en el HStack del encabezado
                    
                    // 3. TAGS (Artículos aceptados)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Artículos aceptados")
                            .font(.headline)
                        
                        let acceptedItems = location.acceptedItemTags
                        if acceptedItems.isEmpty {
                            Text("Información general disponible.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            AcceptedItemsView(items: acceptedItems)
                        }
                    }
                    
                    // 4. BOTÓN DE DONAR
                    Button(action: onDonarAqui) {
                        HStack {
                            if isOpen {
                                Text("Donar en este bazar")
                                Image(systemName: "arrow.right")
                            } else {
                                Text("Bazar no disponible")
                                Image(systemName: "nosign")
                            }
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(isOpen ? Color("AccentColor") : Color.gray)
                    .disabled(!isOpen)
                    
                    Divider()
                    
                    // 5. STREET VIEW (Look Around)
                    if let scene = lookAroundScene {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Vista de calle")
                                .font(.headline)
                            
                            LookAroundPreview(initialScene: scene)
                                .frame(height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.tertiary, lineWidth: 1)
                                )
                        }
                        .transition(.opacity)
                    } else {
                        // Espacio reservado mientras carga
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .frame(height: 100)
                    }
                    
                    // 6. DIRECCIÓN (Al final)
                    if !location.address.isEmpty {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color("AccentColor"))
                            
                            Text(location.address)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(24)
            }
            // Ocultamos la barra de sistema para que nuestro encabezado mande
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await fetchLookAroundScene()
            }
            .onChange(of: location.id) {
                Task { await fetchLookAroundScene() }
            }
        }
    }
    
    private func fetchLookAroundScene() async {
        lookAroundScene = nil
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let request = MKLookAroundSceneRequest(coordinate: coordinate)
        do {
            lookAroundScene = try await request.scene
        } catch {
            // Silencioso
        }
    }
}

// MARK: - Componentes Auxiliares

struct AcceptedItemsView: View {
    let items: [Location.AcceptedItem]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
            ForEach(items, id: \.name) { item in
                HStack(spacing: 4) {
                    Image(systemName: item.icon)
                    Text(item.name)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

// Extensión para transformar los booleanos del modelo en etiquetas visuales
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
