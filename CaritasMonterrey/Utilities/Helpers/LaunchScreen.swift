//
//  LaunchScreen.swift
//  CaritasMonterrey
//
//  CaritasMonterrey
//

import SwiftUI

struct LaunchScreenConfig {
    var initialDelay: Double = 0.5
    var backgroundColor: Color = .white
    var logoBackgroundColor: Color = .clear
    var scaling: CGFloat = 4
    var blurRadius: CGFloat = 15
    var forceHideLogo: Bool = true
    var animation: Animation = .smooth(duration: 1, extraBounce: 0)
    
    var zoomAnchor: UnitPoint = .center
}

struct LaunchScreen<RootView: View, Logo: View>: Scene {
    var config: LaunchScreenConfig = .init()
    @ViewBuilder var logo: () -> Logo
    @ViewBuilder var rootContent: RootView
    
    var body: some Scene {
        WindowGroup {
            rootContent
                .modifier(LaunchScreenModifier(config: config, logo: logo))
        }
    }
}

fileprivate struct LaunchScreenModifier<Logo: View>: ViewModifier {
    var config: LaunchScreenConfig
    @ViewBuilder var logo: Logo
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var splashWindow: UIWindow?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                let scenes = UIApplication.shared.connectedScenes
                for scene in scenes {
                    guard let windowScene = scene as? UIWindowScene,
                          checkStates(windowScene.activationState),
                          !windowScene.windows.contains(where: { $0.tag == 1009 })
                    else { continue }
                    
                    let window = UIWindow(windowScene: windowScene)
                    window.tag = 1009
                    window.backgroundColor = .clear
                    window.isHidden = false
                    window.isUserInteractionEnabled = true
                    window.windowLevel = .alert + 1
                    
                    let rootViewController = UIHostingController(rootView: LaunchScreenView(config: config) {
                        logo
                    } isCompleted: {
                        window.isHidden = true
                        window.isUserInteractionEnabled = false
                        self.splashWindow = nil
                    })
                    
                    rootViewController.view.backgroundColor = .clear
                    window.rootViewController = rootViewController
                    self.splashWindow = window
                }
            }
    }
    
    private func checkStates(_ state: UIWindowScene.ActivationState) -> Bool {
        switch scenePhase {
        case .active: return state == .foregroundActive
        case .inactive: return state == .foregroundInactive
        case .background: return state == .background
        default: return state.hashValue == scenePhase.hashValue
        }
    }
}

fileprivate struct LaunchScreenView<Logo: View>: View {
    var config: LaunchScreenConfig
    @ViewBuilder var logo: Logo
    var isCompleted: () -> ()
    
    @State private var scaleDown: Bool = false
    @State private var scaleUp: Bool = false
    @State private var showSolidLogo: Bool = true
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(config.backgroundColor)
                .mask {
                    GeometryReader { proxy in
                        let size = proxy.size.applying(.init(scaleX: config.scaling, y: config.scaling))
                        
                        Rectangle()
                            .overlay {
                                logo
                                    .blur(radius: config.forceHideLogo ? 0 : (scaleUp ? config.blurRadius : 0))
                                    .blendMode(.destinationOut)
                                    .animation(.smooth(duration: 0.3, extraBounce: 0)) { content in
                                        content
                                            .scaleEffect(scaleDown ? 0.8 : 1, anchor: config.zoomAnchor)
                                    }
                                    .visualEffect { content, geometryProxy in
                                        let scaleX: CGFloat = size.width / geometryProxy.size.width
                                        let scaleY: CGFloat = size.height / geometryProxy.size.height
                                        let maxScale = max(scaleX, scaleY)
                                        
                                        return content
                                            .scaleEffect(scaleUp ? maxScale : 1.0, anchor: config.zoomAnchor)
                                    }
                            }
                    }
                }
            
            if showSolidLogo {
                logo
                    .scaleEffect(scaleDown ? 0.8 : 1, anchor: config.zoomAnchor)
                    .transition(.opacity)
            }
        }
        .compositingGroup()
        .opacity(config.forceHideLogo ? 1 : (scaleUp ? 0 : 1))
        .ignoresSafeArea()
        .task {
            guard !scaleDown else { return }
            try? await Task.sleep(for: .seconds(config.initialDelay))
            
            withAnimation(.smooth(duration: 0.3 )) {
                scaleDown = true
            }
            try? await Task.sleep(for: .seconds(0.3))
            
            withAnimation(.easeIn(duration: 0.2)) {
                showSolidLogo = false
            }
            
            withAnimation(config.animation, completionCriteria: .logicallyComplete) {
                scaleUp = true
            } completion: {
                isCompleted()
            }
        }
    }
}
