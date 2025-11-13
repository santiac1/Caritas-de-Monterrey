import SwiftUI
import Supabase

struct AdminSolicitudDetailView: View {
    
    @StateObject private var viewModel: AdminSolicitudDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    let donation: Donation
    
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
            }
        }
        .navigationTitle("Solicitud de ayuda")
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                
                // --- CAMBIO AQUÍ ---
                // RECHAZAR
                Button(action: {
                    viewModel.prepareUpdate(action: .rejected)
                }) {
                    Text("Rechazar").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent) // <-- AHORA ES PROMINENT
                .tint(.red)
                .disabled(viewModel.isUpdating)

                // --- CAMBIO AQUÍ ---
                // SUGERIR
                Button(action: {
                    viewModel.prepareUpdate(action: .in_process)
                }) {
                    Text("Sugerir").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent) // <-- AHORA ES PROMINENT
                .tint(.orange)
                .disabled(viewModel.isUpdating)
                
                // APROBAR (Este se queda igual)
                Button(action: {
                    viewModel.prepareUpdate(action: .accepted)
                }) {
                    Text("Aprobar").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(viewModel.isUpdating)
            }
        }
        .sheet(isPresented: $viewModel.isShowingNoteSheet) {
            AdminNoteView(viewModel: viewModel)
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Button("Aceptar", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .toolbar(.hidden, for: .tabBar)
        .task {
            viewModel.onComplete = {
                dismiss()
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
