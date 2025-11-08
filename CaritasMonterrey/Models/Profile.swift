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
        case firstName = "first_name"
        case lastName = "last_name"
        case username = "username"
        case phone = "phone"
        case birthdate = "birthdate"
        case companyName = "company_name"
        case rfc = "rfc"
        case address = "address"
    }
}
