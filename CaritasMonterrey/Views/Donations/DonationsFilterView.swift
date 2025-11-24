import SwiftUI

struct DonationsFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedFilter: DonationFilter
    @Binding var sortOrder: SortOrder

    var body: some View {
        NavigationStack {
            Form {
                Section("Estado") {
                    Picker("Estado", selection: $selectedFilter) {
                        ForEach(DonationFilter.allCases, id: \.self) { filter in
                            Text(filter.title).tag(filter)
                        }
                    }
                }

                Section("Ordenar por") {
                    Picker("Orden", selection: $sortOrder) {
                        ForEach(SortOrder.allCases, id: \.self) { order in
                            Text(order.title).tag(order)
                        }
                    }
                    .pickerStyle(.inline)
                }
            }
            .navigationTitle("Filtros")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Aplicar") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    DonationsFilterView(
        selectedFilter: .constant(.all),
        sortOrder: .constant(.newest)
    )
}
