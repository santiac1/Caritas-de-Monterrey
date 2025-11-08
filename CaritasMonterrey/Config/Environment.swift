//
//  AppConstants.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import Foundation

enum AppEnvironment {
    enum Keys: String {
        case supabaseURL = "SUPABASE_URL"
        case supabaseAnonKey = "SUPABASE_ANON_KEY"
    }

    private static func value(for key: Keys) -> String {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let v = dict[key.rawValue] as? String, !v.isEmpty
        else {
            fatalError("Falta \(key.rawValue) en Secrets.plist")
        }
        return v
    }

    static let supabaseURL: URL = URL(string: value(for: .supabaseURL))!
    static let supabaseAnonKey: String = value(for: .supabaseAnonKey)
}
