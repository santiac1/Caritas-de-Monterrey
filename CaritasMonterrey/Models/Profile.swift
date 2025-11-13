import Foundation

struct Profile: Identifiable, Codable {
    let id: UUID
    var role: String
    var firstName: String?
    var lastName: String?
    var username: String?
    var phone: String?
    var birthdate: Date?
    var companyName: String?
    var rfc: String?
    var address: String?

    enum CodingKeys: String, CodingKey {
        case id
        case role
        case firstName   = "first_name"
        case lastName    = "last_name"
        case username
        case phone
        case birthdate
        case companyName = "company_name"
        case rfc
        case address
    }

    // MARK: - Decode ("2007-11-06" ó ISO8601) -> Date?
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        id          = try c.decode(UUID.self, forKey: .id)
        role        = try c.decode(String.self, forKey: .role)
        firstName   = try? c.decode(String.self, forKey: .firstName)
        lastName    = try? c.decode(String.self, forKey: .lastName)
        username    = try? c.decode(String.self, forKey: .username)
        phone       = try? c.decode(String.self, forKey: .phone)
        companyName = try? c.decode(String.self, forKey: .companyName)
        rfc         = try? c.decode(String.self, forKey: .rfc)
        address     = try? c.decode(String.self, forKey: .address)

        // birthdate puede venir como String "yyyy-MM-dd" o null
        if let s = try? c.decode(String.self, forKey: .birthdate) {
            // Intenta yyyy-MM-dd y como fallback ISO8601 (por si cambia en el futuro)
            birthdate = DateFormatter.yyyyMMdd.date(from: s) ?? ISO8601DateFormatter().date(from: s)
        } else if let d = try? c.decode(Date.self, forKey: .birthdate) {
            // Por si algún día viene como Date real
            birthdate = d
        } else {
            birthdate = nil
        }
    }

    // MARK: - Encode Date? -> "yyyy-MM-dd" (para columna DATE)
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(role, forKey: .role)
        try c.encodeIfPresent(firstName, forKey: .firstName)
        try c.encodeIfPresent(lastName, forKey: .lastName)
        try c.encodeIfPresent(username, forKey: .username)
        try c.encodeIfPresent(phone, forKey: .phone)
        try c.encodeIfPresent(companyName, forKey: .companyName)
        try c.encodeIfPresent(rfc, forKey: .rfc)
        try c.encodeIfPresent(address, forKey: .address)

        if let bd = birthdate {
            try c.encode(DateFormatter.yyyyMMdd.string(from: bd), forKey: .birthdate)
        } else {
            try c.encodeNil(forKey: .birthdate)
        }
    }
}

// MARK: - DateFormatter helper
extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .iso8601)
        f.locale   = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}

