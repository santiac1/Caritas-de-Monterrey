//
//  DonationsView.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//
//  Modificado por Gemini con "matchedGeometryEffect" para slide-animation
//

// Views/Donations/DonationsView.swift
import SwiftUI

struct DonationsView: View {

    // Filtros
    enum FilterOption: String, CaseIterable {
        case todas = "Todas"
        case enProceso = "En proceso"
        case completadas = "Completadas"
    }

    @State private var selectedFilter: FilterOption = .todas
    @Namespace private var animationNamespace

    // Mock data (conéctalo a tu store después)
    @State private var allDonations: [Donation] = Donation.sampleDonations

    private var filteredDonations: [Donation] {
        switch selectedFilter {
        case .todas:        return allDonations
        case .enProceso:    return allDonations.filter { $0.status == .enProceso }
        case .completadas:  return allDonations.filter { $0.status == .completada }
        }
    }

    var body: some View {
        VStack(spacing: 0) {

            // Filtros estilo "píldora"
            FilterPillView(
                selection: $selectedFilter,
                namespace: animationNamespace
            )
            .padding(.bottom, 12)

            // Lista
            ScrollView {
                if filteredDonations.isEmpty {
                    EmptyStateView(message: "No hay donaciones en esta categoría.")
                        .padding(.top, 100)
                } else {
                    VStack(spacing: 12) {
                        ForEach(filteredDonations) { donation in
                            DonationCardView(donation: donation)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Mis donaciones")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subviews (mismo archivo)

private struct FilterPillView: View {
    @Binding var selection: DonationsView.FilterOption
    var namespace: Namespace.ID

    var body: some View {
        HStack(spacing: 8) {
            ForEach(DonationsView.FilterOption.allCases, id: \.self) { filter in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selection = filter
                    }
                } label: {
                    Text(filter.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .foregroundColor(selection == filter ? .white : .primary)
                }
                .buttonStyle(.plain)
                .background {
                    if selection == filter {
                        Capsule()
                            .fill(Color("AccentColor"))
                            .matchedGeometryEffect(id: "selectionPill", in: namespace)
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selection)
            }
        }
        .background {
            Capsule()
                .fill(Color(.secondarySystemBackground))
        }
        .padding(.horizontal)
    }
}

private struct DonationCardView: View {
    let donation: Donation

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Image(systemName: "shippingbox.fill")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text(donation.title)
                    .font(.headline).fontWeight(.bold)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: donation.status.iconName)
                    Text(donation.status.rawValue)
                }
                .font(.caption).fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(donation.status.color.opacity(0.15))
                .foregroundColor(donation.status.color)
                .clipShape(Capsule())
            }

            InfoRow(iconName: "calendar", text: donation.formattedDate)
            InfoRow(iconName: "mappin.circle.fill", text: donation.location)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

private struct InfoRow: View {
    let iconName: String
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

private struct EmptyStateView: View {
    let message: String
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 50))
                .foregroundColor(Color(red: 0.4, green: 0.75, blue: 0.75))
            Text("¡Todo al día!")
                .font(.headline).fontWeight(.bold)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }
}

// Preview
#Preview {
    NavigationStack {
        DonationsView()
    }
}
