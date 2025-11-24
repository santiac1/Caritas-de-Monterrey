import SwiftUI
import Auth   // ← REQUIRED to access appState.session?.user.id

struct DonationsView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var viewModel: DonationsViewModel
    @Namespace private var tabsNS // <--- RE-AÑADIDO: Necesario para la animación

    var body: some View {
        // Usamos un ScrollView principal para que el título grande se colapse
        ScrollView {
            VStack(alignment: .leading, spacing: 0) { // <--- Reducido el spacing
                
                // CAMBIO: Volvemos a tu FilterBar, que es como el ejemplo de GitHub
                FilterBar(selection: $viewModel.selectedFilter, namespace: tabsNS)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                //
                // ¡TODA ESTA LÓGICA PERMANECE IDÉNTICA!
                //
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 40)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if viewModel.filteredDonations.isEmpty {
                        EmptyStateView(message: "No hay donaciones en esta categoría.")
                            .padding(.top, 80)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        // El LazyVStack va directo dentro del ScrollView principal
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredDonations) { donation in
                                DonationCard(donation: donation)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
                .frame(maxWidth: .infinity)
                
            }
            // No se necesita .padding(.top, 12) aquí
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Mis donaciones")
        .navigationBarTitleDisplayMode(.large) // <--- Se mantiene el título grande
        .task {
            // Lógica intacta
            if let id = appState.session?.user.id {
                await viewModel.load(for: id)
            }
        }
        .refreshable {
            // Lógica intacta
            if let id = appState.session?.user.id {
                await viewModel.refresh(for: id)
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in }
        )) {
            Button("Aceptar", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

// MARK: - Filter Bar (píldoras deslizables)
// ¡Esta es tu struct original, pero MÁS LIMPIA!
private struct FilterBar: View {
    @Binding var selection: DonationFilter
    var namespace: Namespace.ID

    private let items = DonationFilter.allCases

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            selection = item
                        }
                    } label: {
                        Text(item.title)
                            .font(.subheadline).fontWeight(.semibold)
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
            .padding(.horizontal, 16) // <-- Padding para el HStack
            
        }
    }
}


// MARK: - Card (badge según enum de BD)
private struct DonationCard: View {
    let donation: Donation
    
    // ... (Tu código de DonationCard va aquí, sin cambios)
    private var badge: (text: String, color: Color, icon: String) {
        switch donation.status {
        case .in_process: return ("En proceso", Color(red: 0.40, green: 0.75, blue: 0.75), "circle.dashed")
        case .accepted:   return ("Aceptada",   .green,  "checkmark.seal.fill")
        case .rejected:   return ("Rechazada",  .red,    "xmark.octagon.fill")
        case .returned:   return ("Devuelta",   .orange, "arrow.uturn.backward.circle.fill")
        case .received:   return ("Recibida", .purple, "shippingbox.fill")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Image(systemName: "shippingbox.fill")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text(donation.title)
                    .font(.headline).fontWeight(.bold)
                    .lineLimit(1)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: badge.icon)
                    Text(badge.text)
                }
                .font(.caption).fontWeight(.semibold)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(badge.color.opacity(0.18), in: Capsule())
                .foregroundStyle(badge.color)
            }
            
            InfoRow(iconName: "calendar", text: donation.formattedDate.isEmpty ? "—" : donation.formattedDate)
            
            if let loc = donation.location_name, !loc.isEmpty {
                InfoRow(iconName: "mappin.circle.fill", text: loc)
            }
            
            HStack(spacing: 8) {
                if let w = donation.shipping_weight, !w.isEmpty {
                    Pill(icon: "scalemass", text: w)
                }
                Pill(icon: "square.stack.3d.up.fill", text: donation.type.capitalized)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }
}

// MARK: - Vistas Auxiliares (Sin Cambios)

private struct InfoRow: View {
    let iconName: String
    let text: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}

private struct Pill: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption).bold()
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .foregroundStyle(.primary)
        .background(Capsule().fill(Color.primary.opacity(0.08)))
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
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DonationsView()
            .environmentObject(AppState())
            .environmentObject(DonationsViewModel())
    }
}
