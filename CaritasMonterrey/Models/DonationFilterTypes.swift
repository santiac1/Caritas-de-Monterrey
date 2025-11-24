import Foundation

public enum DonationFilter: CaseIterable, Hashable {
    case all
    case inProcess
    case accepted
    case rejected
    case returned
    case received

    /// Valor que espera la columna `status` en la base de datos.
    public var dbValue: String? {
        switch self {
        case .all:
            return nil
        case .inProcess:
            return DonationDBStatus.in_process.rawValue
        case .accepted:
            return DonationDBStatus.accepted.rawValue
        case .rejected:
            return DonationDBStatus.rejected.rawValue
        case .returned:
            return DonationDBStatus.returned.rawValue
        case .received:
            return DonationDBStatus.received.rawValue
        }
    }

    /// Texto en español para mostrar en la UI.
    public var title: String {
        switch self {
        case .all:
            return "Todas"
        case .inProcess:
            return "En proceso"
        case .accepted:
            return "Aceptadas"
        case .rejected:
            return "Rechazadas"
        case .returned:
            return "Devueltas"
        case .received:
            return "Recibidas"
        }
    }
}

public enum SortOrder: CaseIterable, Hashable {
    case newest
    case oldest

    public var title: String {
        switch self {
        case .newest:
            return "Más recientes"
        case .oldest:
            return "Más antiguas"
        }
    }
}
