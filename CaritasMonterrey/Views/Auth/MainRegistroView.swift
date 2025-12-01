import SwiftUI
import AVKit
import AVFoundation

struct MainRegistroView: View {
    //Controla navegación
    @State private var path = NavigationPath()
    
    var body: some View {
        // Vincular el stack
        NavigationStack(path: $path) {
            ZStack {
                if let _ = Bundle.main.path(forResource: "background-video", ofType: "mov") {
                    LoopingVideoPlayer(videoName: "background-video", videoType: "mov")
                        .ignoresSafeArea()
                        .overlay(
                            Color.black.opacity(0.1).ignoresSafeArea()
                        )
                } else {
                    Color(.systemBackground).ignoresSafeArea()
                }
               
                VStack {
                    logoHeader
                        .padding(.top, 40)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                       
                        Button(action: {
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
               
                // Centralizar la navegación
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .login:
                        LoginView()
                    case .signup:
                        SignUpView()
                    case .mainRegistro:
                        EmptyView()
                    }
                }
            }
        }
    }
    
    private var logoHeader: some View {
        HStack {
            Spacer()
            if let icon = UIImage(named: "CaritasWhite") {
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

struct LoopingVideoPlayer: UIViewRepresentable {
    let videoName: String
    let videoType: String
    
    func makeUIView(context: Context) -> UIView {
        let view = PlayerUIView(frame: .zero, videoName: videoName, videoType: videoType)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    private var player: AVQueuePlayer?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) no ha sido implementado")
    }
    
    init(frame: CGRect, videoName: String, videoType: String) {
        super.init(frame: frame)
        setupVideo(videoName: videoName, videoType: videoType)
        
        // Observar laS NOTIS
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
            print("El video \(videoName).\(videoType) no ha sido encontrado")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        let queuePlayer = AVQueuePlayer(playerItem: item)
        
        player = queuePlayer
        playerLayer.player = queuePlayer
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        queuePlayer.isMuted = true
        
        //Reprdoucción en loop
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
