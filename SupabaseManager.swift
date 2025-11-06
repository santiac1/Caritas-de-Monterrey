//
//  SupabaseManager.swift
//  CaritasMonterrey
//
//  Created by José de Jesùs Jiménez Martínez on 04/11/25.
//

import Foundation
import Supabase
import Combine

final class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: AppEnvironment.supabaseURL,
            supabaseKey: AppEnvironment.supabaseAnonKey
        )
    }
}

