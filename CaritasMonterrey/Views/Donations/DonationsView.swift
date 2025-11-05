//
//  DonationsView.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import SwiftUI

struct DonationsView: View {
    enum Filter: String, CaseIterable { case todas="Todas", aceptadas="Aceptadas", rechazadas="Rechazadas", proceso="En proceso", atencion="Atención" }
    @State private var filtro: Filter = .todas

    var body: some View {
        VStack {
            Picker("Filtro", selection: $filtro) {
                ForEach(Filter.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            List { Text("Tu donación #1") }
        }
        .navigationTitle("Donaciones")
    }
}
