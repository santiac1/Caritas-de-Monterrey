//
//  FullMapView.swift
//  test
//
//  Created by Victor Valero on 06/10/25.
//

import SwiftUI
import MapKit
import CoreLocation

extension CLLocationCoordinate2D {
    static let bazar1 = CLLocationCoordinate2D(latitude: 25.679263, longitude: -100.340499)
    static let bazar2 = CLLocationCoordinate2D(latitude: 25.682716, longitude: -100.310453)
    static let bazar3 = CLLocationCoordinate2D(latitude: 25.784040, longitude: -100.407145)
    static let bazar4 = CLLocationCoordinate2D(latitude: 25.699485, longitude: -100.460740)
    static let bazar5 = CLLocationCoordinate2D(latitude: 25.659183, longitude: -100.368712)
    static let bazar6 = CLLocationCoordinate2D(latitude: 25.674526, longitude: -100.258442)
}

struct mapaView: View {
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var locationManager = CLLocationManager()
    @StateObject var viewModel = MapaViewModel()
    @State private var fullMap = true

    var body: some View {
        VStack {
            Map(position: $position) {
                UserAnnotation()

            
                ForEach(viewModel.Locations) { loc in
                    let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(loc.latitude),
                                                            longitude: CLLocationDegrees(loc.longitude))
                    Annotation(loc.name, coordinate: coordinate) {
                        BubbleAnnotationLabel(icon: "building.2.fill")
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .onAppear {
                locationManager.requestWhenInUseAuthorization()
                Task { await viewModel.fetchMapa() }
            }
            .mapControls {
                if fullMap { MapUserLocationButton() }
            }
        }
        .background(Color(.systemBackground)) // evita “pantalla negra”
        .navigationTitle("Mapa")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal, 0)
    }
}

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
                .fill(LinearGradient(colors: [Color(red: 1, green: 0.40, blue: 0.60),
                                              Color(red: 1, green: 0.10, blue: 0.40)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.25), lineWidth: 0.8)
        )
        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
    }
}

#Preview { mapaView() }
