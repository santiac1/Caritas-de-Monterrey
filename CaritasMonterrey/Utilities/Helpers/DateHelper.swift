//
//  DateHelper.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import Foundation
import Combine

enum DateHelper {
    static func formatted(_ date: Date, format: String = "dd/MM/yyyy") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    static func parse(_ string: String, format: String = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = format
        return formatter.date(from: string)
    }
}
