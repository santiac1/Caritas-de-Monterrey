import SwiftUI
import Supabase

struct SignUpView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    // MARK: - Lógica Original (INTACTA)
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
    
    // Estado UI extra solo para el toggle de ver contraseña (necesario para el diseño)
    @State private var showPassword = false

    private var isAdult: Bool {
        let years = Calendar.current.dateComponents([.year], from: birthdate, to: Date()).year ?? 0
        return years >= 18
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

    // MARK: - Frontend Modificado
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // 1. Header igual a la imagen
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Crea una cuenta")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.black)
                        
                        HStack(spacing: 4) {
                            Text("¿Ya tienes una cuenta?")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            NavigationLink(destination: LoginView()) {
                                Text("Inicia sesión")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(Color.black)
                                    .underline()
                            }
                        }
                    }
                    .padding(.top, 10)

                    // 2. Campos con estilo "Cut Border"
                    VStack(spacing: 24) {
                        CustomStyledField(title: "Nombre", text: $firstName, isSecure: false)
                        CustomStyledField(title: "Apellido", text: $lastName, isSecure: false)
                        CustomStyledField(title: "Nombre público", text: $publicName, isSecure: false)
                        
                        CustomStyledField(title: "Teléfono", text: $phone, isSecure: false)
                            .keyboardType(.phonePad)
                        
                        // Wrapper visual para el DatePicker
                        CustomDatePickerField(title: "Fecha de nacimiento", date: $birthdate)
                        
                        CustomStyledField(title: "E-mail", text: $email, isSecure: false)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                        
                        CustomStyledField(title: "Contraseña", text: $password, isSecure: true, showPassword: $showPassword)
                    }
                    .padding(.top, 10)

                    // 3. Requisitos de contraseña (Bullet points)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tu contraseña debe de contener:")
                            .font(.caption)
                            .foregroundStyle(Color("SecondaryBlue"))
                        
                        Group {
                            bulletPoint("Mínimo 8 caracteres.")
                            bulletPoint("1 letra en mayúsculas.")
                            bulletPoint("1 número")
                            bulletPoint("1 símbolo")
                        }
                        .font(.caption)
                        .foregroundStyle(Color("SecondaryBlue"))
                    }
                    .padding(.leading, 5)

                    // Mensaje de Error
                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }

                    // 4. Texto Legal
                    Text("Al hacer clic en el botón de Registrarse debajo, accedes a los [Términos de Servicio](#) de Caritas de Monterrey y reconoces el [Aviso de Privacidad](#).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .tint(Color("AccentColor"))
                        .padding(.vertical, 10)

                    // 5. Botón Registrarse
                    Button {
                        Task { await register() }
                    } label: {
                        ZStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Registrarse")
                                    .font(.headline.weight(.bold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color("SecondaryBlue"))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                    .disabled(!formIsValid || isLoading)
                    .opacity(!formIsValid || isLoading ? 0.7 : 1)

                    Spacer(minLength: 40)
                }
                .padding(24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Cuenta creada", isPresented: $showSuccessAlert) {
            Button("Aceptar") { dismiss() }
        } message: {
            Text("Cuenta creada. Revisa tu email para confirmar tu cuenta.")
        }
    }
    
    // Helper UI
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•").bold()
            Text(text)
        }
    }

    // MARK: - Registro (Lógica Original INTACTA)
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

// MARK: - Estructuras Auxiliares (INTACTAS)
private struct ProfileInsert: Encodable {
    let id: UUID
    let role: String
    let first_name: String?
    let last_name: String?
    let username: String?
    let phone: String?
    let birthdate: String?        // "yyyy-MM-dd"
    let company_name: String?
    let rfc: String?
    let address: String?
}

// MARK: - Componentes Visuales Personalizados (Frontend)

struct CustomDatePickerField: View {
    let title: String
    @Binding var date: Date
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack {
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(height: 56)
            .background(RoundedRectangle(cornerRadius: 28).fill(Color(.systemBackground)))
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color("SecondaryBlue"), lineWidth: 1.5))
            
            Text(title)
                .font(.caption)
                .foregroundStyle(Color("SecondaryBlue"))
                .padding(.horizontal, 5)
                .background(Color(.systemBackground))
                .offset(x: 20, y: -10)
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AppState())
    }
}
