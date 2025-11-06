import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0

    var body: some View {
        NavigationStack {
            TabView(selection: $currentPage) {
                ForEach(Array(OnboardingPage.pages.enumerated()), id: \.offset) { index, page in
                    VStack(spacing: 24) {
                        Spacer()
                        Image(page.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 280)
                            .padding(.horizontal, 32)
                        Text(page.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Text(page.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Spacer()
                        Button(action: {
                            if page.isLast {
                                hasCompletedOnboarding = true
                            } else {
                                withAnimation { currentPage = min(index + 1, OnboardingPage.pages.count - 1) }
                            }
                        }) {
                            Text(page.buttonTitle)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("AccentColor"))
                                .clipShape(Capsule())
                                .padding(.horizontal, 32)
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 32)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
        }
    }
}

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
    let buttonTitle: String
    let isLast: Bool

    static let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "onboarding_slide_1",
            title: "Dona con propósito",
            description: "Explora oportunidades para ayudar a las comunidades que más lo necesitan.",
            buttonTitle: "Continuar",
            isLast: false
        ),
        OnboardingPage(
            imageName: "onboarding_slide_2",
            title: "Conecta con causas locales",
            description: "Encuentra bazares cercanos y entérate de sus necesidades en tiempo real.",
            buttonTitle: "Continuar",
            isLast: false
        ),
        OnboardingPage(
            imageName: "onboarding_slide_3",
            title: "Sigue el impacto",
            description: "Recibe notificaciones sobre el recorrido y destino de tus donaciones.",
            buttonTitle: "Continuar",
            isLast: false
        ),
        OnboardingPage(
            imageName: "onboarding_slide_4",
            title: "Únete a la comunidad",
            description: "Colabora con otras personas y empresas para llegar más lejos.",
            buttonTitle: "Continuar",
            isLast: false
        ),
        OnboardingPage(
            imageName: "onboarding_slide_5",
            title: "Misión, Visión y Valores",
            description: "Compartimos la misión de Cáritas de Monterrey: servir con amor, transparencia y compromiso.",
            buttonTitle: "¡Empieza tu aventura!",
            isLast: true
        )
    ]
}

#Preview {
    OnboardingView()
}
