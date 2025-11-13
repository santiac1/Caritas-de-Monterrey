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
        let years = Calendar.current.dateComponents([.year], from: birthdate, to: Date()).year ?? 0
        return years >= 18
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Crea una cuenta")
                        .font(.largeTitle).bold()
                    Text("Únete a la comunidad de Cáritas Monterrey")
                        .foregroundStyle(.secondary)
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
                            .autocorrectionDisabled(true)
                        SecureField("Contraseña (mínimo 8 caracteres)", text: $password)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))

                    DatePicker("Fecha de nacimiento", selection: $birthdate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }

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
                            .foregroundStyle(.white)
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
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !publicName.isEmpty &&
        !phone.isEmpty &&
        !email.isEmpty &&
        password.count >= 8 &&
        isAdult
    }

    // MARK: - Registro
    @MainActor
    private func register() async {
        guard formIsValid else {
            errorMessage = isAdult
            ? "Completa todos los campos y verifica tu contraseña."
            : "Debes ser mayor de 18 años."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // 1) Crear usuario en Auth
            let response = try await appState.signUp(email: email, password: password)
            let user = response.user

            // 2) Insertar perfil en tabla `profiles` con birthdate "yyyy-MM-dd"
            let payload = ProfileInsert(
                id: user.id,
                role: "user",
                first_name: firstName,
                last_name: lastName,
                username: publicName,
                phone: phone,
                birthdate: DateFormatter.yyyyMMdd.string(from: birthdate), // <- clave
                company_name: nil,
                rfc: nil,
                address: nil
            )

            _ = try await SupabaseManager.shared.client
                .from("profiles")
                .insert(payload)
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

// MARK: - Payload para escribir en Supabase
private struct ProfileInsert: Encodable {
    let id: UUID
    let role: String
    let first_name: String?
    let last_name: String?
    let username: String?
    let phone: String?
    let birthdate: String?         // "yyyy-MM-dd"
    let company_name: String?
    let rfc: String?
    let address: String?
}



#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AppState())
    }
}
