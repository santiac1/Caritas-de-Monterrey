import SwiftUI
import Supabase

struct SignUpView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var publicName: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var birthdate: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccessAlert = false

    private var isAdult: Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: birthdate, to: Date())
        return (components.year ?? 0) >= 18
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Crea una cuenta")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Únete a la comunidad de Cáritas Monterrey")
                        .foregroundColor(.secondary)
                }
                VStack(spacing: 16) {
                    Group {
                        TextField("Nombre", text: $firstName)
                        TextField("Apellido", text: $lastName)
                        TextField("Nombre público", text: $publicName)
                        TextField("Teléfono", text: $phone)
                            .keyboardType(.phonePad)
                        TextField("Correo electrónico", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                        SecureField("Contraseña (mínimo 8 caracteres)", text: $password)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))

                    DatePicker("Fecha de nacimiento", selection: $birthdate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                }

                if let errorMessage { Text(errorMessage).foregroundColor(.red).font(.footnote) }

                Button {
                    Task { await register() }
                } label: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Registrarse")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color("AccentColor"))
                .clipShape(Capsule())
                .disabled(!formIsValid || isLoading)

                Spacer(minLength: 24)
            }
            .padding(24)
        }
        .navigationTitle("Registro")
        .alert("Cuenta creada", isPresented: $showSuccessAlert) {
            Button("Aceptar") { dismiss() }
        } message: {
            Text("Cuenta creada. Revisa tu email para confirmar tu cuenta.")
        }
    }

    private var formIsValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !publicName.isEmpty &&
        !phone.isEmpty && !email.isEmpty && password.count >= 8 && isAdult
    }

    private func register() async {
        guard formIsValid else {
            errorMessage = isAdult ? "Completa todos los campos y verifica tu contraseña." : "Debes ser mayor de 18 años."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let response = try await appState.signUp(email: email, password: password)
            guard let user = response.user else {
                throw AuthError.userCreationFailed
            }
            let profile = Profile(
                id: user.id,
                role: "user",
                firstName: firstName,
                lastName: lastName,
                username: publicName,
                phone: phone,
                birthdate: birthdate,
                companyName: nil,
                rfc: nil,
                address: nil
            )
            _ = try await SupabaseManager.shared.client.database
                .from("profiles")
                .insert(profile)
                .select()
                .single()
                .execute()
            showSuccessAlert = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

private enum AuthError: LocalizedError {
    case userCreationFailed

    var errorDescription: String? {
        switch self {
        case .userCreationFailed:
            return "No se pudo obtener el usuario creado."
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AppState())
    }
}
