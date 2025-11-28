import SwiftUI
import Supabase

struct AdminSolicitudDetailView: View {

    @StateObject private var viewModel: AdminSolicitudDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    let donation: Donation

    @State private var isSchedulingPickup = false
    @State private var pickupDate = Date()
    @State private var isProcessingAction = false
    @State private var actionError: String?
    
    // Estado para mostrar la imagen en pantalla completa (Zoom)
    @State private var selectedImage: String?
    
    init(donation: Donation) {
        self.donation = donation
        _viewModel = StateObject(wrappedValue: AdminSolicitudDetailViewModel(donation: donation))
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - 1. Cabecera Reorganizada
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
                                            image.resizable().scaledToFill()
                                        case .empty:
                                            Rectangle().fill(Color.gray.opacity(0.2)).overlay(ProgressView())
                                        case .failure:
                                            Rectangle().fill(Color.gray.opacity(0.1))
                                                .overlay(Image(systemName: "photo.badge.exclamationmark").foregroundStyle(.secondary))
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
                        Text("Detalles de la solicitud")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            DetailRow(icon: "tag.fill", title: "Tipo", value: donation.type.capitalized)
                            Divider().padding(.leading, 60)
                            DetailRow(
                                icon: "shippingbox.fill",
                                title: "Necesita ayuda",
                                value: donation.help_needed ? "Sí, recolección" : "No, entrega personal"
                            )
                            if let shipping = donation.shipping_weight, donation.help_needed {
                                Divider().padding(.leading, 60)
                                DetailRow(icon: "scalemass.fill", title: "Peso/Volumen", value: shipping)
                            }
                            if let pickupAddress = donation.pickup_address, !pickupAddress.isEmpty {
                                Divider().padding(.leading, 60)
                                DetailRow(icon: "mappin.and.ellipse", title: "Dirección", value: pickupAddress)
                            }
                            if let pickupDate = donation.pickup_date {
                                Divider().padding(.leading, 60)
                                DetailRow(
                                    icon: "calendar.badge.clock",
                                    title: "Fecha Recolección",
                                    value: DateFormatter.localizedString(from: pickupDate, dateStyle: .medium, timeStyle: .short)
                                )
                            }
                            if let notes = donation.notes, !notes.isEmpty {
                                Divider().padding(.leading, 60)
                                DetailRow(icon: "note.text", title: "Notas", value: notes)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(20)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                    }
                    
                    Spacer(minLength: 120)
                }
                .padding(.vertical, 20)
            }
            
            // MARK: - 5. Botones de Acción Flotantes (ESTILO ORIGINAL RESTAURADO)
            VStack {
                Spacer()
                
                // Lógica de botones según estado
                if donation.status == .accepted {
                    // CASO: YA ACEPTADA -> Botón único
                    HStack {
                        Button {
                            Task { await markDonationAsReceived() }
                        } label: {
                            HStack {
                                if isProcessingAction {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "checkmark.seal.fill")
                                    Text("Donación Recibida")
                                }
                            }
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        }
                        .buttonStyle(.glassProminent) // Estilo Glass original
                        .tint(.blue)
                        .disabled(isProcessingAction)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                } else if donation.status != .received && donation.status != .rejected {
                    // CASO: PENDIENTE / EN PROCESO -> Rechazar / Aprobar (ESTILO ORIGINAL)
                    HStack(spacing: 16) {
                        // Botón Rechazar
                        Button(role: .destructive) {
                            viewModel.prepareUpdate(action: .rejected)
                        } label: {
                            HStack {
                                Image(systemName: "xmark")
                                Text("Rechazar")
                            }
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.glass) // Estilo Glass original
                        .disabled(viewModel.isUpdating || isProcessingAction)
                        
                        // Botón Aprobar
                        Button {
                            if donation.help_needed {
                                isSchedulingPickup = true
                            } else {
                                viewModel.prepareUpdate(action: .accepted)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "checkmark")
                                Text("Aprobar")
                            }
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.glassProminent) // Estilo Glass original
                        .tint(.secondaryBlue)
                        .disabled(viewModel.isUpdating || isProcessingAction)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("Solicitud")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.prepareUpdate(action: .in_process)
                } label: {
                    Label("Sugerir", systemImage: "bubble.left.and.exclamationmark.bubble.right.fill")
                }
                .tint(.orange)
                .disabled(viewModel.isUpdating || isProcessingAction)
            }
        }
        .sheet(isPresented: $viewModel.isShowingNoteSheet) {
            AdminNoteView(viewModel: viewModel)
        }
        .fullScreenCover(item: $selectedImage) { imageUrl in
            FullScreenImageView(imageUrl: imageUrl)
        }
        .sheet(isPresented: $isSchedulingPickup) {
            NavigationStack {
                Form {
                    Section {
                        DatePicker("Programar fecha de recolección", selection: $pickupDate)
                    }
                }
                .navigationTitle("Agendar Recolección")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") { isSchedulingPickup = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Guardar") {
                            Task { await schedulePickup() }
                        }
                        .disabled(isProcessingAction)
                    }
                }
            }
            .presentationDetents([.height(250)])
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil || actionError != nil },
            set: { _ in
                viewModel.errorMessage = nil
                actionError = nil
            }
        )) {
            Button("Aceptar", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? actionError ?? "")
        }
        .toolbar(.hidden, for: .tabBar)
        .task {
            viewModel.onComplete = {
                dismiss()
            }
        }
    }
}

// MARK: - Funciones Lógicas Independientes
private extension AdminSolicitudDetailView {
    @MainActor
    func schedulePickup() async {
        actionError = nil
        isProcessingAction = true
        
        do {
            struct UpdatePayload: Encodable {
                let status: String
                let pickup_date: Date
            }
            let payload = UpdatePayload(status: "accepted", pickup_date: pickupDate)
            
            try await SupabaseManager.shared.client
                .from("Donations")
                .update(payload)
                .eq("id", value: donation.id)
                .execute()
            
            isProcessingAction = false
            isSchedulingPickup = false
            dismiss()
        } catch {
            isProcessingAction = false
            actionError = "Error al actualizar: \(error.localizedDescription)"
        }
    }

    @MainActor
    func markDonationAsReceived() async {
        actionError = nil
        isProcessingAction = true
        
        do {
            struct UpdatePayload: Encodable {
                let status: String
            }
            let payload = UpdatePayload(status: "received")
            
            try await SupabaseManager.shared.client
                .from("Donations")
                .update(payload)
                .eq("id", value: donation.id)
                .execute()
            
            isProcessingAction = false
            dismiss()
        } catch {
            isProcessingAction = false
            actionError = "Error al actualizar: \(error.localizedDescription)"
        }
    }
}

// MARK: - Vistas Auxiliares

private struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
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
                        image.resizable().scaledToFit()
                            .scaleEffect(finalScale * currentScale)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { newScale in currentScale = newScale }
                                    .onEnded { scale in
                                        finalScale *= scale
                                        currentScale = 1.0
                                        if finalScale < 1.0 { finalScale = 1.0 }
                                    }
                            )
                            .onTapGesture(count: 2) { withAnimation { finalScale = 1.0 } }
                    case .empty: ProgressView().tint(.white)
                    case .failure: Image(systemName: "exclamationmark.triangle").foregroundColor(.white)
                    @unknown default: EmptyView()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}

private struct AdminNoteView: View {
    @ObservedObject var viewModel: AdminSolicitudDetailViewModel
    @FocusState private var isNoteFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Nota para el donador")) {
                    TextEditor(text: $viewModel.adminNote)
                        .frame(height: 150)
                        .focused($isNoteFocused)
                }
                Section(footer: Text("Esta nota será visible para el donador.")) { EmptyView() }
            }
            .navigationTitle("Añadir Nota")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { viewModel.cancelUpdate() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirmar") {
                        Task { await viewModel.performUpdate() }
                    }
                    .disabled(viewModel.isUpdating)
                }
            }
            .onAppear { isNoteFocused = true }
        }
        .presentationDetents([.medium])
    }
}
