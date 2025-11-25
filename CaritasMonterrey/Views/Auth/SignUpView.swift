import SwiftUI
import Supabase

struct SignUpView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

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
    
    @State private var showPassword = false
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case firstName, lastName, publicName, phone, email, password
    }
    
    private var titleColor: Color {
        colorScheme == .dark ? Color("AccentColor") : Color("SecondaryBlue")
    }

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

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // 1. Header
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Crea una cuenta")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(titleColor)
                        
                        HStack(spacing: 4) {
                            Text("¿Ya tienes una cuenta?")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            // ⚠️ CORRECCIÓN AQUÍ: Usamos AuthRoute en lugar de destination directo
                            NavigationLink(value: AuthRoute.login) {
                                Text("Inicia sesión")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(titleColor)
                                    .underline()
                            }
                        }
                    }
                    .padding(.top, 10)

                    // 2. Campos
                    VStack(spacing: 24) {
                        CustomStyledField<Field>(title: "Nombre", text: $firstName, isSecure: false, focusedField: $focusedField, fieldValue: .firstName)
                        CustomStyledField<Field>(title: "Apellido", text: $lastName, isSecure: false, focusedField: $focusedField, fieldValue: .lastName)
                        CustomStyledField<Field>(title: "Nombre público", text: $publicName, isSecure: false, focusedField: $focusedField, fieldValue: .publicName)
                        
                        CustomStyledField<Field>(title: "Teléfono", text: $phone, isSecure: false, focusedField: $focusedField, fieldValue: .phone)
                            .keyboardType(.phonePad)
                        
                        CustomDatePickerField(title: "Fecha de nacimiento", date: $birthdate)
                        
                        CustomStyledField<Field>(
                            title: "E-mail",
                            text: $email,
                            isSecure: false,
                            focusedField: $focusedField,
                            fieldValue: .email
                        )
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        
                        CustomStyledField<Field>(
                            title: "Contraseña",
                            text: $password,
                            isSecure: true,
                            showPassword: $showPassword,
                            focusedField: $focusedField,
                            fieldValue: .password
                        )
                    }
                    .padding(.top, 10)

                    // 3. Requisitos
                    if focusedField == .password {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tu contraseña debe de contener:")
                                .font(.caption)
                                .foregroundStyle(titleColor)
                            
                            Group {
                                bulletPoint("Mínimo 8 caracteres.")
                                bulletPoint("1 letra en mayúsculas.")
                                bulletPoint("1 número")
                                bulletPoint("1 símbolo")
                            }
                            .font(.caption)
                            .foregroundStyle(titleColor)
                        }
                        .padding(.leading, 5)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .animation(.easeInOut(duration: 0.3), value: focusedField)
                    }

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

                    // 5. Botón
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
                    .buttonStyle(.glassProminent)
                    Spacer(minLength: 40)
                }
                .padding(24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                }
            }
        }
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
            let response = try await appState.signUp(email: email, password: password)
            let user = response.user

            let payload = ProfileInsert(
                id: user.id,
                role: "user",
                first_name: firstName,
                last_name: lastName,
                username: publicName,
                phone: phone,
                birthdate: DateFormatter.yyyyMMdd.string(from: birthdate),
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

// ... (Resto de estructuras ProfileInsert y CustomDatePickerField se mantienen igual)
private struct ProfileInsert: Encodable {
    let id: UUID
    let role: String
    let first_name: String?
    let last_name: String?
    let username: String?
    let phone: String?
    let birthdate: String?
    let company_name: String?
    let rfc: String?
    let address: String?
}

struct CustomDatePickerField: View {
    let title: String
    @Binding var date: Date
    @Environment(\.colorScheme) private var colorScheme
    
    private var borderColor: Color {
        colorScheme == .dark ? Color(.white) : Color("SecondaryBlue")
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color.white
    }
    
    private var labelBackgroundColor: Color {
        colorScheme == .dark ? Color.black : Color.white
    }
    
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
            .background(RoundedRectangle(cornerRadius: 28).fill(backgroundColor))
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(borderColor, lineWidth: 1.5))
            
            Text(title)
                .font(.caption)
                .foregroundStyle(borderColor)
                .background(labelBackgroundColor)
                .padding(.horizontal, 1)
                .offset(x: 20, y: -7)
        }
    }
}
