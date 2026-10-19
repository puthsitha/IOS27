import SwiftUI

struct ContentView: View {
    @Bindable var viewModel: ChessGameViewModel = ChessGameViewModel()
    
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 8) {
                // MARK: - Top Player HUD (Opponent / Far Side)
                PlayerHUDView(
                    color: viewModel.topPlayerColor,
                    isCurrentTurn: viewModel.currentTurn == viewModel.topPlayerColor && !viewModel.gameStatus.isGameOver,
                    timeRemaining: viewModel.timeRemaining(for: viewModel.topPlayerColor),
                    hasTimer: viewModel.timeControl.totalSeconds != nil,
                    capturedPieces: viewModel.capturedPieces(by: viewModel.topPlayerColor),
                    materialAdvantage: viewModel.materialAdvantage(for: viewModel.topPlayerColor),
                    isRotated180: viewModel.layoutMode == .faceToFace,
                    language: viewModel.language
                )
                .padding(.horizontal, 12)
                .padding(.top, 4)
                
                // MARK: - Status Pill / Alert
                if case .active(let turn, let isCheck) = viewModel.gameStatus, isCheck {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text(LocalizedStrings.checkWarning(color: turn, in: viewModel.language))
                            .fontWeight(.semibold)
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.12))
                    .clipShape(Capsule())
                    .transition(.opacity)
                }
                
                Spacer(minLength: 4)
                
                // MARK: - Chess Board
                ChessBoardView(viewModel: viewModel)
                    .padding(.horizontal, 12)
                
                Spacer(minLength: 4)
                
                // MARK: - Bottom Player HUD (Front / Near Side)
                PlayerHUDView(
                    color: viewModel.bottomPlayerColor,
                    isCurrentTurn: viewModel.currentTurn == viewModel.bottomPlayerColor && !viewModel.gameStatus.isGameOver,
                    timeRemaining: viewModel.timeRemaining(for: viewModel.bottomPlayerColor),
                    hasTimer: viewModel.timeControl.totalSeconds != nil,
                    capturedPieces: viewModel.capturedPieces(by: viewModel.bottomPlayerColor),
                    materialAdvantage: viewModel.materialAdvantage(for: viewModel.bottomPlayerColor),
                    isRotated180: false,
                    language: viewModel.language
                )
                .padding(.horizontal, 12)
                
                // MARK: - Control Buttons Bar
                GameControlsBar(viewModel: viewModel)
                    .padding(.bottom, 6)
            }
            .blur(radius: viewModel.pendingPromotion != nil ? 3 : 0)
            
            // MARK: - Pawn Promotion Modal Overlay
            if let pending = viewModel.pendingPromotion {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewModel.cancelPromotion()
                    }
                
                PawnPromotionSheet(
                    color: pending.color,
                    language: viewModel.language,
                    onSelect: { chosenType in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.completePromotion(type: chosenType)
                        }
                    },
                    onCancel: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.cancelPromotion()
                        }
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
            
            // MARK: - Game Over Banner Overlay
            if viewModel.showGameOverAlert {
                GameOverOverlayView(
                    status: viewModel.gameStatus,
                    language: viewModel.language,
                    onRestart: {
                        withAnimation {
                            viewModel.showGameOverAlert = false
                            viewModel.restartGame()
                        }
                    }
                )
                .transition(.opacity)
            }
        }
        .preferredColorScheme(viewModel.appTheme.colorScheme)
        // MARK: - Sheets
        .sheet(isPresented: $viewModel.showSettingsSheet) {
            SettingsSheetView(viewModel: viewModel)
                .preferredColorScheme(viewModel.appTheme.colorScheme)
        }
        .sheet(isPresented: $viewModel.showHistorySheet) {
            MoveHistorySheetView(moves: viewModel.moveHistory, language: viewModel.language)
                .preferredColorScheme(viewModel.appTheme.colorScheme)
        }
    }
}

#Preview {
    ContentView()
}
