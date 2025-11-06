import SwiftUI
import Auth

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
                    GroupBox {
                        Menu {
                            ForEach(DonationSheetViewModel.DonationType.allCases) { type in
                                Button(type.rawValue) { viewModel.selectedType = type }
                            }
                        } label: {
                            HStack {
                                Text(viewModel.selectedType.rawValue)
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                        }
                    } label: {
                        Label("Tipo de donación", systemImage: "square.stack.3d.down.forward")
                            .foregroundStyle(.secondary)
                    }

                    if viewModel.selectedType == .monetaria {
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

                    if viewModel.selectedType != .monetaria {
                        GroupBox {
                            Toggle("¿Necesitas ayuda con el envío?", isOn: $viewModel.helpNeeded)
                                .tint(accent)
                            if viewModel.helpNeeded {
                                TextField("Peso o tamaño aproximado (ej: 10kg, 2 cajas)", text: $viewModel.shippingWeight)
                                    .textInputAutocapitalization(.never)
                                    .padding(.vertical, 4)
                            }
                        } label: {
                            Label("Ayuda con el envío", systemImage: "shippingbox")
                                .foregroundStyle(.secondary)
                        }
                    }

                    GroupBox {
                        Toggle(isOn: $viewModel.preferPickupAtBazaar) {
                            Text("Entregar en bazar cercano")
                        }
                        .tint(accent)

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

                    GroupBox {
                        TextField("Notas para el equipo de Cáritas", text: $viewModel.notes, axis: .vertical)
                            .lineLimit(3...6)
                    } label: {
                        Label("Notas", systemImage: "note.text")
                            .foregroundStyle(.secondary)
                    }

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
                            Text("Confirmar")
                        }
                    }
                    .disabled(viewModel.isSubmitting || !viewModel.isValid)
                }
            }
            .task {
                await viewModel.loadBazaars()
            }
            .onAppear {
                viewModel.currentUserId = appState.session?.user.id
            }
        }
        .alert("Solicitud enviada", isPresented: $showHelpAlert, actions: {
            Button("Entendido") {
                viewModel.submitOK = false
                dismiss()
            }
        }, message: {
            Text("Solicitud enviada. Un administrador revisará tu donación.")
        })
    }
}

#Preview {
    DonationSheet(viewModel: DonationSheetViewModel())
        .environmentObject(AppState())
}
