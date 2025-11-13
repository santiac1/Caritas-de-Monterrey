// Models/Donation.swift
import Foundation
import SwiftUI

/// Estados **tal cual** los acepta la BD (CHECK constraint)
enum DonationDBStatus: String, Codable, CaseIterable, Hashable {
    case in_process = "in_process"
    case accepted   = "accepted"
    case rejected   = "rejected"
    case returned   = "returned"
}

/// Estados de **presentación** para la UI en español
enum DonationStatusDisplay: String, CaseIterable {
    case enProceso = "En proceso"
    case completada = "Completada"
    case solicitudAyuda = "Solicitud de ayuda"
    case ayudaAprobada = "Ayuda aprobada"
    case ayudaRechazada = "Ayuda rechazada"

    var color: Color {
        switch self {
        case .enProceso:        return Color(red: 0.40, green: 0.75, blue: 0.75)
        case .completada:       return Color(red: 0.95, green: 0.50, blue: 0.30)
        case .solicitudAyuda:   return .orange
        case .ayudaAprobada:    return .green
        case .ayudaRechazada:   return .red
        }
    }

    var iconName: String {
        switch self {
        case .enProceso:        return "circle.dashed"
        case .completada:       return "checkmark.circle.fill"
        case .solicitudAyuda:   return "paperplane.fill"
        case .ayudaAprobada:    return "hand.thumbsup.fill"
        case .ayudaRechazada:   return "xmark.octagon.fill"
        }
    }
}

/// (Opcional) Tipos normalizados que mandarás a BD
enum DonationTypeDB: String, Codable, CaseIterable {
    case monetaria, ropa, alimentos, equipo, muebles, otros
}

struct Donation: Identifiable, Codable, Hashable {
    let id: Int
    let user_id: UUID
    var name: String
    var type: String             // queda String si ya tienes datos; si quieres: DonationTypeDB
    var status: DonationDBStatus // <- ahora es el enum alineado a la BD
    var help_needed: Bool
    var shipping_weight: String?
    var notes: String?
    var amount: Double?
    var created_at: Date?
    var location_name: String?
    var admin_note: String?

    var image_urls: [String]?
    
    // Solo para UI
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

    /// Mapea el estado de BD -> etiqueta de UI (en español)
    var statusDisplay: DonationStatusDisplay {
        switch status {
        case .in_process:
            return help_needed ? .solicitudAyuda : .enProceso
        case .accepted:
            return help_needed ? .ayudaAprobada : .completada
        case .rejected:
            return .ayudaRechazada
        case .returned:
            // puedes personalizarlo; por ahora lo mostramos como "En proceso"
            return .enProceso
        }
    }

    enum CodingKeys: String, CodingKey {
            case id, user_id, name, type, status, help_needed, shipping_weight, notes,
                 amount, created_at, location_name, admin_note,
                 image_urls
        }
}

// MARK: - Mocks alineados a la BD
extension Donation {
    static let sampleDonations: [Donation] = [
        Donation(
            id: 1,
            user_id: UUID(),
            name: "Ropa de invierno",
            type: "ropa",
            status: .in_process,
            help_needed: false,
            shipping_weight: nil,
            notes: nil,
            amount: nil,
            created_at: Date(),
            location_name: "Bazar Emilio Carranza",
            admin_note: nil,
            donorName: "Carolina"
        ),
        Donation(
            id: 2,
            user_id: UUID(),
            name: "Artículos personales",
            type: "alimentos",
            status: .in_process,
            help_needed: true,
            shipping_weight: "10kg",
            notes: nil,
            amount: nil,
            created_at: Date().addingTimeInterval(-200000),
            location_name: "Bazar Cáritas Centro",
            admin_note: nil,
            donorName: "Luis"
        )
    ]
}

