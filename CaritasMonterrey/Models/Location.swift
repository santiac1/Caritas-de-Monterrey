//
//  Location.swift
//  CaritasMonterrey
//
//  Created by José de Jesùs Jiménez Martínez on 04/11/25.
//

import Foundation
import Combine

struct Location: Codable, Identifiable {
    var id: Int
    var name: String
    var latitude: Double
    var longitude: Double
    var address: String
    var food: Bool
    var clothes: Bool
    var equipment: Bool
    var furniture: Bool
    var appliances: Bool
    var cleaning: Bool
    var medicine: Bool
    var isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case latitude
        case longitude
        case address
        case food
        case clothes
        case equipment
        case furniture
        case appliances
        case cleaning
        case medicine
        case isActive = "is_active"
    }
}
