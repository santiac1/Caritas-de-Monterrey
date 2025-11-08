//
//  HomeView.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import SwiftUI

struct BannerCard: View {
    let title: String
    let assetName: String?
    let systemFallback: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center) {
                Text(title)
                    .font(.title3).bold()
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                bannerImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .shadow(radius: 6)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(Color.secondaryBlue) // <-- tu color de assets
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var bannerImage: Image {
        if let name = assetName, let ui = UIImage(named: name) {
            return Image(uiImage: ui)
        } else {
            return Image(systemName: systemFallback)
        }
    }
}

#Preview {
    BannerCard(
        title: "¡Haz una donación ahora!",
        assetName: "home_heart",
        systemFallback: "heart.circle.fill",
        onTap: {}
    )
    .padding()
    .background(Color(.systemBackground))
}
