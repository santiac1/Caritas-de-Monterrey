//
//
//
//  DonationsView.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import SwiftUI

struct DonationsFilterBar: View {
    @Binding var selection: DonationFilter
    var namespace: Namespace.ID

    private let items = DonationFilter.allCases

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(items) { item in
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            selection = item
                        }
                    } label: {
                        Text(item.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .foregroundStyle(selection == item ? .white : .primary)
                            .background(
                                ZStack {
                                    if selection == item {
                                        Capsule()
                                            .fill(Color("AccentColor"))
                                            .matchedGeometryEffect(id: "tab-pill", in: namespace)
                                    } else {
                                        Capsule()
                                            .fill(Color(.secondarySystemBackground))
                                            .opacity(0.8)
                                    }
                                }
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
