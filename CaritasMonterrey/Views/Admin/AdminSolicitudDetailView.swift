import SwiftUI
import Supabase

struct AdminSolicitudDetailView: View {
    let donation: Donation
    @State private var isUpdating = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DetailRow(label: "Nombre", value: donation.name)
                DetailRow(label: "Tipo", value: donation.type.capitalized)
                DetailRow(label: "Notas", value: donation.notes ?? "Sin notas")
                DetailRow(label: "Necesita ayuda", value: donation.help_needed ? "Sí" : "No")
                if let shipping = donation.shipping_weight {
                    DetailRow(label: "Peso/Volumen", value: shipping)
                }
                DetailRow(label: "Estado", value: donation.statusDisplay.rawValue)
                if let donor = donation.donorName {
                    DetailRow(label: "Donante", value: donor)
                }
            }
            .padding()
        }
        .navigationTitle("Solicitud de ayuda")
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: { Task { await updateStatus("ayuda_rechazada") } }) {
                    Text("Rechazar")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(isUpdating)

                Button(action: { Task { await updateStatus("ayuda_aprobada") } }) {
                    Text("Aprobar")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(isUpdating)
            }
        }
        .alert("Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { _ in errorMessage = nil }
        )) {
            Button("Aceptar", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func updateStatus(_ newStatus: String) async {
        isUpdating = true
        errorMessage = nil
        do {
            try await SupabaseManager.shared.client
                .from("Donations")
                .update(["status": newStatus])
                .eq("id", value: donation.id)
                .execute()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isUpdating = false
    }
}

private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}
