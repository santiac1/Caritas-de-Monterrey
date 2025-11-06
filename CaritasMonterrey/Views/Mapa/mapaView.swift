//
//  FullMapView.swift
//  test
//
//  Created by Victor Valero on 06/10/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct mapaView: View {
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var locationManager = CLLocationManager()
    @StateObject var viewModel = MapaViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var fullMap = true

    var body: some View {
            //map
            VStack {
                Map(position: $position) {
                    UserAnnotation()

                    // Anotaciones dinámicas desde Supabase
                    ForEach(viewModel.Locations) { Location in
                        let coordinate = CLLocationCoordinate2D(
                            latitude: CLLocationDegrees(Location.latitude),
                            longitude: CLLocationDegrees(Location.longitude)
                        )
                        Annotation(Location.name, coordinate: coordinate) {
                            BubbleAnnotationLabel(icon: "building.2.fill")
                        }
                    }
                }

                .mapStyle(.standard(elevation: .realistic))
                .onAppear {
                    locationManager.requestWhenInUseAuthorization()
                    Task {
                        await viewModel.fetchMapa()
                    }
                }
                .mapControls {
                    if fullMap {
                        MapUserLocationButton()
                    }
                }
            }

            }
        }


//diseño para los puntos
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
    mapaView()
}
