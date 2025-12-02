import SwiftUI
import Auth

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var statsViewModel = ProfileStatsViewModel()
    @StateObject private var viewModel = ProfileViewModel() // ViewModel para badges
    @State private var selectedSection: ProfileSection = .badges

    private enum ProfileSection: String, CaseIterable, Identifiable {
        case badges = "Mis insignias"
        case stats = "Mis estadísticas"

        var id: String { rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header

                Picker("Sección", selection: $selectedSection) {
                    ForEach(ProfileSection.allCases) { section in
                        Text(section.rawValue).tag(section)
                    }
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading, spacing: 16) {
                    switch selectedSection {
                    case .badges:
                        badgesContent
                    case .stats:
                        statsContent
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 32)
            .padding(.bottom, 24)
        }
        .navigationTitle("Perfil")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(value: AppRoute.settings) {
                    Image(systemName: "gearshape.fill")
                        .imageScale(.large)
                }
                .accessibilityLabel("Ajustes")
            }
        }
        .task {
            if let userId = appState.session?.user.id {
                await statsViewModel.loadStats(for: userId)
                await viewModel.loadBadges(for: userId)
            }
        }
        .refreshable {
            if let userId = appState.session?.user.id {
                await statsViewModel.loadStats(for: userId)
                await viewModel.loadBadges(for: userId)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(Color(.systemGray4))

            Text(appState.profile?.username ?? "Sin nombre público")
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)

            Text(appState.session?.user.email ?? "Correo no disponible")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var badgesContent: some View {
        if viewModel.isLoadingBadges {
            HStack {
                ProgressView()
                Text("Cargando insignias...")
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
        } else if viewModel.badges.isEmpty {
            Text("No hay insignias disponibles en el sistema.")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
        } else {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.badges) { badge in
                    BadgeView(badge: badge)
                }
            }
        }
    }

    @ViewBuilder
    private var statsContent: some View {
        if statsViewModel.isLoading {
            HStack {
                ProgressView()
                Text("Cargando estadísticas…")
            }
            .frame(maxWidth: .infinity, alignment: .center)
        } else if let error = statsViewModel.errorMessage {
            Text(error)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else if statsViewModel.stats.isEmpty {
            Text("Aún no hay estadísticas disponibles.")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(statsViewModel.stats) { stat in
                    StatCard(title: stat.title, value: stat.value, systemIcon: stat.systemIcon)
                }
            }
        }
    }
}

private struct BadgeView: View {
    let badge: Badge
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(spacing: 12) {
            // Icono
            ZStack {
                Circle()
                    .fill(badge.isEarned ? Color("PrimaryCyan").opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Text(badge.icon_name) // Asumimos que es un Emoji por ahora, si es SF Symbol usar Image
                    .font(.system(size: 40))
                    .grayscale(badge.isEarned ? 0 : 1)
                    .opacity(badge.isEarned ? 1 : 0.5)
            }
            
            VStack(spacing: 4) {
                Text(badge.name)
                    .font(.subheadline.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(badge.isEarned ? .primary : .secondary)
                
                Text(badge.description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(scheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : .white)
                .shadow(color: badge.isEarned ? Color.black.opacity(0.05) : .clear, radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(badge.isEarned ? Color("PrimaryCyan").opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
        )
        .opacity(badge.isEarned ? 1 : 0.7)
    }
}
