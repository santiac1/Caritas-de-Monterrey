import SwiftUI

struct CampaignDetailView: View {
    let campaign: Campaign
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                // 1. HEADER IMAGEN (Inmersivo)
                GeometryReader { proxy in
                    let scrollY = proxy.frame(in: .global).minY
                    // Efecto Parallax y Stretch
                    headerImage
                        .frame(width: proxy.size.width, height: max(350 + scrollY, 350))
                        .offset(y: -scrollY)
                        .overlay(
                            LinearGradient(
                                colors: [Color.black.opacity(0.6), .clear],
                                startPoint: .bottom,
                                endPoint: .center
                            )
                        )
                }
                .frame(height: 350)
                
                // 2. CONTENIDO (Card superpuesta)
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Título y Badge
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            Text(campaign.title)
                                .font(.system(size: 28, weight: .heavy, design: .rounded))
                                .foregroundStyle(Color.primary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                            
                            statusBadge
                        }
                        
                        // Tarjetas de Fechas
                        HStack(spacing: 12) {
                            DetailInfoCard(
                                icon: "calendar",
                                title: "Inicio",
                                value: campaign.start_date.formatted(date: .numeric, time: .omitted),
                                color: Color("SecondaryBlue")
                            )
                            
                            DetailInfoCard(
                                icon: "flag.checkered",
                                title: "Fin",
                                value: campaign.end_date.formatted(date: .numeric, time: .omitted),
                                color: Color("PrimaryCyan")
                            )
                        }
                    }
                    
                    Divider()
                    
                    // Descripción
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Acerca de esta causa", systemImage: "info.circle.fill")
                            .font(.title3.bold())
                            .foregroundStyle(Color("PrimaryDark"))
                        
                        Text(campaign.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineSpacing(6)
                    }
                    
                    // Botón de Acción (Solo si activa)
                    if campaign.isCurrentlyActive {
                        Button {
                            // Acción de donar específica
                        } label: {
                            HStack {
                                Image(systemName: "heart.fill")
                                Text("Donar a esta campaña")
                            }
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color("PrimaryCyan"))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color("PrimaryCyan").opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.top, 10)
                    }
                    
                    // Footer Metadata
                    if let created = campaign.created_at {
                        HStack {
                            Spacer()
                            Text("Publicado el \(created.formatted(date: .long, time: .omitted))")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                            Spacer()
                        }
                        .padding(.top)
                    }
                }
                .padding(24)
                .background(Color(.systemBackground))
                // Efecto de hoja redondeada subiendo sobre la imagen
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .offset(y: -40)
                .padding(.bottom, -40)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                
                        
                }
            }
        }
    }
    
    // --- Componentes Privados ---
    
    private var headerImage: some View {
        Group {
            if let imageUrl = campaign.image_url, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .empty:
                        ZStack {
                            Color.gray.opacity(0.2)
                            ProgressView()
                        }
                    case .failure:
                        fallbackImage
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                fallbackImage
            }
        }
    }
    
    private var fallbackImage: some View {
        ZStack {
            Color("SecondaryBlue")
            Image(systemName: "megaphone.fill")
                .font(.system(size: 80))
                .foregroundStyle(.white.opacity(0.3))
        }
    }
    
    private var statusBadge: some View {
        Text(campaign.isCurrentlyActive ? "Activa" : "Finalizada")
            .font(.caption.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(campaign.isCurrentlyActive ? Color.green : Color.gray)
            .clipShape(Capsule())
            .shadow(radius: 2)
    }
}

// Componente auxiliar para fechas
struct DetailInfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.caption.bold())
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                Text(value)
                    .font(.callout.bold())
                    .foregroundStyle(.primary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    CampaignDetailView(campaign: Campaign(
        id: 1,
        created_at: Date(),
        title: "Colecta de Ropa Invernal 2025",
        description: "Ayúdanos a recolectar abrigos, cobijas y ropa térmica para las comunidades de la sierra de Arteaga. Tu apoyo es fundamental para que muchas familias pasen un invierno cálido. Aceptamos ropa de todas las tallas en buen estado.",
        image_url: nil,
        start_date: Date(),
        end_date: Date().addingTimeInterval(86400 * 30),
        is_active: true
    ))
}
