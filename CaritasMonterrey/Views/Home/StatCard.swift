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
        let accent = scheme == .dark ? Color(.white) : Color.primaryCyan

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
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(accent)
                .frame(width: 36, height: 36)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: HomeCardStyle.height, alignment: .leading)
        .background(Color(.white))
        .clipShape(RoundedRectangle(cornerRadius: HomeCardStyle.cornerRadius, style: .continuous))
        .contentShape(Rectangle())
    }
}


#Preview {
    StatCard(title: "Resumen", value: "0 donaciones", systemIcon: "chart.bar.fill")
        .padding()
}
