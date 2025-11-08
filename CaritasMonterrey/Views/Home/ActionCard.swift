//
//
//  HomeView.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import SwiftUI

struct ActionCard: View {
    let title: String
    let assetName: String?
    let systemFallback: String
    let onTap: () -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let accent = scheme == .dark ? Color(.white) : Color.primaryCyan

        Button(action: onTap) {
            VStack(spacing: 10) {
                actionImage
                    .resizable()
                    .scaledToFit()
                    .frame(height: HomeCardStyle.iconSize)
                    .foregroundStyle(accent)

                Text(title)
                    .font(.subheadline).bold()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(accent)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            // Un único padding para todo el contenido
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, minHeight: HomeCardStyle.height)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: HomeCardStyle.cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var actionImage: Image {
        if let name = assetName, let ui = UIImage(named: name) {
            return Image(uiImage: ui)
        } else {
            return Image(systemName: systemFallback)
        }
    }
}


#Preview {
    HStack {
        ActionCard(title: "Bazares cercanos", assetName: nil, systemFallback: "mappin.and.ellipse", onTap: {})
        ActionCard(title: "Tus donaciones", assetName: nil, systemFallback: "gift.fill", onTap: {})
    }
    .padding()
}
