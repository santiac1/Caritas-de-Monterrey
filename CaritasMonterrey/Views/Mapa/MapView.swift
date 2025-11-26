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
                // --- CAMBIO: Empezamos en .medium para ver más info de golpe ---
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                
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

// MARK: - Componentes Visuales del Mapa

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
