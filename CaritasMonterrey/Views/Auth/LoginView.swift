import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Variables de Estado
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showPassword = false
    @FocusState private var focusedField: Field?
    
    // Estado para animación de error
    @State private var shakeAttempts: Int = 0
    
    private var titleColor: Color {
        colorScheme == .dark ? Color(.white) : Color("SecondaryBlue")
    }

    private enum Field {
        case email
        case password
    }

    var body: some View {
        // ✅ CORRECTO: Sin NavigationStack aquí, ya que MainRegistroView lo provee.
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
                .onTapGesture {
                    focusedField = nil
                }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    logoHeader
                        .padding(.top, 1)
                    
                    // Encabezado con enlace a Registro (Lógica AuthRoute implementada)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Iniciar sesión")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(titleColor)
                        
                        HStack(spacing: 4) {
                            Text("¿No tienes una cuenta?")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            // 👇 AQUÍ USAMOS LA LÓGICA DE ENUMS
                            NavigationLink(value: AuthRoute.signup) {
                                Text("Regístrate")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(titleColor)
                                    .underline()
                            }
                        }
                    }
                    .padding(.bottom, 10)
                    
                    // Formulario
                    VStack(spacing: 28) {
                        CustomStyledField<Field>(
                            title: "E-mail",
                            text: $email,
                            isSecure: false,
                            focusedField: $focusedField,
                            fieldValue: .email
                        )
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }
                        
                        CustomStyledField<Field>(
                            title: "Contraseña",
                            text: $password,
                            isSecure: true,
                            showPassword: $showPassword,
                            focusedField: $focusedField,
                            fieldValue: .password
                        )
                        .submitLabel(.go)
                        .onSubmit { Task { await signIn() } }
                    }
                    .modifier(ShakeEffect(animatableData: CGFloat(shakeAttempts)))

                    legalText
                    
                    signInButton
                    
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    goBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundStyle(Color("SecondaryBlue"))
                }
            }
        }
    }

    // MARK: - Componentes Visuales

    private var logoHeader: some View {
        HStack {
            Spacer()
            if let icon = UIImage(named: "caritas") {
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            } else {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(Color("AccentColor"))
            }
            Spacer()
        }
        .padding(.bottom, 30)
    }
    
    private var legalText: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Al hacer clic en el botón de Iniciar sesión debajo, accedes a los [Términos de Servicio](#) de Caritas de Monterrey y reconoces el [Aviso de Privacidad](#).")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .padding(.vertical, 5)
                .tint(Color("AccentColor"))
        }
    }

    private var signInButton: some View {
        Button {
            Task { await signIn() }
        } label: {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Iniciar sesión")
                        .font(.headline.weight(.bold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11) // 11 como en MainRegistroView
        }
        .disabled(isLoading)
        .buttonStyle(.glassProminent) // Estilo aplicado al botón completo
        .tint(Color("SecondaryBlue"))
        .opacity(isLoading ? 0.8 : 1)
        .padding(.top, 10)
    }
    
    // MARK: - Lógica y Animaciones
    private func signIn() async {
        errorMessage = nil
        
        guard !email.isEmpty, !password.isEmpty else {
            triggerErrorAnimation()
            return
        }
        
        isLoading = true
        
        do {
            try await appState.signIn(email: email, password: password)
        } catch {
            triggerErrorAnimation()
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func triggerErrorAnimation() {
        withAnimation(.default) {
            shakeAttempts += 1
        }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    private func goBack() {
        dismiss()
    }
}

// MARK: - Efecto Shake (Temblor)
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

// MARK: - Campo Personalizado (Estilo borde cortado) - Compartido
// NOTA: Si este struct ya existe en otro archivo o en SignUpView, bórralo de aquí para evitar errores de duplicidad.
struct CustomStyledField<Field: Hashable>: View {
    let title: String
    @Binding var text: String
    var isSecure: Bool
    var showPassword: Binding<Bool>? = nil
    var focusedField: FocusState<Field?>.Binding? = nil
    var fieldValue: Field? = nil
    @Environment(\.colorScheme) private var colorScheme
    
    private var borderColor: Color {
        colorScheme == .dark ? Color("AccentColor") : Color("SecondaryBlue")
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
                if isSecure && !(showPassword?.wrappedValue ?? false) {
                    Group {
                        if let focusedField = focusedField, let fieldValue = fieldValue {
                            SecureField("", text: $text)
                                .focused(focusedField, equals: fieldValue)
                        } else {
                            SecureField("", text: $text)
                        }
                    }
                } else {
                    Group {
                        if let focusedField = focusedField, let fieldValue = fieldValue {
                            TextField("", text: $text)
                                .focused(focusedField, equals: fieldValue)
                        } else {
                            TextField("", text: $text)
                        }
                    }
                }
                
                if isSecure, let showPass = showPassword {
                    Button {
                        showPass.wrappedValue.toggle()
                    } label: {
                        Image(systemName: showPass.wrappedValue ? "eye.slash" : "eye")
                            .foregroundStyle(borderColor)
                    }
                }
            }
            .padding()
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(borderColor, lineWidth: 1.5)
            )
            
            Text(title)
                .font(.caption)
                .foregroundStyle(borderColor)
                .background(labelBackgroundColor)
                .padding(.horizontal, 1)
                .offset(x: 20, y: -8)
        }
    }
}

