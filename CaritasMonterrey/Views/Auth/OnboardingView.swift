//  OnboardingView.swift
//  CaritasMonterrey
//
import SwiftUI
import Combine

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var navigateToLogin = false
    @State private var navigateToMainRegistro = false
    @State private var showTermsAndPrivacy = false

    private var currentPageData: OnboardingPage {
        let clampedIndex = min(max(currentPage, 0), OnboardingPage.pages.count - 1)
        return OnboardingPage.pages[clampedIndex]
    }

    private func advancePage() {
        if currentPageData.isLast {
            hasCompletedOnboarding = true
            navigateToLogin = true
        } else {
            withAnimation {
                currentPage = min(currentPage + 1, OnboardingPage.pages.count - 1)
            }
        }
    }

    private func goBackPage() {
        withAnimation {
            currentPage = max(currentPage - 1, 0)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    Spacer().frame(height: 40)

                    TabView(selection: $currentPage) {
                        ForEach(Array(OnboardingPage.pages.enumerated()), id: \.offset) { index, page in
                            VStack(spacing: 20) {
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
                                VStack(spacing: 8) {
                                    Text(page.description)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 30)
                                    
                                    // Texto "ver más" solo en la última página
                                    if page.isLast {
                                        Button {
                                            showTermsAndPrivacy = true
                                        } label: {
                                            Text("ver más")
                                                .font(.caption)
                                                .foregroundStyle(Color("SecondaryBlue"))
                                                .underline()
                                        }
                                        .padding(.top, 4)
                                    }
                                }

                                Spacer()
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                    // Indicadores de página (dots)
                    HStack(spacing: 8) {
                        ForEach(0..<OnboardingPage.pages.count, id: \.self) { dot in
                            Circle()
                                .fill(dot == currentPage ? Color("AccentColor") : Color.gray.opacity(0.3))
                                .frame(width: 10, height: 10)
                        }
                    }
                    .padding(.top, 32)

                    Spacer().frame(height: 48)

                    // Botones de navegación
                    Group {
                        if currentPage == 0 {
                            Button(action: advancePage) {
                                Text(currentPageData.buttonTitle)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("SecondaryBlue"))
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                            }
                        } else if currentPageData.isLast {
                            Button(action: advancePage) {
                                Text(currentPageData.buttonTitle)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("SecondaryBlue"))
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                            }
                        } else {
                            HStack(spacing: 16) {
                                Button(action: goBackPage) {
                                    Text("Regresar")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .foregroundColor(.primary)
                                        .cornerRadius(30)
                                }

                                Button(action: advancePage) {
                                    Text(currentPageData.buttonTitle)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color("SecondaryBlue"))
                                        .foregroundColor(.white)
                                        .cornerRadius(30)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                }

                // 🔁 Navegación automática al login
                NavigationLink(destination: LoginView(), isActive: $navigateToLogin) {
                    EmptyView()
                }
                .hidden()
                
                // 🔁 Navegación automática a MainRegistro
                NavigationLink(destination: MainRegistroView(), isActive: $navigateToMainRegistro) {
                    EmptyView()
                }
                .hidden()
            }
            .sheet(isPresented: $showTermsAndPrivacy) {
                TermsAndPrivacyView()
            }
        }
    }
}

// MARK: - Vista de Aviso de Privacidad
struct TermsAndPrivacyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    privacyContent
                }
                .padding()
            }
            .navigationTitle("Aviso de Privacidad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var privacyContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Aviso de Privacidad")
                .font(.title2)
                .bold()
            
            Text("CÁRITAS DE MONTERREY, A.B.P.")
                .font(.headline)
            
            Group {
                Text("Introducción")
                    .font(.headline)
                    .padding(.top, 8)
                
                Text("CÁRITAS DE MONTERREY, A.B.P. informa sobre la recopilación, propósito y protección de datos personales de acuerdo con la Ley Federal de Protección de Datos Personales en Posesión de los Particulares (LFPDPPP).")
                
                Text("Sujetos de Datos")
                    .font(.headline)
                    .padding(.top, 8)
                
                Text("Se protegen los datos personales de beneficiarios, donantes, voluntarios, prestadores de servicio social y personal.")
                
                Text("Responsable")
                    .font(.headline)
                    .padding(.top, 8)
                
                Text("CÁRITAS DE MONTERREY, A.B.P., ubicada en FRANCISCO G. SADA PTE 2810 OBISPADO MONTERREY, NUEVO LEON, MEXICO 64040, es responsable del tratamiento de datos.")
                
                Text("Finalidades Primarias")
                    .font(.headline)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("1. Recaudación de donaciones.")
                    Text("2. Registro de donantes y pagos en línea.")
                    Text("3. Procesamiento de recibos deducibles.")
                    Text("4. Difusión de información (áreas de servicio, campañas).")
                    Text("5. Donaciones directas (únicas/recurrentes).")
                    Text("6. Invitaciones para campañas y nuevos programas.")
                    Text("7. Programas de patrocinio.")
                    Text("8. Voluntariado.")
                    Text("9. Generación de bases de datos.")
                }
                
                Text("Finalidades Secundarias")
                    .font(.headline)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("1. Evaluación de calidad de servicio.")
                    Text("2. Envío de Boletines Electrónicos.")
                    Text("3. Mercadotecnia o publicidad.")
                    Text("4. Desarrollo de estudios y programas para determinar hábitos de consumo.")
                }
                
                Text("Limitación de Uso de Datos")
                    .font(.headline)
                    .padding(.top, 8)
                
                Text("Los usuarios pueden enviar un correo electrónico a caritas@caritas.org.mx para optar por no recibir comunicaciones relacionadas con las finalidades secundarias.")
                
                Text("Cambios al Aviso de Privacidad")
                    .font(.headline)
                    .padding(.top, 8)
                
                Text("Las actualizaciones se notificarán a través del sitio web de la institución.")
                
                Text("Derechos ARCO")
                    .font(.headline)
                    .padding(.top, 8)
                
                Text("Los titulares de datos pueden ejercer sus derechos de Acceso, Rectificación, Cancelación y Oposición mediante aviso escrito en las oficinas de la institución.")
                
                Text("Última actualización: 08/01/2025")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
            .font(.body)
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
            buttonTitle: "¡Dona ahora!",
            isLast: true
        )
    ]
}

#Preview {
    OnboardingView()
}

