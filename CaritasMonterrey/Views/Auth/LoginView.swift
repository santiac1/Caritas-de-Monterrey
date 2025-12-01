import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showPassword = false
    @FocusState private var focusedField: Field?
    
    @State private var shakeAttempts: Int = 0
    
    private var titleColor: Color {
        colorScheme == .dark ? Color(.white) : Color("SecondaryBlue")
    }

    private enum Field {
        case email
        case password
    }

    var body: some View {
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
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Iniciar sesión")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(titleColor)
                        
                        HStack(spacing: 4) {
                            Text("¿No tienes una cuenta?")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
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
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
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

                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.footnote)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

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
                }
            }
        }
    }

    // Empieza para visual

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
            .padding(.vertical, 11)
        }
        .disabled(isLoading)
        .buttonStyle(.glassProminent)
        .tint(Color("SecondaryBlue"))
        .opacity(isLoading ? 0.8 : 1)
        .padding(.top, 10)
    }
    
    // Empieza logica para animaciones
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
            errorMessage = "La contraseña o el email son incorrectos."
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

struct CustomStyledField<Field: Hashable>: View {
    let title: String
    @Binding var text: String
    var isSecure: Bool
    var showPassword: Binding<Bool>? = nil
    var focusedField: FocusState<Field?>.Binding? = nil
    var fieldValue: Field? = nil
    @Environment(\.colorScheme) private var colorScheme
    
    private var isActive: Bool {
        if let focusedField = focusedField, let fieldValue = fieldValue {
            return focusedField.wrappedValue == fieldValue
        }
        return false
    }
    
    private var borderColor: Color {
        if isActive {
            return colorScheme == .dark ? Color("PrimaryCyan") : Color("SecondaryBlue")
        } else {
            return colorScheme == .dark ? Color.white : Color.black
        }
    }
    
    private var borderWidth: CGFloat {
        isActive ? 2.5 : 1.5
    }
    
    private var cornerRadius: CGFloat {
        isActive ? 30 : 28
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color.white
    }
    
    private var labelBackgroundColor: Color {
        colorScheme == .dark ? Color.black : Color.white
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(spacing: 12) {
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
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .animation(.easeInOut(duration: 0.2), value: isActive)
            
            Text(title)
                .font(isActive ? .caption.weight(.semibold) : .caption)
                .foregroundStyle(borderColor)
                .padding(.horizontal, 10) // Más padding interno para cortar la línea
                .background(labelBackgroundColor)
                .offset(x: 20, y: -9) // Alineado más cerca de la línea
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if let focusedField = focusedField, let fieldValue = fieldValue {
                focusedField.wrappedValue = fieldValue
            }
        }
    }
}

