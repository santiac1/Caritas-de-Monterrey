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
    var latitude : Double
    var longitude : Double
    var address : String
}
