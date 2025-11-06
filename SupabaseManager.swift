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
            // 1. Creamos un formateador para el estilo "YYYY-MM-DD"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            // 2. Creamos un decodificador JSON personalizado
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)

            // --- INICIO DE LA CORRECCIÓN ---
            
            // 3. Creamos las opciones de 'Database' (db) y le pasamos el decodificador
            let dbOptions = SupabaseClientOptions.DBOptions(decoder: decoder)
            
            // 4. Creamos las opciones principales del cliente, pasándole nuestras 'dbOptions'
            let clientOptions = SupabaseClientOptions(db: dbOptions)
            
            // --- FIN DE LA CORRECCIÓN ---

            // 5. Creamos el cliente pasándole nuestras opciones
            client = SupabaseClient(
                supabaseURL: AppEnvironment.supabaseURL,
                supabaseKey: AppEnvironment.supabaseAnonKey,
                options: clientOptions
            )
        }
}

