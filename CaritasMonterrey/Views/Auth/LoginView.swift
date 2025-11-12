import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showPassword = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case email
        case password
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        header
                        credentialsCard
                        errorLabel
                        signInButton
                        recoveryPrompt
                        Divider().padding(.vertical, 6)
                        signUpPrompt
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color("AccentColor").opacity(0.2),
                Color("AccentColor").opacity(0.08),
                Color(.systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(spacing: 16) {
            if let icon = UIImage(named: "home_heart") {
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 8)
            } else {
                Image(systemName: "hands.sparkles.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(Color("AccentColor"))
                    .padding(20)
                    .background(
                        Circle()
                            .fill(Color("AccentColor").opacity(0.15))
                    )
            }

            VStack(spacing: 6) {
                Text("Bienvenido de vuelta")
                    .font(.system(.largeTitle, design: .rounded)).bold()
                    .multilineTextAlignment(.center)

                Text("Inicia sesión con tus credenciales para continuar")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 12)
        }
        .padding(.top, 32)
    }

    private var credentialsCard: some View {
        VStack(spacing: 20) {
            formField(
                title: "Correo electrónico",
                placeholder: "nombre@ejemplo.com",
                text: $email,
                field: .email
            )

            passwordField
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.systemBackground).opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Color.gray.opacity(0.08))
                )
                .shadow(color: Color.black.opacity(0.08), radius: 30, x: 0, y: 20)
        )
    }

    private func formField(title: String, placeholder: String, text: Binding<String>, field: Field) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.callout.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField(placeholder, text: text)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .focused($focusedField, equals: field)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(focusedField == field ? Color("AccentColor") : Color.gray.opacity(0.15), lineWidth: focusedField == field ? 1.5 : 1)
                        )
                )
        }
    }

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contraseña")
                .font(.callout.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Group {
                    if showPassword {
                        TextField("••••••••", text: $password)
                    } else {
                        SecureField("••••••••", text: $password)
                    }
                }
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .focused($focusedField, equals: .password)

                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(focusedField == .password ? Color("AccentColor") : Color.gray.opacity(0.15), lineWidth: focusedField == .password ? 1.5 : 1)
                    )
            )
        }
    }

    private var errorLabel: some View {
        Group {
            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 6)
            }
        }
    }

    private var signInButton: some View {
        Button {
            Task { await signIn() }
        } label: {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                }
                Text(isLoading ? "Ingresando..." : "Iniciar sesión")
                    .font(.system(.headline, design: .rounded))
            }
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [
                        Color("AccentColor"),
                        Color("AccentColor").opacity(0.85)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color("AccentColor").opacity(0.25), radius: 20, x: 0, y: 12)
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .disabled(isLoading || email.isEmpty || password.isEmpty)
        .opacity(isLoading || email.isEmpty || password.isEmpty ? 0.7 : 1)
        .padding(.top, 8)
    }

    private var recoveryPrompt: some View {
        HStack(spacing: 6) {
            Text("¿Olvidaste tu contraseña?")
                .foregroundStyle(.secondary)
            Button("Recuperar") {
                // Hook up recovery flow
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color("AccentColor"))
            .buttonStyle(.plain)
        }
    }

    private var signUpPrompt: some View {
        HStack(spacing: 6) {
            Text("¿No tienes cuenta?")
                .foregroundStyle(.secondary)
            NavigationLink("Crear cuenta") {
                SignUpView()
            }
            .font(.headline)
            .foregroundStyle(Color("AccentColor"))
        }
        .padding(.bottom, 24)
    }

    private func signIn() async {
        guard !email.isEmpty, !password.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await appState.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
