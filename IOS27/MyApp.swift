import SwiftUI

@main
struct MyApp: App {
    @State private var viewModel = ChessGameViewModel()
    @State private var showLaunchScreen = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView(viewModel: viewModel)
                
                if showLaunchScreen {
                    LaunchScreenView(isPresented: $showLaunchScreen, language: viewModel.language)
                        .transition(.opacity.combined(with: .scale(scale: 1.04)))
                        .zIndex(1)
                }
            }
            .preferredColorScheme(viewModel.appTheme.colorScheme)
        }
    }
}
