import SwiftUI
import Auth
import PhotosUI

struct DonationSheet: View {
    @ObservedObject var viewModel: DonationSheetViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var appState: AppState
    @State private var showHelpAlert = false
    @State private var showSuccessAlert = false

    private var accent: Color { scheme == .dark ? Color(.white) : .primaryCyan }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    donationNameSection
                    donationImageSection
                    
                    donationTypeSection
                    donationShippingSection
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


// MARK: - Sección Imagen
extension DonationSheet {
    private var donationImageSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
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

                // Visualizar imagen
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
                    Text("No se ha seleccionado ninguna foto.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 80, alignment: .center)
                }
            }
        } label: {
            Label("Foto(s) de la donación", systemImage: "photo.stack.fill")
                .foregroundStyle(.secondary)
        }
        .onChange(of: viewModel.selectedPhotoItems) {
            Task { await viewModel.loadImages() }
        }
    }
}

// Tipo de donación
extension DonationSheet {
    private var donationTypeSection: some View {
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



//Pregunta de ayudas
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

// Entrega de donaciones
extension DonationSheet {
    private var donationDeliverySection: some View {
        GroupBox {
            if let msg = viewModel.restrictedMessage {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text(msg)
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                .padding(.bottom, 8)
            }

            if !viewModel.helpNeeded {
                // Aviso en caso de lista vacia
                if viewModel.bazaars.isEmpty {
                    Text("No hay bazares activos en este momento.")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.top, 4)
                } else {
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
                            showSuccessAlert = true
                        }
                    }
                } label: {
                    if viewModel.isSubmitting {
                        ProgressView()
                    } else {
                        Label("Confirmar", systemImage: "checkmark")
                            .labelStyle(.titleAndIcon)
                    }
                }
                .disabled(viewModel.isSubmitting || !viewModel.isValid)
                .alert("¡Tu donación fue creada con éxito!", isPresented: $showSuccessAlert) {
                    Button("Aceptar") {
                        viewModel.submitOK = false
                        dismiss()
                    }
                } message: {
                    Text("Será revisada por un administrador.")
                }
            }
        }
    }
}

#Preview {
    DonationSheet(viewModel: DonationSheetViewModel())
        .environmentObject(AppState())
}
