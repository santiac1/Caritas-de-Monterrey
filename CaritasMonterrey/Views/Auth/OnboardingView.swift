//  OnboardingView.swift
//  CaritasMonterrey
//
import SwiftUI
import Combine

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var navigateToLogin = false

    var body: some View {
        NavigationStack {
            ZStack {
                TabView(selection: $currentPage) {
                    ForEach(Array(OnboardingPage.pages.enumerated()), id: \.offset) { index, page in
                        VStack(spacing: 20) {
                            Spacer().frame(height: 80)

                            // Imagen principal
                            Image(page.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 220, height: 220)

                            // Título
                            Text(page.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)

                            // Descripción
                            Text(page.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)

                            Spacer()

                            // Botón principal
                            Button(action: {
                                if page.isLast {
                                    hasCompletedOnboarding = true
                                    navigateToLogin = true
                                } else {
                                    withAnimation {
                                        currentPage = min(index + 1, OnboardingPage.pages.count - 1)
                                    }
                                }
                            }) {
                                Text(page.buttonTitle)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("SecondaryBlue"))
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                                    .padding(.horizontal, 40)
                            }

                            // Indicadores de página (dots)
                            HStack(spacing: 8) {
                                ForEach(0..<OnboardingPage.pages.count, id: \.self) { dot in
                                    Circle()
                                        .fill(dot == currentPage ? Color("AccentColor") : Color.gray.opacity(0.3))
                                        .frame(width: 10, height: 10)
                                }
                            }
                            .padding(.bottom, 50)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                // 🔁 Navegación automática al login
                NavigationLink(destination: LoginView(), isActive: $navigateToLogin) {
                    EmptyView()
                }
                .hidden()
            }
        }
    }
}

// MARK: - Modelo de página
private struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
    let buttonTitle: String
    let isLast: Bool

    static let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "polla1",
            title: "Dona lo que no usas",
            description: "Ropa, juguetes, libros y más.\nConecta tus artículos con familias a través de los bazares de Cáritas.",
            buttonTitle: "Continuar",
            isLast: false
        ),
        OnboardingPage(
            imageName: "polla2",
            title: "Así de fácil",
            description: "Registra tus artículos, elige un punto de acopio o bazar cercano y programa tu entrega.",
            buttonTitle: "Continuar",
            isLast: false
        ),
        OnboardingPage(
            imageName: "polla3",
            title: "Bazares cerca de ti",
            description: "Ubica los bazares en tu zona y descubre cómo tus donaciones sostienen programas de alimentos, salud y educación.",
            buttonTitle: "Continuar",
            isLast: false
        ),
        OnboardingPage(
            imageName: "polla4",
            title: "Misión, Visión y Valores",
            description: "Fundamentados en el amor, servimos sin distinción y optimizamos recursos para apoyar a los más vulnerables.",
            buttonTitle: "¡Comienza a donar!",
            isLast: true
        )
    ]
}

#Preview {
    OnboardingView()
}
