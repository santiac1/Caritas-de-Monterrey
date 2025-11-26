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
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // CORRECCIÓN: Creamos los formateadores localmente.
            // Esto elimina el error de 'nonisolated'/'Sendable' porque cada hilo
            // tiene su propia instancia segura del formateador.
            
            // 1. Intentar formato con segundos fraccionales (común en Supabase)
            let iso8601WithFractional = ISO8601DateFormatter()
            iso8601WithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = iso8601WithFractional.date(from: dateString) {
                return date
            }
            
            // 2. Intentar formato estándar
            let iso8601 = ISO8601DateFormatter()
            iso8601.formatOptions = [.withInternetDateTime]
            if let date = iso8601.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Formato de fecha no soportado: \(dateString)"
                )
            )
        }

        // Configuración de Auth corregida para evitar advertencias futuras
        let options = SupabaseClientOptions(
            db: .init(decoder: decoder),
            auth: .init(emitLocalSessionAsInitialSession: true)
        )

        client = SupabaseClient(
            supabaseURL: AppEnvironment.supabaseURL,
            supabaseKey: AppEnvironment.supabaseAnonKey,
            options: options
        )
    }
}
