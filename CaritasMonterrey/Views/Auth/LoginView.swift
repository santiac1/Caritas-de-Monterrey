import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bienvenido de vuelta")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Inicia sesión con tu correo y contraseña")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                VStack(spacing: 16) {
                    TextField("Correo electrónico", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                    SecureField("Contraseña", text: $password)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                }
                if let errorMessage { Text(errorMessage).foregroundColor(.red).font(.footnote) }
                Button {
                    Task { await signIn() }
                } label: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Iniciar sesión")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color("AccentColor"))
                .clipShape(Capsule())
                .disabled(isLoading || email.isEmpty || password.isEmpty)

                HStack {
                    Text("¿No tienes cuenta?")
                        .foregroundColor(.secondary)
                    NavigationLink("Crear cuenta") {
                        SignUpView()
                    }
                    .font(.headline)
                }
                Spacer()
            }
            .padding(24)
        }
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
