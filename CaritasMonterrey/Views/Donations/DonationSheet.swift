//
//  DonationSheet.swift
//  CaritasMonterrey
//
//  Created by Alumno on 05/11/25.
//

// Views/Donations/DonationSheet.swift
import SwiftUI

struct DonationSheet: View {
    @ObservedObject var viewModel: DonationSheetViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme

    private var accent: Color { scheme == .dark ? Color(.white) : .primaryCyan }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // Tipo de donación
                    GroupBox {
                        Picker("Tipo de donación", selection: $viewModel.kind) {
                            ForEach(DonationSheetViewModel.Kind.allCases) { k in
                                Text(k.rawValue).tag(k)
                            }
                        }
                        .pickerStyle(.segmented)
                    } label: {
                        Label("Tipo de donación", systemImage: "square.stack.3d.down.forward")
                            .foregroundStyle(.secondary)
                    }

                    // Monto (solo si es monetaria)
                    if viewModel.kind == .monetaria {
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

                    // Entrega
                    GroupBox {
                        Toggle(isOn: $viewModel.preferPickupAtBazaar) {
                            Text("Entregar en bazar cercano")
                        }
                        .tint(accent)

                        if viewModel.preferPickupAtBazaar {
                            Picker("Bazar", selection: $viewModel.selectedBazaarName) {
                                ForEach(viewModel.bazaars, id: \.self) { b in
                                    Text(b).tag(b)
                                }
                            }
                            .pickerStyle(.menu)
                        } else {
                            Text("Recolección a domicilio")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } label: {
                        Label("Entrega", systemImage: "mappin.and.ellipse")
                            .foregroundStyle(.secondary)
                    }

                    // Notas
                    GroupBox {
                        TextField("Notas para el equipo de Cáritas", text: $viewModel.notes, axis: .vertical)
                            .lineLimit(3...6)
                    } label: {
                        Label("Notas", systemImage: "note.text")
                            .foregroundStyle(.secondary)
                    }

                    // Estado
                    if let err = viewModel.errorMessage {
                        Text(err)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(16)
            }
            .navigationTitle("Nueva donación")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await viewModel.submit()
                            if viewModel.submitOK { dismiss() }
                        }
                    } label: {
                        if viewModel.isSubmitting {
                            ProgressView()
                        } else {
                            Text("Confirmar")
                        }
                    }
                    .disabled(viewModel.isSubmitting || !viewModel.isValid)
                }
            }
        }
    }
}

#Preview {
    DonationSheet(viewModel: DonationSheetViewModel())
}
