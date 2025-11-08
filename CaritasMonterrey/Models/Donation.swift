import Foundation
import SwiftUI

enum DonationStatusDisplay: String, CaseIterable {
    case enProceso = "En proceso"
    case completada = "Completada"
    case solicitudAyuda = "Solicitud de ayuda"
    case ayudaAprobada = "Ayuda aprobada"
    case ayudaRechazada = "Ayuda rechazada"

    var color: Color {
        switch self {
        case .enProceso: return Color(red: 0.4, green: 0.75, blue: 0.75)
        case .completada: return Color(red: 0.95, green: 0.5, blue: 0.3)
        case .solicitudAyuda: return .orange
        case .ayudaAprobada: return .green
        case .ayudaRechazada: return .red
        }
    }

    var iconName: String {
        switch self {
        case .enProceso: return "circle.dashed"
        case .completada: return "checkmark.circle.fill"
        case .solicitudAyuda: return "paperplane.fill"
        case .ayudaAprobada: return "hand.thumbsup.fill"
        case .ayudaRechazada: return "xmark.octagon.fill"
        }
    }
}

struct Donation: Identifiable, Codable, Hashable {
    let id: UUID
    let user_id: UUID
    var name: String
    var type: String
    var status: String
    var help_needed: Bool
    var shipping_weight: String?
    var notes: String?
    var amount: Double?
    var created_at: Date?
    var location_name: String?

    var donorName: String? = nil

    var title: String { name }
    var location: String { location_name ?? "" }

    var formattedDate: String {
        guard let created_at else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd'/' MMMM '/' yyyy"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: created_at)
    }

    var statusDisplay: DonationStatusDisplay {
        switch status {
        case "en_proceso": return .enProceso
        case "completada": return .completada
        case "solicitud_ayuda": return .solicitudAyuda
        case "ayuda_aprobada": return .ayudaAprobada
        case "ayuda_rechazada": return .ayudaRechazada
        default: return .enProceso
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case user_id
        case name
        case type
        case status
        case help_needed
        case shipping_weight
        case notes
        case amount
        case created_at
        case location_name
    }

    static let sampleDonations: [Donation] = [
        Donation(
            id: UUID(),
            user_id: UUID(),
            name: "Ropa de invierno",
            type: "Ropa",
            status: "en_proceso",
            help_needed: false,
            shipping_weight: nil,
            notes: "",
            amount: nil,
            created_at: Date(),
            location_name: "Bazar Emilio Carranza",
            donorName: "Carolina"
        ),
        Donation(
            id: UUID(),
            user_id: UUID(),
            name: "Artículos personales",
            type: "Útiles escolares",
            status: "solicitud_ayuda",
            help_needed: true,
            shipping_weight: "10kg",
            notes: "",
            amount: nil,
            created_at: Date().addingTimeInterval(-200000),
            location_name: "Bazar Cáritas Centro",
            donorName: "Luis"
        )
    ]
}
