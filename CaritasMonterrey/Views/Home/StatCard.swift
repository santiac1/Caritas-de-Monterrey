//
//
//  HomeView.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let systemIcon: String
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        // color de acento: blanco en dark, primaryCyan en light
        let accent = scheme == .dark ? Color(.white) : Color.primaryCyan

        HStack(alignment: .center, spacing: 12) {
            // Texto a la izquierda (sin padding interno extra)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text(value)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }

            Spacer(minLength: 8)

            // Ícono a la derecha (sin padding extra para que el padding horizontal del card mande)
            Image(systemName: systemIcon)
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(accent)
                .frame(width: 36, height: 36) // tamaño fijo; no agrega padding
        }
        // El único padding horizontal del card (igual para texto e ícono)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: HomeCardStyle.height, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: HomeCardStyle.cornerRadius, style: .continuous))
        .contentShape(Rectangle())
    }
}


#Preview {
    StatCard(title: "Resumen", value: "0 donaciones", systemIcon: "chart.bar.fill")
        .padding()
}
