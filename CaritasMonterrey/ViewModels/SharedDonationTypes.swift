//
//  SharedDonationTypes.swift
//  CaritasMonterrey
//
//  Created by Alumno on 27/11/25.
//

import SwiftUI

enum SortOrder: String, CaseIterable, Identifiable {
    case newest = "Más recientes"
    case oldest = "Más antiguas"
    
    var id: String { rawValue }
    var title: String { rawValue }
}

enum DonationFilter: String, CaseIterable, Identifiable {
    case all = "Todas"
    case inProcess = "En proceso"
    case accepted = "Aprobadas"
    case received = "Recibidas"
    case rejected = "Rechazadas"

    var id: String { rawValue }
    var title: String { rawValue }

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
