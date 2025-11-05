//
//  Donation.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//
//  Modificado por Gemini para ser "database-ready"
//

import Foundation
import SwiftUI

/// Define los estados posibles de una donación, basados en tu mockup.
/// Esto controlará el color y el texto de estado en las tarjetas.
enum DonationStatus: String, CaseIterable {
    case enProceso = "En proceso"
    case completada = "Completada"
    
    /// El color asociado con cada estado (como en tu mockup)
    var color: Color {
        switch self {
        case .enProceso:
            return Color(red: 0.4, green: 0.75, blue: 0.75) // Teal
        case .completada:
            return Color(red: 0.95, green: 0.5, blue: 0.3) // Naranja
        }
    }
    
    /// El icono SFSymbol asociado
    var iconName: String {
        switch self {
        case .enProceso:
            return "circle.dashed"
        case .completada:
            return "checkmark.circle.fill"
        }
    }
}

/// El modelo de datos principal para una donación.
/// Tu base de datos deberá devolver una lista de estos objetos.
struct Donation: Identifiable {
    let id: UUID
    let title: String
    let date: Date
    let location: String
    let status: DonationStatus
    
    /// Propiedad computada para formatear la fecha como en tu mockup
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd'/' MMMM '/' yyyy" // "10/ Diciembre / 2025"
        formatter.locale = Locale(identifier: "es_MX") // Para que "Diciembre" esté en español
        return formatter.string(from: date)
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Datos de Muestra (Mock Data)
    // -------------------------------------------------------------------------
    
    /// Aquí están los datos de muestra, guardados como una propiedad estática
    /// de la propia estructura Donation.
    static let sampleDonations: [Donation] = [
        Donation(id: UUID(), title: "Ropa de invierno", date: Date(), location: "Bazar Emilio Carranza", status: .enProceso),
        Donation(id: UUID(), title: "Artículos personales", date: Date().addingTimeInterval(-1000000), location: "Bazar Cáritas Centro", status: .completada),
        Donation(id: UUID(), title: "Juguetes", date: Date().addingTimeInterval(-2000000), location: "Bazar Emilio Carranza", status: .completada)
    ]
}
