import SwiftUI

struct DetallesDonacionView: View {
    let donation: Donation
    @Environment(\.dismiss) var dismiss
    
    // Estado para mostrar la imagen en pantalla completa
    @State private var selectedImage: String?
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - 1. Cabecera Reorganizada (Igual que Admin)
                    VStack(alignment: .leading, spacing: 8) {
                    
                        // Fila 1: Nombre (Solo y Grande)
                        Text(donation.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                                    
                        // Fila 2: Badge de Estado + Fecha (Separados por Spacer)
                        HStack(alignment: .center, spacing: 12) {
                        // Badge (Izquierda)
                        Text(donation.statusDisplay.rawValue)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(donation.statusDisplay.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(donation.statusDisplay.color.opacity(0.1))
                        .clipShape(Capsule())
                                            
                        Spacer() // ✅ Empuja la fecha a la derecha
                                                
                                                // Fecha (Derecha)
                                                HStack(spacing: 4) {
                                                    Image(systemName: "calendar")
                                                    if let created = donation.created_at {
                                                        Text(created, format: .dateTime.day().month().year())
                                                    } else {
                                                        Text("—")
                                                    }
                                                }
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            }
                                            
                                            // Fila 3: ID
                        Text("ID: #\(donation.id)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .padding(.top, 2)
                                        
                        // Fila 4: Información del Donante (Debajo del ID)
                        if let donor = donation.donorName {
                        Label(donor, systemImage: "person.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Divider().padding(.horizontal, 20)
                    
                    // MARK: - 2. Evidencia Fotográfica
                    if let images = donation.image_urls, !images.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Evidencia fotográfica", systemImage: "camera.fill")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.horizontal, 20)
                            
                            TabView {
                                ForEach(images, id: \.self) { imageUrl in
                                    AsyncImage(url: URL(string: imageUrl)) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        case .empty:
                                            Rectangle().fill(Color.gray.opacity(0.2))
                                                .overlay(ProgressView())
                                        case .failure:
                                            Rectangle().fill(Color.gray.opacity(0.1))
                                                .overlay(
                                                    Image(systemName: "photo.badge.exclamationmark")
                                                        .foregroundStyle(.secondary)
                                                )
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .onTapGesture {
                                        selectedImage = imageUrl
                                    }
                                }
                            }
                            .frame(height: 250)
                            .tabViewStyle(.page)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal, 20)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        }
                    }
                    
                    // MARK: - 3. Tarjeta de Detalles
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Detalles de la donación")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            // Fila: Tipo
                            DetailRow(icon: "tag.fill", title: "Tipo", value: donation.type.capitalized)
                            
                            Divider().padding(.leading, 60)
                            
                            // Fila: Método de entrega
                            DetailRow(
                                icon: "shippingbox.fill",
                                title: "Método de entrega",
                                value: donation.help_needed ? "Recolección solicitada" : "Entrega personal"
                            )
                            
                            // Fila: Peso (si aplica)
                            if let shipping = donation.shipping_weight, !shipping.isEmpty, donation.help_needed {
                                Divider().padding(.leading, 60)
                                DetailRow(icon: "scalemass.fill", title: "Peso/Volumen", value: shipping)
                            }
                            
                            // Fila: Dirección (si aplica)
                            if let address = donation.pickup_address, !address.isEmpty {
                                Divider().padding(.leading, 60)
                                DetailRow(icon: "mappin.and.ellipse", title: "Dirección", value: address)
                            }
                            
                            // Fila: Fecha Recolección (si ya fue agendada por admin)
                            if let pickupDate = donation.pickup_date {
                                Divider().padding(.leading, 60)
                                DetailRow(
                                    icon: "calendar.badge.clock",
                                    title: "Fecha Recolección",
                                    value: DateFormatter.localizedString(from: pickupDate, dateStyle: .medium, timeStyle: .short)
                                )
                            }
                            
                            // Fila: Ubicación de entrega (si no pidió ayuda)
                            if let locName = donation.location_name, !donation.help_needed {
                                Divider().padding(.leading, 60)
                                DetailRow(icon: "building.2.fill", title: "Entregar en", value: locName)
                            }
                            
                            // Fila: Notas del usuario
                            if let notes = donation.notes, !notes.isEmpty {
                                Divider().padding(.leading, 60)
                                DetailRow(icon: "note.text", title: "Mis notas", value: notes)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(20)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                    }
                    
                    // MARK: - 4. Tarjeta de Nota de Administrador (SEPARADA)
                    if let adminNote = donation.admin_note, !adminNote.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Nota de Administrador")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 0) {
                                DetailRow(
                                    icon: "bubble.left.and.exclamationmark.bubble.right.fill",
                                    title: "Mensaje de Cáritas",
                                    value: adminNote
                                )
                            }
                            .background(Color.white)
                            .cornerRadius(20)
                            .padding(.horizontal, 20)
                            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical, 20)
            }
            .navigationTitle("Detalles")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(item: $selectedImage) { imageUrl in
                FullScreenImageView(imageUrl: imageUrl)
            }
        }
    }
}

// MARK: - Vistas Auxiliares (Reutilizables)

private struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icono con círculo de fondo gris
            ZStack {
                Circle()
                    .fill(Color(UIColor.systemGray6))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundStyle(.black.opacity(0.7))
                    .font(.system(size: 16))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(16)
    }
}

private struct FullScreenImageView: View {
    let imageUrl: String
    @Environment(\.dismiss) var dismiss
    
    @State private var currentScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(finalScale * currentScale)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { newScale in currentScale = newScale }
                                    .onEnded { scale in
                                        finalScale *= scale
                                        currentScale = 1.0
                                        if finalScale < 1.0 { finalScale = 1.0 }
                                        if finalScale > 5.0 { finalScale = 5.0 }
                                    }
                            )
                            .onTapGesture(count: 2) {
                                withAnimation { finalScale = 1.0 }
                            }
                    case .empty:
                        ProgressView().tint(.white)
                    case .failure:
                        Image(systemName: "exclamationmark.triangle").foregroundColor(.white)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}

// ✅ Extension vital para que no crashee el zoom
extension String: Identifiable {
    public var id: String { self }
}

#Preview {
    DetallesDonacionView(donation: Donation.sampleDonations[0])
}
