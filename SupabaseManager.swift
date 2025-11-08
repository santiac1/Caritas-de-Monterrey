//
//  SupabaseManager.swift
//  CaritasMonterrey
//
//  Created by José de Jesùs Jiménez Martínez on 04/11/25.
//

import Foundation
import Supabase
import Combine

@MainActor
final class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    let client: SupabaseClient

    private init() {
        // Formateador compatible con fechas "YYYY-MM-DD"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        // Decodificador personalizado que utiliza el formateador anterior
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        // Opciones del cliente con el decodificador personalizado para la base de datos
        let options = SupabaseClientOptions(
            db: .init(decoder: decoder)
        )

        // Inicialización del cliente compartido
        client = SupabaseClient(
            supabaseURL: AppEnvironment.supabaseURL,
            supabaseKey: AppEnvironment.supabaseAnonKey,
            options: options
        )
    }
}


