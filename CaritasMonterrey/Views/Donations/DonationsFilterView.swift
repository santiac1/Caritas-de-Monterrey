import SwiftUI

struct DonationsFilterView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Solo recibir orden, lo demas innecesario
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
        .presentationDetents([.height(250)])
    }
}

#Preview {
    DonationsFilterView(sortOrder: .constant(.newest))
}
