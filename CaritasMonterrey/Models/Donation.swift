import Foundation
import SwiftUI

enum DonationDBStatus: String, Codable, CaseIterable, Hashable {
    case in_process = "in_process"
    case accepted   = "accepted"
    case rejected   = "rejected"
    case returned   = "returned"
    case received   = "received"
}

enum DonationStatusDisplay: String, CaseIterable {
    case enProceso = "En proceso"
    case completada = "Aprobada"
    case solicitudAyuda = "Solicitud de ayuda"
    case ayudaAprobada = "Ayuda aprobada"
    case ayudaRechazada = "Rechazada"
    case recibida = "Recibida"

    var color: Color {
        switch self {
        case .enProceso:        return .primaryCyan
        case .completada:       return .green
        case .solicitudAyuda:   return .orangeCaritas
        case .ayudaAprobada:    return .green
        case .ayudaRechazada:   return .red
        case .recibida:         return .magentaCaritas
        }
    }

    var iconName: String {
        switch self {
        case .enProceso:        return "circle.dashed"
        case .completada:       return "checkmark.circle.fill"
        case .solicitudAyuda:   return "paperplane.fill"
        case .ayudaAprobada:    return "hand.thumbsup.fill"
        case .ayudaRechazada:   return "xmark.octagon.fill"
        case .recibida:         return "shippingbox.circle.fill"
        }
    }
}

enum DonationTypeDB: String, Codable, CaseIterable {
    case monetaria, ropa, alimentos, equipo, muebles, otros
}

struct Donation: Identifiable, Codable, Hashable {
    let id: Int
    let user_id: UUID
    var name: String
    var type: String
    var status: DonationDBStatus
    var help_needed: Bool
    var shipping_weight: String?
    var pickup_address: String?
    var pickup_date: Date?
    var notes: String?
    var amount: Double?
    var created_at: Date?
    var location_name: String?
    var admin_note: String?

    var image_urls: [String]?
    
    var donorName: String? = nil

    var title: String { name }
    var location: String { location_name ?? "" }

    var formattedDate: String {
        guard let created_at else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd' 'MMM' 'yyyy"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: created_at)
    }

    var statusDisplay: DonationStatusDisplay {
        switch status {
        case .in_process:
            return help_needed ? .solicitudAyuda : .enProceso
        case .accepted:
            return help_needed ? .ayudaAprobada : .completada
        case .rejected:
            return .ayudaRechazada
        case .returned:
            return .enProceso
        case .received:
            return .recibida
        }
    }

    enum CodingKeys: String, CodingKey {
            case id, user_id, name, type, status, help_needed, shipping_weight, notes,
                 pickup_address, pickup_date, amount, created_at, location_name, admin_note,
                 image_urls
        }
}
