import SwiftUI

struct MainRegistroView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack {
                    // Logo
                    logoHeader
                        .padding(.top, 40)
                    
                    Spacer()
                    
                    // Botones en la parte inferior
                    VStack(spacing: 16) {
                        // Botón "Log in"
                        NavigationLink(destination: LoginView()) {
                            Text("Log in")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color("SecondaryBlue"))
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .shadow(color: Color("SecondaryBlue").opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        
                        // Botón "Create account"
                        NavigationLink(destination: SignUpView()) {
                            Text("Create account")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color("SecondaryBlue"))
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .shadow(color: Color("SecondaryBlue").opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 50)
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
                    .frame(height: 100) // ¡Más grande!
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            } else {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(Color("AccentColor"))
            }
            Spacer()
        }
        .padding(.bottom, 30) // Ajuste de padding inferior para el logo
    }
}

#Preview {
    MainRegistroView()
        .environmentObject(AppState())
}

