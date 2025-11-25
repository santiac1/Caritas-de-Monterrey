import SwiftUI
import AVKit
import AVFoundation

// 1. Definimos las rutas posibles fuera de la vista

struct MainRegistroView: View {
    // 2. Variable de estado para controlar toda la navegación del stack
    @State private var path = NavigationPath()
    
    var body: some View {
        // 3. Vinculamos el Stack al path
        NavigationStack(path: $path) {
            ZStack {
                // --- FONDO DE VIDEO ---
                if let _ = Bundle.main.path(forResource: "background-video", ofType: "mp4") {
                    LoopingVideoPlayer(videoName: "background-video", videoType: "mp4")
                        .ignoresSafeArea()
                        .overlay(
                            Color.black.opacity(0.1).ignoresSafeArea()
                        )
                } else {
                    Color(.systemBackground).ignoresSafeArea()
                }
                
                // --- CONTENIDO ---
                VStack {
                    // Logo
                    logoHeader
                        .padding(.top, 40)
                    
                    Spacer()
                    
                    // Botones en la parte inferior
                    VStack(spacing: 16) {
                        
                        // 4. Botón "Iniciar Sesión" (Ahora es un Button, no un Link)
                        Button(action: {
                            // Lógica aquí
                            path.append(AuthRoute.login)
                        }) {
                            Text("Iniciar Sesión")
                                .font(.headline.weight(.bold))
                               
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 11)
                            
                        }
                        .buttonStyle(.glassProminent)
                        
                        // 4. Botón "Crear Cuenta"
                        Button(action: {
                            path.append(AuthRoute.signup)
                        }) {
                            Text("Crear Cuenta")
                                .font(.headline.weight(.bold))
                               
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 11)
                        }
                        .buttonStyle(.glassProminent)
                        .tint(Color(.secondaryBlue))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 50)
                }
                
                // 5. Destino de navegación centralizado

                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .login:
                        LoginView()
                    case .signup:
                        SignUpView()
                    }
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
}

// Mantén tu código de LoopingVideoPlayer y PlayerUIView exactamente igual aquí abajo...
// (No es necesario cambiar nada en el reproductor de video)
    
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
// MARK: - Video de Fondo
struct LoopingVideoPlayer: UIViewRepresentable {
    let videoName: String
    let videoType: String
    
    func makeUIView(context: Context) -> UIView {
        let view = PlayerUIView(frame: .zero, videoName: videoName, videoType: videoType)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Este método se llama cuando la vista se actualiza
        // No necesitamos hacer nada aquí ya que el video se maneja automáticamente
    }
}

class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    private var player: AVQueuePlayer?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, videoName: String, videoType: String) {
        super.init(frame: frame)
        setupVideo(videoName: videoName, videoType: videoType)
        
        // Observar notificaciones del ciclo de vida de la app
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(pauseVideo),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resumeVideo),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    private func setupVideo(videoName: String, videoType: String) {
        guard let path = Bundle.main.path(forResource: videoName, ofType: videoType) else {
            print("⚠️ No se encontró el video: \(videoName).\(videoType)")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        let queuePlayer = AVQueuePlayer(playerItem: item)
        
        player = queuePlayer
        playerLayer.player = queuePlayer
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        // Mutar el audio del video
        queuePlayer.isMuted = true
        
        // Crear el looper para reproducir infinitamente
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        queuePlayer.play()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    @objc private func pauseVideo() {
        player?.pause()
    }
    
    @objc private func resumeVideo() {
        player?.isMuted = true
        player?.play()
    }
    
    deinit {
        // Limpiar recursos
        NotificationCenter.default.removeObserver(self)
        playerLooper?.disableLooping()
        player?.pause()
        player = nil
        playerLayer.player = nil
    }
}

#Preview {
    MainRegistroView()
        .environmentObject(AppState())
}

