import SwiftUI

// MARK: - Animated Launch Screen
struct LaunchScreenView: View {
    @Binding var isPresented: Bool
    var language: AppLanguage = .english
    
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var glowOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Background luxury gradient
            LinearGradient(
                colors: [
                    Color(red: 16/255, green: 20/255, blue: 30/255),
                    Color(red: 8/255, green: 10/255, blue: 15/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Subtle chess grid watermark
            GeometryReader { proxy in
                let cols = 8
                let size = proxy.size.width / CGFloat(cols)
                VStack(spacing: 0) {
                    ForEach(0..<16) { r in
                        HStack(spacing: 0) {
                            ForEach(0..<cols, id: \.self) { c in
                                Rectangle()
                                    .fill((r + c) % 2 == 0 ? Color.white.opacity(0.018) : Color.clear)
                                    .frame(width: size, height: size)
                            }
                        }
                    }
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Centered App Logo
                ZStack {
                    // Pulsing golden glow behind logo
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 212/255, green: 175/255, blue: 55/255).opacity(0.35),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: 130
                            )
                        )
                        .frame(width: 260, height: 260)
                        .scaleEffect(glowOpacity > 0 ? 1.15 : 0.85)
                        .opacity(glowOpacity)
                    
                    // Logo Image from Asset Catalog
                    if let _ = UIImage(named: "LaunchLogo") {
                        Image("LaunchLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 160, height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 38, style: .continuous))
                            .shadow(color: Color.black.opacity(0.6), radius: 20, x: 0, y: 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 38, style: .continuous)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 255/255, green: 223/255, blue: 128/255),
                                                Color(red: 180/255, green: 140/255, blue: 40/255)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                    } else {
                        // Fallback Procedural Logo
                        ZStack {
                            Circle()
                                .fill(Color(red: 30/255, green: 35/255, blue: 48/255))
                                .frame(width: 140, height: 140)
                            
                            Text("♔")
                                .font(.system(size: 90, weight: .bold))
                                .foregroundColor(Color(red: 250/255, green: 246/255, blue: 236/255))
                        }
                    }
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                // Title and Subtitle
                VStack(spacing: 8) {
                    Text(language == .khmer ? "អុកចត្រង្គក្រៅបណ្ដាញ" : "CHESS OFFLINE")
                        .font(.system(size: language == .khmer ? 28 : 34, weight: .heavy, design: .serif))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 255/255, green: 240/255, blue: 200/255),
                                    Color(red: 212/255, green: 175/255, blue: 55/255)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .tracking(language == .khmer ? 1 : 4)
                    
                    Text(LocalizedStrings.launchSubtitle(in: language))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.secondary)
                        .tracking(language == .khmer ? 1 : 4)
                }
                .opacity(textOpacity)
                
                Spacer()
                
                // Subtle version or ready indicator
                Text(LocalizedStrings.tapToBegin(in: language))
                    .font(.caption2)
                    .foregroundColor(Color.white.opacity(0.35))
                    .padding(.bottom, 24)
                    .opacity(textOpacity)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            dismissLaunchScreen()
        }
        .onAppear {
            // Animate logo entrance
            withAnimation(.easeOut(duration: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            // Animate glow pulse
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                glowOpacity = 0.9
            }
            
            // Animate text appearance
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                textOpacity = 1.0
            }
            
            // Auto-dismiss launch screen after 1.6s
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                dismissLaunchScreen()
            }
        }
    }
    
    private func dismissLaunchScreen() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isPresented = false
        }
    }
}

#Preview {
    LaunchScreenView(isPresented: .constant(true))
}
