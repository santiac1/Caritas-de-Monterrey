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
        let accent = scheme == .dark ? Color("PrimaryCyan") : Color.primaryCyan
        // Fondo adaptativo: blanco en light, gris oscuro (secondarySystemBackground) en dark
        let backgroundColor = scheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white

        HStack(alignment: .center, spacing: 12) {
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

            Image(systemName: systemIcon)
                .font(.system(size: 32, weight: .semibold)) // Reduje un poco el tamaño para balancear
                .foregroundStyle(accent)
                .frame(width: 36, height: 36)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: HomeCardStyle.height, alignment: .leading)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: HomeCardStyle.cornerRadius, style: .continuous))
        // Sombra sutil solo en light mode, en dark mode el contraste es suficiente o se usa un borde sutil
        .shadow(color: Color.black.opacity(scheme == .dark ? 0 : 0.05), radius: 8, x: 0, y: 2)
        .contentShape(Rectangle())
    }
}


#Preview {
    ZStack {
        Color(.systemGroupedBackground)
        StatCard(title: "Resumen", value: "0 donaciones", systemIcon: "chart.bar.fill")
            .padding()
    }
}
