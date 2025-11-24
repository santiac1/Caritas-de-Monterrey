import SwiftUI
import Auth
import PhotosUI

struct DonationSheet: View {
    @ObservedObject var viewModel: DonationSheetViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var appState: AppState
    @State private var showHelpAlert = false

    private var accent: Color { scheme == .dark ? Color(.white) : .primaryCyan }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    donationNameSection // Campo de nombre
                    donationImageSection // Sección de imagen
                    
                    donationTypeSection
                    donationDeliverySection
                    donationNotesSection
                    donationErrorSection
                }
                .padding(16)
            }
            .navigationTitle("Nueva donación")
            .toolbar { toolbarContent }
            .task { await viewModel.loadBazaars() }
            .onAppear {
                viewModel.currentUserId = appState.session?.user.id
                viewModel.prefillPickupAddress(appState.profile?.address)
            }
            .alert("Solicitud enviada", isPresented: $showHelpAlert) {
                Button("Entendido") {
                    viewModel.submitOK = false
                    dismiss()
                }
            } message: {
                Text("Solicitud enviada. Un administrador revisará tu donación.")
            }
        }
    }
}

// MARK: - Sección Nombre
extension DonationSheet {
    private var donationNameSection: some View {
        GroupBox {
            TextField("Nombre (ej: Ropa de invierno, Despensa)", text: $viewModel.donationName)
                .padding(.vertical, 4)
        } label: {
            Label("Nombre de la donación", systemImage: "tag.fill")
                .foregroundStyle(.secondary)
        }
    }
}


// MARK: - Sección Imagen (MODIFICADO)
extension DonationSheet {
    private var donationImageSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                // 1. El PhotosPicker (botón)
                PhotosPicker(
                    selection: $viewModel.selectedPhotoItems,
                    maxSelectionCount: 10,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    HStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.title3)
                        Text("Seleccionar foto(s)")
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(accent)
                    .padding(.vertical, 8)
                }
                
                Divider().padding(.bottom, 8)

                // 2. El área de visualización de imágenes
                if !viewModel.selectedImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(viewModel.selectedImages.indices, id: \.self) { index in
                                viewModel.selectedImages[index]
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(alignment: .topTrailing) {
                                        Button {
                                            viewModel.removeImage(at: index)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.callout)
                                                .foregroundStyle(.white, Color.black.opacity(0.6))
                                                .padding(4)
                                        }
                                    }
                            }
                        }
                    }
                    .frame(height: 100)
                    
                } else {
                    // 3. Texto de placeholder
                    Text("No se ha seleccionado ninguna foto.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 80, alignment: .center)
                }
            }
        } label: {
            // --- Etiqueta MODIFICADA (ya no es opcional) ---
            Label("Foto(s) de la donación", systemImage: "photo.stack.fill")
                .foregroundStyle(.secondary)
        }
        .onChange(of: viewModel.selectedPhotoItems) {
            Task { await viewModel.loadImages() }
        }
    }
}

// MARK: - Tipo de donación
extension DonationSheet {
    private var donationTypeSection: some View {
        // Dentro de DonationSheet
        GroupBox {
            Menu {
                ForEach(viewModel.availableTypes) { opt in
                    Button {
                        viewModel.selectedType = opt
                    } label: {
                        Label(opt.displayName, systemImage: opt.systemImage)
                    }
                }
            } label: {
                HStack {
                    Label(viewModel.selectedType?.displayName ?? "Selecciona un tipo",
                          systemImage: viewModel.selectedType?.systemImage ?? "square.stack.3d.down.forward")
                        .labelStyle(.titleAndIcon)
                        .foregroundStyle(viewModel.selectedType == nil ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "chevron.down").foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
            }
        } label: {
            Label("Tipo de donación", systemImage: "square.stack.3d.down.forward")
                .foregroundStyle(.secondary)
        }

    }
}

// MARK: - Monto
extension DonationSheet {
    private var donationAmountSection: some View {
        GroupBox {
            HStack {
                Text("$")
                    .font(.title3).bold()
                    .foregroundStyle(accent)
                TextField("Monto", text: $viewModel.amount)
                    .keyboardType(.decimalPad)
                    .textInputAutocapitalization(.never)
            }
            .padding(.vertical, 4)
        } label: {
            Label("Monto", systemImage: "creditcard")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Envío
extension DonationSheet {
    private var donationShippingSection: some View {
        GroupBox {
            Toggle("¿Necesitas ayuda con el envío?", isOn: $viewModel.helpNeeded)
                .tint(accent)

            if viewModel.helpNeeded {
                TextField("Peso o tamaño aproximado (ej: 10kg, 2 cajas)", text: $viewModel.shippingWeight)
                    .textInputAutocapitalization(.never)
                    .padding(.vertical, 4)

                TextField("Dirección de recolección", text: $viewModel.pickupAddress)
                    .textInputAutocapitalization(.sentences)
                    .padding(.vertical, 4)
            }
        } label: {
            Label("Ayuda con el envío", systemImage: "shippingbox")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Entrega
extension DonationSheet {
    private var donationDeliverySection: some View {
        GroupBox {
            Toggle(isOn: $viewModel.preferPickupAtBazaar) {
                Text("Entregar en bazar cercano")
            }
            .tint(Color("AccentColor"))

            if viewModel.preferPickupAtBazaar {
                Menu {
                    ForEach(viewModel.bazaars) { bazaar in
                        Button(bazaar.name) { viewModel.selectedBazaar = bazaar }
                    }
                } label: {
                    HStack {
                        Text(viewModel.selectedBazaar?.name ?? "Selecciona un bazar")
                            .foregroundStyle(viewModel.selectedBazaar == nil ? .secondary : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .padding(.vertical, 4)
                }
            } else {
                Text("Recolección a domicilio")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        } label: {
            Label("Entrega", systemImage: "mappin.and.ellipse")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Notas
extension DonationSheet {
    private var donationNotesSection: some View {
        GroupBox {
            TextField("Notas para el equipo de Cáritas", text: $viewModel.notes, axis: .vertical)
                .lineLimit(3...6)
        } label: {
            Label("Notas", systemImage: "note.text")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Errores
extension DonationSheet {
    private var donationErrorSection: some View {
        Group {
            if let err = viewModel.errorMessage {
                Text(err)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Toolbar
extension DonationSheet {
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cerrar", systemImage:"xmark") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        viewModel.currentUserId = appState.session?.user.id
                        await viewModel.submit()
                        if viewModel.submitOK {
                            if viewModel.helpNeeded {
                                showHelpAlert = true
                            } else {
                                dismiss()
                            }
                        }
                    }
                } label: {
                    if viewModel.isSubmitting {
                        ProgressView()
                    } else {
                        Button("Confirmar",systemImage:"checkmark") {
                            dismiss()
                        }
                    }
                }
                // El botón se desactivará automáticamente si `isValid` es falso
                .disabled(viewModel.isSubmitting || !viewModel.isValid)
            }
        }
    }
}

#Preview {
    DonationSheet(viewModel: DonationSheetViewModel())
        .environmentObject(AppState())
}
