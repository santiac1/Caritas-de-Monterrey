//
//  MapViewModel.swift
//  CaritasMonterrey
//
//  Created by José de Jesùs Jiménez Martínez on 04/11/25.
//

import Foundation
import SwiftUI
import Supabase
import Combine

@MainActor
final class MapaViewModel: ObservableObject {
    @Published var locations: [Location] = [] // Cambié mayúscula Locations -> locations (convención Swift)
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Helper: Si alguna vista necesita solo los abiertos
    var activeLocations: [Location] {
        locations.filter { $0.isActive }
    }
    
    func fetchMapa() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Traemos todos para mostrarlos en el mapa (abiertos y cerrados)
            let response = try await SupabaseManager.shared.client
                .from("Locations")
                .select()
                .execute()
            
            let datosDecodificados = try JSONDecoder().decode([Location].self, from: response.data)
            self.locations = datosDecodificados
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
