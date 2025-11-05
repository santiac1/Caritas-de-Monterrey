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
        client = SupabaseClient(supabaseURL: URL(string: "https://kfumhqqowleugtlxjfff.supabase.co")!,
                                supabaseKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtmdW1ocXFvd2xldWd0bHhqZmZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIyNzc0NDAsImV4cCI6MjA3Nzg1MzQ0MH0.MuATkhSo2Wk31wvzWWKpAoYd2yGc4YRVwhbiKYsWR_4")
    }
}

