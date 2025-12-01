import SwiftUI
import PhotosUI

struct CampaignView: View {
    @StateObject private var viewModel = CampaignViewModel()
    @State private var isPresentingForm = false
    @State private var editingCampaign: Campaign?
    @State private var deletingCampaign: Campaign?
    @State private var isDeleteAlertPresented = false
    
    var body: some View {
        List {
            ForEach(viewModel.campaigns) { campaign in
                CampaignCard(
                    campaign: campaign,
                    onEdit: {
                        editingCampaign = campaign
                        isPresentingForm = true
                    },
                    onDelete: {
                        deletingCampaign = campaign
                        isDeleteAlertPresented = true
                    }
                )
                .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .contextMenu {
                    Button(role: .destructive) {
                        deletingCampaign = campaign
                        isDeleteAlertPresented = true
                    } label: {
                        Label("Eliminar campaña", systemImage: "trash")
                    }
                    Button {
                        editingCampaign = campaign
                        isPresentingForm = true
                    } label: {
                        Label("Editar campaña", systemImage: "pencil")
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        deletingCampaign = campaign
                        isDeleteAlertPresented = true
                    } label: {
                        Label("Eliminar", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button {
                        editingCampaign = campaign
                        isPresentingForm = true
                    } label: {
                        Label("Editar", systemImage: "pencil")
                    }
                    .tint(Color("AccentColor"))
                }
            }
            .listSectionSeparator(.hidden)
        }
        .scrollContentBackground(.hidden)
        .background(Color(.secondarySystemBackground))
        .listStyle(.plain)
        .navigationTitle("Gestión de campañas")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    editingCampaign = nil
                    isPresentingForm = true
                } label: {
                    Label("Nueva campaña", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("AccentColor"))
            }
        }
        .task { await viewModel.loadCampaigns() }
        .sheet(isPresented: $isPresentingForm, onDismiss: { Task { await viewModel.loadCampaigns() } }) {
            NavigationStack {
                CampaignForm(campaign: editingCampaign) { payload in
                    Task {
                        if let editingCampaign {
                            await viewModel.updateCampaign(editingCampaign.id, with: payload)
                        } else {
                            await viewModel.createCampaign(payload)
                        }
                    }
                }
                .toolbarTitleDisplayMode(.inline)
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
        .alert("Eliminar campaña", isPresented: $isDeleteAlertPresented, presenting: deletingCampaign) { campaign in
            Button("Cancelar", role: .cancel) {
                deletingCampaign = nil
            }
            Button("Eliminar", role: .destructive) {
                Task { await viewModel.deleteCampaign(campaign.id) }
            }
        } message: { _ in
            Text("Esta acción eliminará la campaña de forma permanente de la base de datos.")
        }
    }
}

// MARK: - Campaign Card

private struct CampaignCard: View {
    @Environment(\.colorScheme) private var scheme
    
    let campaign: Campaign
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Image
            if let imageUrl = campaign.image_url, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 160)
                            .clipped()
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 160)
                            .overlay(ProgressView())
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 160)
                            .overlay(
                                Image(systemName: "photo.badge.exclamationmark")
                                    .foregroundStyle(.secondary)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(campaign.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Group {
                            if campaign.isCurrentlyActive {
                                Image(systemName: "checkmark.circle.fill")
                                    .symbolRenderingMode(.monochrome)
                                    .foregroundStyle(scheme == .dark ? .white : Color.secondaryBlue)
                            } else {
                                Image(systemName: "xmark.circle.fill")
                                    .symbolRenderingMode(.monochrome)
                                    .foregroundStyle(Color(.systemGray3))
                            }
                        }
                        .font(.headline)
                    }
                    
                    Text(campaign.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    
                    Text(campaign.formattedDateRange)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                Menu {
                    Button { onEdit() } label: { Label("Editar campaña", systemImage: "pencil") }
                    Button(role: .destructive) { onDelete() } label: { Label("Eliminar campaña", systemImage: "trash") }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .foregroundStyle(Color("AccentColor"))
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(glassBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08))
        }
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
    }
    
    @ViewBuilder
    private var glassBackground: some View {
        if #available(iOS 18.0, *) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.thinMaterial)
        } else {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
        }
    }
}

private struct CampaignForm: View {
    var campaign: Campaign?
    var onSave: (CampaignPayload) -> Void
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CampaignViewModel()
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(7 * 24 * 60 * 60)
    @State private var isActive: Bool = true
    
    // Picker de fotos
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    @State private var selectedImageData: Data?
    @State private var isUploadingImage = false
    @State private var uploadedImageUrl: String?
    @State private var uploadError: String?
    @State private var showErrorAlert = false
    
    var body: some View {
        Form {
            Section("Detalles") {
                TextField("Título", text: $title)
                TextField("Descripción", text: $description, axis: .vertical)
                    .lineLimit(3...6)
            }
            
            Section("Imagen") {
                // Botón para el picker de fotos
                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    HStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.title3)
                        Text(selectedImage == nil ? "Seleccionar imagen" : "Cambiar imagen")
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(Color("AccentColor"))
                    .padding(.vertical, 8)
                }
                
                // Preview
                if let selectedImage {
                    selectedImage
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(alignment: .topTrailing) {
                            Button {
                                self.selectedImage = nil
                                self.selectedImageData = nil
                                self.selectedPhotoItem = nil
                                self.uploadedImageUrl = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white, Color.black.opacity(0.6))
                                    .padding(8)
                            }
                        }
                } else if let existingUrl = uploadedImageUrl ?? campaign?.image_url,
                          let url = URL(string: existingUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        case .empty:
                            ProgressView()
                        case .failure:
                            Label("Error al cargar imagen", systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.secondary)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Text("No se ha seleccionado ninguna imagen.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 80, alignment: .center)
                }
                
                if isUploadingImage {
                    HStack {
                        ProgressView()
                        Text("Subiendo imagen...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section("Fechas") {
                DatePicker("Fecha de inicio", selection: $startDate, displayedComponents: [.date])
                DatePicker("Fecha de fin", selection: $endDate, displayedComponents: [.date])
            }
            
            Section("Estado") {
                Toggle("Campaña activa", isOn: $isActive)
                    .tint(Color("AccentColor"))
            }
        }
        .navigationTitle(campaign == nil ? "Nueva campaña" : "Editar campaña")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar") {
                    Task {
                        await saveCampaign()
                    }
                }
                .disabled(title.isEmpty || description.isEmpty || isUploadingImage)
            }
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(uploadError ?? "Ocurrió un error desconocido")
        }
        .onChange(of: selectedPhotoItem) {
            Task { await loadImage() }
        }
        .onAppear {
            if let campaign {
                title = campaign.title
                description = campaign.description
                uploadedImageUrl = campaign.image_url
                startDate = campaign.start_date
                endDate = campaign.end_date
                isActive = campaign.is_active
            }
        }
    }
    
    private func loadImage() async {
        guard let item = selectedPhotoItem else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                
                let maxDimension: CGFloat = 1024
                var finalImage = uiImage
                
                if uiImage.size.width > maxDimension || uiImage.size.height > maxDimension {
                    let aspectRatio = uiImage.size.width / uiImage.size.height
                    var newSize: CGSize
                    
                    if uiImage.size.width > uiImage.size.height {
                        newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
                    } else {
                        newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
                    }
                    
                    let renderer = UIGraphicsImageRenderer(size: newSize)
                    finalImage = renderer.image { _ in
                        uiImage.draw(in: CGRect(origin: .zero, size: newSize))
                    }
                }
                
                selectedImage = Image(uiImage: finalImage)
                selectedImageData = finalImage.jpegData(compressionQuality: 0.6)
            }
        } catch {
            print("Error al cargar imagen: \(error.localizedDescription)")
        }
    }
    
    private func saveCampaign() async {
        var finalImageUrl: String? = uploadedImageUrl ?? campaign?.image_url
        
        // Subir imagen
        if let imageData = selectedImageData {
            isUploadingImage = true
            do {
                finalImageUrl = try await viewModel.uploadCampaignImage(data: imageData)
            } catch {
                print("Error al subir imagen: \(error.localizedDescription)")
                uploadError = "Error al subir imagen: \(error.localizedDescription)"
                showErrorAlert = true
                isUploadingImage = false
                return
            }
            isUploadingImage = false
        }
        
        let payload = CampaignPayload(
            title: title,
            description: description,
            image_url: finalImageUrl,
            start_date: startDate,
            end_date: endDate,
            is_active: isActive
        )
        
        onSave(payload)
        dismiss()
    }
}

