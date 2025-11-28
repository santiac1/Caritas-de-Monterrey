import SwiftUI

struct DonationsFilterView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Solo recibimos el orden, ya que el estado se filtra en la barra de la vista principal
    @Binding var sortOrder: SortOrder

    var body: some View {
        NavigationStack {
            Form {
                Section("Ordenar por fecha") {
                    Picker("Orden", selection: $sortOrder) {
                        ForEach(SortOrder.allCases) { order in
                            Text(order.title).tag(order)
                        }
                    }
                    .pickerStyle(.inline)
                }
            }
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                }
            }
        }
        .presentationDetents([.height(250)]) // Altura compacta
    }
}

#Preview {
    DonationsFilterView(sortOrder: .constant(.newest))
}
