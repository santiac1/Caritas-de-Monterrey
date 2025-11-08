import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var statsViewModel = ProfileStatsViewModel()
    @State private var selectedSection: ProfileSection = .badges

    private enum ProfileSection: String, CaseIterable, Identifiable {
        case badges = "Mis insignias"
        case stats = "Mis estadísticas"

        var id: String { rawValue }
    }

    private let placeholderBadges: [ProfileBadge] = [
        ProfileBadge(icon: "🏆", title: "Donante pionero"),
        ProfileBadge(icon: "🏅", title: "Amigo fiel"),
        ProfileBadge(icon: "🎖️", title: "Héroe solidario"),
        ProfileBadge(icon: "💎", title: "Apoyo destacado")
    ]

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
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape.fill")
                        .imageScale(.large)
                }
                .accessibilityLabel("Ajustes")
            }
        }
        .task {
            await statsViewModel.loadStats(for: appState.session?.user.id)
        }
        .onChange(of: appState.session?.user.id) { newValue in
            Task {
                await statsViewModel.loadStats(for: newValue)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
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
        if placeholderBadges.isEmpty {
            Text("Aún no tienes insignias.")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(placeholderBadges) { badge in
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

private struct ProfileBadge: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
}

private struct BadgeView: View {
    let badge: ProfileBadge

    var body: some View {
        VStack(spacing: 8) {
            Text(badge.icon)
                .font(.system(size: 44))
            Text(badge.title)
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(.systemGray4))
        )
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AppState())
    }
}
