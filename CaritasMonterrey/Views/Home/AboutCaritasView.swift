import SwiftUI

struct KnowCaritasCard: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            ZStack {
                Color("PrimaryCyan")
                
                GeometryReader { proxy in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 200, height: 200)
                        .offset(x: -50, y: -50)
                        .blur(radius: 20)
                    
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 150, height: 150)
                        .offset(x: proxy.size.width - 50, y: proxy.size.height - 50)
                        .blur(radius: 20)
                }
            }
            
            // Contenido
            HStack(alignment: .center, spacing: 10) {
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Conoce a Cáritas")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

                    Text("Descubre la misión detrás de tu ayuda.")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.white.opacity(0.95))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(3)

                    HStack(spacing: 6) {
                        Text("VER MISIÓN")
                            .font(.caption.weight(.bold))
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.caption.bold())
                    }
                    .foregroundStyle(Color("PrimaryCyan"))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 18)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image("polla3")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125, height: 125)
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 8)
                    .rotationEffect(.degrees(5))
            }
            .padding(24)
        }
        .frame(height: 190)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color("PrimaryCyan").opacity(0.5), radius: 20, x: 0, y: 12)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
    }
}

struct AboutCaritasView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                ZStack(alignment: .bottomLeading) {
                    
                    LinearGradient(
                        colors: [
                            Color("SecondaryBlue"),
                            Color("PrimaryCyan")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 250)
                    .frame(maxWidth: .infinity)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: 30,
                            bottomTrailingRadius: 30,
                            topTrailingRadius: 0
                        )
                    )
                    
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 300, height: 300)
                        .offset(x: 150, y: -50)
                        .blur(radius: 30)

                    HStack(alignment: .bottom, spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 80, height: 80)
                                .shadow(radius: 10)
                            
                            if let icon = UIImage(named: "caritas") {
                                Image(uiImage: icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                            } else {
                                Image(systemName: "heart.hand.holding.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(Color("PrimaryCyan"))
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Cáritas de Monterrey")
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                                .shadow(radius: 2)

                            Text("Transformando vidas")
                                .font(.subheadline)
                                .foregroundStyle(Color.white.opacity(0.9))
                        }
                        .padding(.bottom, 10)
                    }
                    .padding(24)
                }
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)

                VStack(alignment: .leading, spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("¿Por qué existe esta app?")
                            .font(.title3.bold())
                            .foregroundStyle(Color("PrimaryDark"))

                        Text("Esta aplicación es un puente entre tus ganas de ayudar y las familias que más lo necesitan. Cada donación, por pequeña que parezca, se convierte en alimento, abrigo y oportunidades reales.")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 24)

                    Divider()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nuestra misión")
                            .font(.title3.bold())
                            .foregroundStyle(Color("PrimaryDark"))

                        Text("En Cáritas de Monterrey trabajamos para aliviar el sufrimiento de las personas en situación de vulnerabilidad, promoviendo la dignidad humana a través de programas de alimentación, salud, educación y acompañamiento integral.")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tu impacto")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        ImpactRow(icon: "cube.box.fill", color: .orange, text: "Donando artículos que ya no usas pero tienen vida.")
                        ImpactRow(icon: "mappin.and.ellipse", color: .blue, text: "Conectando ayuda con centros de acopio cercanos.")
                        ImpactRow(icon: "heart.text.square.fill", color: .pink, text: "Sosteniendo programas de apoyo social.")
                    }
                    
                    Divider()
                    
                    VStack(spacing: 16) {
                        Text("Síguenos en nuestras redes")
                            .font(.headline)
                            .foregroundStyle(Color("PrimaryBlue"))
                        
                        HStack(spacing: 20) {
                            SocialButton(icon: "f.square.fill", label: "Facebook", url: "https://www.facebook.com/caritasmonterrey")
                            SocialButton(icon: "camera.fill", label: "Instagram", url: "https://www.instagram.com/caritasmty")
                            SocialButton(icon: "globe", label: "Web", url: "https://www.caritas.org.mx")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)

                    VStack(spacing: 16) {
                        Text("No solo descargaste una app; te sumaste a una misión.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
        // Esto es CLAVE para que el azul suba hasta el tope (notch/status bar)
        .ignoresSafeArea(edges: .top)
        .navigationTitle("Conócenos")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Componentes Auxiliares

struct ImpactRow: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundStyle(color)
            }
            Text(text)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct SocialButton: View {
    let icon: String
    let label: String
    let url: String
    
    var body: some View {
        Link(destination: URL(string: url) ?? URL(string: "https://google.com")!) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(Color("PrimaryCyan"))
                }
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
