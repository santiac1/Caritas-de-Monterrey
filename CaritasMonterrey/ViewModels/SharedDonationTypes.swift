//
//  SharedDonationTypes.swift
//  CaritasMonterrey
//
//  Created by Alumno on 27/11/25.
//

import SwiftUI

// MARK: - Enums Globales

/// Opciones de ordenamiento
enum SortOrder: String, CaseIterable, Identifiable {
    case newest = "Más recientes"
    case oldest = "Más antiguas"
    
    var id: String { rawValue }
    var title: String { rawValue }
}

/// Filtros de estado para donaciones
enum DonationFilter: String, CaseIterable, Identifiable {
    case all = "Todas"
    case inProcess = "En proceso"
    case accepted = "Aprobadas"
    case received = "Recibidas"
    case rejected = "Rechazadas"

    var id: String { rawValue }
    var title: String { rawValue }

    // Mapeo al valor exacto de la base de datos (Supabase)
    var dbValue: String? {
        switch self {
        case .inProcess: return "in_process"
        case .accepted: return "accepted"
        case .received: return "received"
        case .rejected: return "rejected"
        case .all: return nil
        }
    }
}
