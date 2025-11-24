import SwiftUI
import Supabase

struct AdminSolicitudDetailView: View {

    @StateObject private var viewModel: AdminSolicitudDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var helpRequestsViewModel: AdminHelpRequestsViewModel

    let donation: Donation

    @State private var isSchedulingPickup = false
    @State private var pickupDate = Date()
    @State private var isProcessingAction = false
    @State private var actionError: String?
    
    init(donation: Donation) {
        self.donation = donation
        _viewModel = StateObject(wrappedValue: AdminSolicitudDetailViewModel(donation: donation))
    }

    // --- BODY REDISEÑADO (NATIVO) ---
    var body: some View {
        Form {
            
            // Sección "Hero" para el Estado
            Section {
                HStack(spacing: 12) {
                    Image(systemName: donation.statusDisplay.iconName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(donation.statusDisplay.color)
                        .frame(width: 35, alignment: .center)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ESTADO ACTUAL")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(donation.statusDisplay.rawValue)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(donation.statusDisplay.color)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Sección para la Donación
            Section(header: Text("Detalles de la Solicitud")) {
                DetailRow(label: "Nombre", value: donation.name)
                DetailRow(label: "Tipo", value: donation.type.capitalized)
                DetailRow(label: "Notas", value: donation.notes ?? "—")
            }
            
            // Sección para el Donante
            Section(header: Text("Información del Donante")) {
                if let donor = donation.donorName {
                    DetailRow(label: "Nombre", value: donor)
                }

                DetailRow(label: "Necesita ayuda", value: donation.help_needed ? "Sí" : "No")

                if let shipping = donation.shipping_weight, donation.help_needed {
                    DetailRow(label: "Peso/Volumen", value: shipping)
                }

                if let pickupAddress = donation.pickup_address, !pickupAddress.isEmpty {
                    DetailRow(label: "Dirección de recolección", value: pickupAddress)
                }

                if let pickupDate = donation.pickup_date {
                    DetailRow(label: "Fecha de recolección", value: DateFormatter.localizedString(from: pickupDate, dateStyle: .medium, timeStyle: .short))
                }
            }

            if donation.help_needed && donation.status == .accepted {
                Section {
                    Button {
                        Task { await markDonationAsReceived() }
                    } label: {
                        HStack {
                            if isProcessingAction {
                                ProgressView()
                            }
                            Text("Marcar como Recibida")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isProcessingAction)
                }
            }
        }
        .navigationTitle("Solicitud de ayuda")
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: {
                    viewModel.prepareUpdate(action: .rejected)
                }) {
                    Text("Rechazar").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(viewModel.isUpdating || isProcessingAction)

                Button(action: {
                    viewModel.prepareUpdate(action: .in_process)
                }) {
                    Text("Sugerir").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .disabled(viewModel.isUpdating || isProcessingAction)

                Button(action: {
                    if donation.help_needed && donation.status == .in_process {
                        isSchedulingPickup = true
                    } else {
                        viewModel.prepareUpdate(action: .accepted)
                    }
                }) {
                    Text("Aprobar").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(viewModel.isUpdating || isProcessingAction)
            }
        }
        .sheet(isPresented: $viewModel.isShowingNoteSheet) {
            AdminNoteView(viewModel: viewModel)
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
        .sheet(isPresented: $isSchedulingPickup) {
            NavigationStack {
                Form {
                    Section {
                        DatePicker("Programar fecha de recolección", selection: $pickupDate)
                    }
                }
                .navigationTitle("Fecha de recolección")
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
        }
    }
}

// MARK: - Vista para la Hoja Modal (NATIVA)
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
                
                Section {
                    EmptyView()
                } footer: {
                    Text("Esta nota será visible para el donador.")
                }
            }
            .navigationTitle("Añadir Nota (Opcional)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        viewModel.cancelUpdate()
                    }
                    .disabled(viewModel.isUpdating)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        Task { await viewModel.performUpdate() }
                    }) {
                        if viewModel.isUpdating {
                            ProgressView()
                        } else {
                            Text("Confirmar")
                                .fontWeight(.bold)
                        }
                    }
                    .disabled(viewModel.isUpdating)
                }
            }
            .onAppear {
                isNoteFocused = true
            }
        }
    }
}

// MARK: - Private helpers
private extension AdminSolicitudDetailView {
    @MainActor
    func schedulePickup() async {
        actionError = nil
        isProcessingAction = true
        let success = await helpRequestsViewModel.approveDonation(donation, pickupDate: pickupDate)
        isProcessingAction = false
        if success {
            isSchedulingPickup = false
            dismiss()
        } else {
            actionError = helpRequestsViewModel.errorMessage
        }
    }

    @MainActor
    func markDonationAsReceived() async {
        actionError = nil
        isProcessingAction = true
        let success = await helpRequestsViewModel.markAsReceived(donation)
        isProcessingAction = false
        if success {
            dismiss()
        } else {
            actionError = helpRequestsViewModel.errorMessage
        }
    }
}


// MARK: - Vista Auxiliar (NATIVA)
private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        LabeledContent(label) {
            Text(value)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.secondary)
        }
    }
}
