//
//  DonationsView.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//
//  Modificado por Gemini con "matchedGeometryEffect" para slide-animation
//

import SwiftUI

struct DonationsView: View {
    
    /// Define las opciones del filtro "píldora"
    enum FilterOption: String, CaseIterable {
        case todas = "Todas"
        case enProceso = "En proceso"
        case completadas = "Completadas"
    }
    
    @State private var selectedFilter: FilterOption = .todas
    
    /// Namespace para la animación de "slide" de los botones
    @Namespace private var animationNamespace
    
    // -------------------------------------------------------------------------
    // MARK: - DATOS (Listos para Base de Datos)
    // -------------------------------------------------------------------------
    
    /// DATOS DE MUESTRA (Mock Data)
    /// Se inicializa desde la propiedad estática en Donation.swift
    @State private var allDonations: [Donation] = Donation.sampleDonations
    
    /// Lógica de filtrado limpia.
    private var filteredDonations: [Donation] {
        switch selectedFilter {
        case .todas:
            return allDonations
        case .enProceso:
            return allDonations.filter { $0.status == .enProceso }
        case .completadas:
            return allDonations.filter { $0.status == .completada }
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Cuerpo de la Vista
    // -------------------------------------------------------------------------
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // --- Filtros estilo "Píldora" (como en GitHub Inbox) ---
                FilterPillView(selection: $selectedFilter, namespace: animationNamespace) // Pasamos el namespace
                    .padding(.bottom, 12)
                
                // --- Lista de Donaciones ---
                ScrollView {
                    if filteredDonations.isEmpty {
                        // --- Estado Vacío (como en GitHub Inbox) ---
                        EmptyStateView(
                            message: "No hay donaciones en esta categoría."
                        )
                        .padding(.top, 100)
                    } else {
                        // --- Tarjetas de Donación ---
                        VStack(spacing: 12) {
                            ForEach(filteredDonations) { donation in
                                DonationCardView(donation: donation)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Mis donaciones")
            .background(Color(.systemGroupedBackground)) // Fondo gris claro
        }
    }
}


// -----------------------------------------------------------------------------
// MARK: - Componentes de UI Reutilizables
// -----------------------------------------------------------------------------

/// Vista para el filtro estilo "Píldora"
private struct FilterPillView: View {
    @Binding var selection: DonationsView.FilterOption
    var namespace: Namespace.ID // El namespace para la animación
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(DonationsView.FilterOption.allCases, id: \.self) { filter in
                Button(action: {
                    // Volvemos a poner la animación en el 'action'
                    // para que el cambio de 'selection' sea animado.
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selection = filter
                    }
                }) {
                    Text(filter.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .foregroundColor(selection == filter ? .white : .primary) // El texto cambia de color
                }
                .buttonStyle(.plain) // Importante: quita el estilo de botón por defecto
                .background {
                    // Aquí ocurre la magia.
                    if selection == filter {
                        // Dibuja la píldora de color seleccionada
                        Capsule()
                            .fill(Color("AccentColor"))
                            .matchedGeometryEffect(id: "selectionPill", in: namespace) // Le dice a SwiftUI que esta es la píldora que se mueve
                    }
                }
                // Anima el cambio de color del texto
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selection)
            }
        }
        .background {
            // Este es el "riel" o "track" de fondo
            Capsule()
                .glassEffect()
        }
        .padding(.horizontal)
    }
}


/// Vista para la tarjeta de donación (estilo minimalista)
private struct DonationCardView: View {
    let donation: Donation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // --- Fila Superior: Título y Estado ---
            HStack {
                Image(systemName: "shippingbox.fill")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(donation.title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                // "Píldora" de Estado (minimalista)
                HStack(spacing: 4) {
                    Image(systemName: donation.status.iconName)
                    Text(donation.status.rawValue)
                }
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(donation.status.color.opacity(0.15))
                .foregroundColor(donation.status.color)
                .clipShape(Capsule())
            }
            
            // --- Fila de Fecha ---
            InfoRow(
                iconName: "calendar",
                text: donation.formattedDate
            )
            
            // --- Fila de Ubicación ---
            InfoRow(
                iconName: "mappin.circle.fill",
                text: donation.location
            )
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground)) // Color de tarjeta blanco
        .cornerRadius(12)
    }
}


/// Fila de información reutilizable (Icono + Texto)
private struct InfoRow: View {
    let iconName: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 20) // Alinea los iconos
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}


/// Vista de "Estado Vacío" (como la de GitHub)
private struct EmptyStateView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 50))
                .foregroundColor(Color(red: 0.4, green: 0.75, blue: 0.75)) // Teal
            
            Text("¡Todo al día!")
                .font(.headline)
                .fontWeight(.bold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }
}


// -----------------------------------------------------------------------------
// MARK: - Vista Previa
// -----------------------------------------------------------------------------

#Preview {
    DonationsView()
}

