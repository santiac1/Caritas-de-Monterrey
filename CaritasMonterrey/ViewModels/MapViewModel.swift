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

class MapaViewModel: ObservableObject {
    @Published var Locations: [Location] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchMapa() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await SupabaseManager.shared.client.from("Locations").select().execute()
            let datosDecodificados = try JSONDecoder().decode([Location].self, from: response.data)
            self.Locations = datosDecodificados
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
}
