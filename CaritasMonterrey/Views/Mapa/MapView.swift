import SwiftUI
import MapKit
import CoreLocation
import Auth

struct MapView: View {
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var locationManager = CLLocationManager()
    @EnvironmentObject private var viewModel: MapaViewModel
    @EnvironmentObject private var appState: AppState

    @State private var fullMap = true
    
    // --- NUEVA ARQUITECTURA DE SHEETS ---
    private enum MapSheet: Identifiable {
        case detail(Location)
        case donation(Location)
        
        var id: String {
            switch self {
            case .detail(let location): return "detail-\(location.id)"
            case .donation(let location): return "donation-\(location.id)"
            }
        }
    }
    
    @State private var activeSheet: MapSheet?

    var body: some View {
        VStack {
            Map(position: $position) {
                UserAnnotation()

                ForEach(viewModel.locations) { location in
                    let coordinate = CLLocationCoordinate2D(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )
                    
                    Annotation(location.name, coordinate: coordinate, anchor: .bottom) {
                        Button {
                            activeSheet = .detail(location)
                        } label: {
                            BubbleAnnotationLabel(
                                icon: "building.2.fill",
                                isActive: location.isActive
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .onAppear {
                locationManager.requestWhenInUseAuthorization()
                if viewModel.locations.isEmpty {
                    Task { await viewModel.fetchMapa() }
                }
            }
            .mapControls {
                if fullMap {
                    MapUserLocationButton()
                }
            }
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .detail(let location):
                LocationDetailSheet(
                    location: location,
                    onDonarAqui: {
                        activeSheet = .donation(location)
                    }
                )
                // --- CAMBIO CLAVE DE UX ---
                // Iniciamos con una altura pequeña (aprox 20-25% de la pantalla) para no tapar el mapa.
                // Permitimos expandir a mediano y grande para ver detalles y Street View.
                .presentationDetents([.fraction(0.25), .medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled(upThrough: .medium)) // Permite interactuar con el mapa si el sheet está bajo
                
            case .donation(let location):
                DonationSheet(
                    viewModel: DonationSheetViewModel(preselectedBazaar: location)
                )
                .environmentObject(appState)
                .presentationDetents([.large])
            }
        }
    }
}

// MARK: - Componentes Visuales

private struct LocationDetailSheet: View {
    let location: Location
    var onDonarAqui: () -> Void
    
    // Estado para la vista de 360 (Street View)
    @State private var lookAroundScene: MKLookAroundScene?
    
    var isOpen: Bool {
        return location.isActive
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // --- Encabezado Compacto ---
                    // Esta es la parte que se ve primero en el detent pequeño
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(location.name)
                                .font(.title2).bold()
                                .lineLimit(1)
                            
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(isOpen ? Color.green : Color.red)
                                    .frame(width: 8, height: 8)
                                
                                Text(isOpen ? "Abierto para recibir" : "No recibe donaciones")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(isOpen ? .green : .red)
                            }
                        }
                        Spacer()
                        DismissButton()
                    }
                    
                    // Botón de acción principal visible desde el inicio
                    Button(action: onDonarAqui) {
                        HStack {
                            if isOpen {
                                Text("Donar aquí")
                                Image(systemName: "arrow.right")
                            } else {
                                Text("No disponible")
                                Image(systemName: "nosign")
                            }
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .tint(isOpen ? Color("AccentColor") : Color.gray)
                    .disabled(!isOpen)
                    .padding(.bottom, 8) // Separación visual antes del contenido detallado

                    Divider()
                    
                    // --- Contenido Expandido ---
                    // Esto se verá mejor al subir el sheet a .medium o .large
                    
                    VStack(alignment: .leading, spacing: 12) {
                        // Dirección
                        if !location.address.isEmpty {
                            Label(location.address, systemImage: "mappin.and.ellipse")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        
                        // Street View (Look Around)
                        if let scene = lookAroundScene {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Vista de calle")
                                    .font(.headline)
                                
                                LookAroundPreview(initialScene: scene)
                                    .frame(height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.tertiary, lineWidth: 1)
                                    )
                            }
                            .transition(.opacity)
                        } else {
                            // Placeholder o estado de carga opcional para Street View
                            HStack {
                                Spacer()
                                ProgressView()
                                    .controlSize(.small)
                                Spacer()
                            }
                            .frame(height: 50)
                        }

                        // Artículos aceptados
                        Text("Artículos aceptados")
                            .font(.headline)
                            .padding(.top, 4)
                        
                        let acceptedItems = location.acceptedItemTags
                        if acceptedItems.isEmpty {
                            Text("Este bazar no tiene información específica.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            AcceptedItemsView(items: acceptedItems)
                        }
                    }
                }
                .padding(24)
            }
            // Cargar la escena de Street View al aparecer
            .task {
                await fetchLookAroundScene()
            }
            .onChange(of: location.id) {
                Task { await fetchLookAroundScene() }
            }
        }
    }
    
    // Función para obtener la escena de LookAround
    private func fetchLookAroundScene() async {
        // Reseteamos primero para evitar mostrar una ubicación anterior
        lookAroundScene = nil
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let request = MKLookAroundSceneRequest(coordinate: coordinate)
        do {
            lookAroundScene = try await request.scene
        } catch {
            print("Error cargando LookAround: \(error.localizedDescription)")
        }
    }
}

// Actualizamos la burbuja
struct BubbleAnnotationLabel: View {
    let icon: String
    var isActive: Bool = true

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    isActive ?
                    AnyShapeStyle(LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.40, blue: 0.60),
                            Color(red: 1.0, green: 0.10, blue: 0.40)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )) :
                    AnyShapeStyle(Color.gray)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.25), lineWidth: 0.8)
        )
        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Helpers

private struct AcceptedItemsView: View {
    let items: [Location.AcceptedItem]
    
    var body: some View {
        // Usamos FlowLayout simplificado con LazyVGrid o un Wrapper personalizado si tienes uno.
        // Como fallback usamos un LazyVGrid adaptativo que se ve muy bien para "píldoras".
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

private struct DismissButton: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .foregroundStyle(Color(.systemFill))
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
