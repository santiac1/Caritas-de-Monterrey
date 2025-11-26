import SwiftUI

// Asegúrate de que tu modelo Donation y Enum DonationStatusDisplay estén en tu proyecto.
// Aquí solo modifico la VISTA visual (Frontend).

struct DetallesDonacionView: View {
    let donation: Donation
    @Environment(\.dismiss) var dismiss
    
    // Estado para mostrar la imagen en pantalla completa
    @State private var selectedImage: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - 1. Cabecera (Badge y Fecha)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            // Badge de estado estilo "Pastilla"
                            Text(donation.statusDisplay.rawValue)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.green) // Ajusta color según lógica si quieres
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.1))
                                .clipShape(Capsule())
                            
                            Spacer()
                            
                            // Fecha con icono
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                Text(donation.formattedDate)
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                        
                        // Título y ID
                        VStack(alignment: .leading, spacing: 4) {
                            Text(donation.name)
                                .font(.system(size: 28, weight: .bold)) // Título grande y negrita
                                .foregroundStyle(.primary)
                            
                            Text("ID: #\(donation.id)")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Divider()
                        .padding(.horizontal, 20)
                    
                        // MARK: - 2. Evidencia Fotográfica (Carrusel)
                        if let images = donation.image_urls, !images.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Evidencia fotográfica", systemImage: "camera")
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
                                        // Solo cortamos esquinas si quieres que cada foto sea redondeada
                                        // o bien, puedes redondear el contenedor TabView.
                                    }
                                }
                                .frame(height: 250) // Altura fija
                                .tabViewStyle(.page) // <--- Paginación (puntitos)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal, 20)
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                            }
                        }
                    
                    // MARK: - 3. Detalles de la donación (Tarjeta Blanca)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Detalles de la donación")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
                        
                        // Contenedor Blanco (Card)
                        VStack(spacing: 0) {
                            
                            // Fila: Tipo
                            DetailRow(icon: "tag.fill", title: "Tipo", value: donation.type.capitalized)
                            
                            Divider().padding(.leading, 60) // Separador indentado
                            
                            // Fila: Método de entrega
                            DetailRow(
                                icon: "person.fill",
                                title: "Método de entrega",
                                value: donation.help_needed ? "Recolección solicitada" : "Entrega personal"
                            )
                            
                            // Fila: Notas (si existen)
                            if let notes = donation.notes, !notes.isEmpty {
                                Divider().padding(.leading, 60)
                                DetailRow(icon: "doc.text.fill", title: "Notas adicionales", value: notes)
                            }
                            
                            // Fila: Ubicación (si existe)
                            if let location = donation.location_name, !location.isEmpty {
                                Divider().padding(.leading, 60)
                                DetailRow(icon: "mappin.and.ellipse", title: "Ubicación", value: location)
                            }
                        }
                        .background(Color.white) // Fondo blanco puro para la tarjeta
                        .cornerRadius(20)      // Bordes muy redondeados
                        .padding(.horizontal, 20)
                        // Sombra sutil para separar del fondo gris
                        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color(UIColor.systemGray6)) // Fondo gris claro general de la pantalla
            .navigationTitle("Detalles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Botón Cerrar (Tachita circular nativa estilo Apple)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                            .padding(8)
                    }
                }
            }
            .fullScreenCover(item: $selectedImage) { imageUrl in
                FullScreenImageView(imageUrl: imageUrl)
            }
        }
    }
}

// Wrapper para que String sea Identifiable y pueda usarse en fullScreenCover
extension String: Identifiable {
    public var id: String { self }
}

// MARK: - Vista de Pantalla Completa para Imagen
private struct FullScreenImageView: View {
    let imageUrl: String
    @Environment(\.dismiss) var dismiss
    
    // Estado para el zoom
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
                                    .onChanged { newScale in
                                        currentScale = newScale
                                    }
                                    .onEnded { scale in
                                        finalScale *= scale
                                        currentScale = 1.0
                                        
                                        // Limitar el zoom mínimo y máximo para UX
                                        if finalScale < 1.0 { finalScale = 1.0 }
                                        if finalScale > 5.0 { finalScale = 5.0 }
                                    }
                            )
                            // Doble tap para resetear zoom
                            .onTapGesture(count: 2) {
                                withAnimation {
                                    finalScale = 1.0
                                }
                            }
                    case .empty:
                        ProgressView()
                            .tint(.white)
                    case .failure:
                        Image(systemName: "photo.badge.exclamationmark")
                            .foregroundColor(.gray)
                            .font(.largeTitle)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                            .padding(8)
                    }
                }
            }
        }
    }
}

// MARK: - Componente de Fila (Row) idéntico a la imagen

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
                    .fontWeight(.semibold) // Texto del valor en negrita suave
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true) // Permite multilínea
            }
            
            Spacer()
        }
        .padding(16)
    }
}

// Previsualización
#Preview {
    DetallesDonacionView(donation: Donation.sampleDonations[0])
}
