import SwiftUI

// MARK: - Game Controls Bar
struct GameControlsBar: View {
    @Bindable var viewModel: ChessGameViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Undo Button
            Button {
                viewModel.undoMove()
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 18, weight: .semibold))
                    Text(LocalizedStrings.undo(in: viewModel.language))
                        .font(.system(size: 10, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            }
            .disabled(viewModel.moveHistory.isEmpty || viewModel.gameStatus.isGameOver)
            .opacity(viewModel.moveHistory.isEmpty || viewModel.gameStatus.isGameOver ? 0.4 : 1.0)
            
            // Flip Board Button
            Button {
                viewModel.toggleBoardFlip()
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 18, weight: .semibold))
                    Text(LocalizedStrings.flip(in: viewModel.language))
                        .font(.system(size: 10, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            }
            
            // Move History Button
            Button {
                viewModel.showHistorySheet = true
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "list.bullet.rectangle.portrait")
                        .font(.system(size: 18, weight: .semibold))
                    Text(LocalizedStrings.moves(count: viewModel.moveHistory.count, in: viewModel.language))
                        .font(.system(size: 10, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            }
            
            // Draw Offer / Resign Menu
            Menu {
                Button(role: .destructive) {
                    viewModel.showResignConfirmation = true
                } label: {
                    Label(LocalizedStrings.resignAction(color: viewModel.currentTurn, in: viewModel.language), systemImage: "flag.fill")
                }
                
                Button {
                    viewModel.showDrawConfirmation = true
                } label: {
                    Label(LocalizedStrings.offerDraw(in: viewModel.language), systemImage: "hand.raised.fill")
                }
                
                Divider()
                
                Button(role: .destructive) {
                    viewModel.showResetConfirmation = true
                } label: {
                    Label(LocalizedStrings.restartGame(in: viewModel.language), systemImage: "arrow.counterclockwise")
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 18, weight: .semibold))
                    Text(LocalizedStrings.actions(in: viewModel.language))
                        .font(.system(size: 10, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            }
            .disabled(viewModel.gameStatus.isGameOver)
            
            // Settings Button
            Button {
                viewModel.showSettingsSheet = true
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text(LocalizedStrings.settings(in: viewModel.language))
                        .font(.system(size: 10, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            }
        }
        .padding(.horizontal, 16)
        .confirmationDialog(
            LocalizedStrings.resignTitle(color: viewModel.currentTurn, in: viewModel.language),
            isPresented: $viewModel.showResignConfirmation,
            titleVisibility: .visible
        ) {
            Button(LocalizedStrings.resignAction(color: viewModel.currentTurn, in: viewModel.language), role: .destructive) {
                viewModel.resign(player: viewModel.currentTurn)
            }
            Button(LocalizedStrings.cancel(in: viewModel.language), role: .cancel) {}
        } message: {
            Text(LocalizedStrings.resignMessage(color: viewModel.currentTurn, in: viewModel.language))
        }
        .confirmationDialog(
            LocalizedStrings.drawTitle(in: viewModel.language),
            isPresented: $viewModel.showDrawConfirmation,
            titleVisibility: .visible
        ) {
            Button(LocalizedStrings.acceptDraw(in: viewModel.language)) {
                viewModel.agreeDraw()
            }
            Button(LocalizedStrings.cancel(in: viewModel.language), role: .cancel) {}
        } message: {
            Text(LocalizedStrings.drawMessage(in: viewModel.language))
        }
        .confirmationDialog(
            LocalizedStrings.restartTitle(in: viewModel.language),
            isPresented: $viewModel.showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button(LocalizedStrings.restartGame(in: viewModel.language), role: .destructive) {
                viewModel.restartGame()
            }
            Button(LocalizedStrings.cancel(in: viewModel.language), role: .cancel) {}
        } message: {
            Text(LocalizedStrings.restartMessage(in: viewModel.language))
        }
    }
}
