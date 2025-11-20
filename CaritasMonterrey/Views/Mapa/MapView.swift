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
    
    // 1. Maneja qué bazar está seleccionado para mostrar el primer sheet.
    @State private var selectedLocation: Location?
    
    // 2. Maneja la aparición del SEGUNDO sheet (DonationSheet).
    @State private var showingDonationSheet = false
    
    // 3. Almacena el VM preconfigurado para el DonationSheet.
    @State private var donationSheetViewModel: DonationSheetViewModel?

    var body: some View {
        VStack {
            // --- CORRECCIÓN 1: Eliminamos el 'selection' de aquí ---
            Map(position: $position) {
                UserAnnotation()

                ForEach(viewModel.Locations) { location in
                    
                    // --- CORRECCIÓN 2: Typo '2D' ---
                    let coordinate = CLLocationCoordinate2D(
                        latitude: CLLocationDegrees(location.latitude),
                        longitude: CLLocationDegrees(location.longitude)
                    )
                    
                    Annotation(location.name, coordinate: coordinate, anchor: .bottom) {
                        
                        // --- CORRECCIÓN 3: Envolvemos la burbuja en un Button ---
                        Button {
                            self.selectedLocation = location
                        } label: {
                            BubbleAnnotationLabel(icon: "building.2.fill")
                        }
                        .buttonStyle(.plain) // Importante para que no parezca un botón de texto
                    }
                    // .tag(location) // <-- Ya no se necesita
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .onAppear {
                locationManager.requestWhenInUseAuthorization()
                Task { await viewModel.fetchMapa() }
            }
            .mapControls {
                if fullMap {
                    MapUserLocationButton()
                }
            }
        }
        // --- PRIMER SHEET: Muestra detalles del bazar ---
        // Esto funciona porque tu 'Location' es Identifiable (implícito por el ForEach)
        .sheet(item: $selectedLocation) { location in
            LocationDetailSheet(
                location: location,
                onDonarAqui: {
                    // 1. Crear el VM preconfigurado
                    self.donationSheetViewModel = DonationSheetViewModel(preselectedBazaar: location)
                    // 2. Descartar el primer sheet
                    self.selectedLocation = nil
                    // 3. Activar el segundo sheet
                    self.showingDonationSheet = true
                }
            )
            .presentationDetents([.height(350), .medium]) // Controlar altura
            .presentationDragIndicator(.visible)
        }
        // --- SEGUNDO SHEET: Muestra el formulario de donación ---
        .sheet(isPresented: $showingDonationSheet) {
            if let vm = donationSheetViewModel {
                DonationSheet(viewModel: vm)
                    .environmentObject(appState) // Pasar el appState
            } else {
                Text("Error al cargar formulario") // Fallback
            }
        }
    }
}

// MARK: - Vista de Detalle del Bazar (NUEVA)
/// El primer sheet que se abre al tocar un pin del mapa.
private struct LocationDetailSheet: View {
    
    let location: Location
    var onDonarAqui: () -> Void // Callback para abrir el DonationSheet
    
    // Placeholder para el estado (abierto/cerrado)
    var isOpen: Bool {
        // Aquí puedes poner lógica de horario real
        return true // Asumimos que siempre está abierto por ahora
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                
                // --- Encabezado ---
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(location.name)
                            .font(.title2).bold()
                        
                        Text(isOpen ? "Abierto" : "Cerrado")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(isOpen ? .green : .red)
                    }
                    Spacer()
                    // Botón para cerrar el sheet
                    DismissButton()
                }
                
                // --- Artículos Aceptados ---
                Text("Artículos aceptados")
                    .font(.headline)
                
                let acceptedItems = location.acceptedItemTags
                if acceptedItems.isEmpty {
                    Text("No se especifican artículos por ahora.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    // Muestra las "píldoras" de lo que se acepta
                    AcceptedItemsView(items: acceptedItems)
                }
                
                Spacer()
                
                // --- Botón de Acción ---
                Button(action: onDonarAqui) {
                    Text("Donar en este bazar")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(Color("AccentColor")) // Usa tu color de acento
                
            }
            .padding(24)
        }
    }
}

// --- Vista Auxiliar para las "píldoras" ---
private struct AcceptedItemsView: View {
    let items: [Location.AcceptedItem]
    
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: 100) // Ajusta la altura según sea necesario
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.items, id: \.name) { item in
                self.item(for: item)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if item.name == self.items.last!.name {
                            width = 0 // Reseteo final
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if item.name == self.items.last!.name {
                            height = 0 // Reseteo final
                        }
                        return result
                    })
            }
        }
    }

    private func item(for item: Location.AcceptedItem) -> some View {
        HStack(spacing: 4) {
            Image(systemName: item.icon)
            Text(item.name)
        }
        .font(.caption)
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// --- Botón de Cerrar Personalizado ---
private struct DismissButton: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title)
                .foregroundStyle(Color(.systemFill))
        }
    }
}


// MARK: - Helpers
// --- Extensión de Location para la UI ---
// (Asumiendo que tu modelo 'Location' no la tiene)
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

// --- Tu 'BubbleAnnotationLabel' sin cambios ---
struct BubbleAnnotationLabel: View {
    let icon: String

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
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.40, blue: 0.60), // rosa
                            Color(red: 1.0, green: 0.10, blue: 0.40)  // fucsia
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.25), lineWidth: 0.8)
        )
        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
    }
}

#Preview {
    // Necesitarás actualizar tu preview para inyectar el AppState
    MapView()
        .environmentObject(MapaViewModel())
        .environmentObject(AppState()) // <-- Añadir
}

