import SwiftUI

// MARK: - Chess Square View
struct ChessSquareView: View {
    let square: Square
    let piece: ChessPiece?
    let size: CGFloat
    let isSelected: Bool
    let isLegalDestination: Bool
    let isLastMoveSquare: Bool
    let isKingInCheck: Bool
    let theme: BoardTheme
    let isFlipped: Bool
    let onTap: () -> Void
    
    // Label coordinate checks
    private var showRankLabel: Bool {
        isFlipped ? square.col == 7 : square.col == 0
    }
    
    private var showFileLabel: Bool {
        isFlipped ? square.row == 0 : square.row == 7
    }
    
    private var squareBaseColor: Color {
        square.isLight ? theme.lightSquareColor : theme.darkSquareColor
    }
    
    private var labelColor: Color {
        square.isLight ? theme.darkSquareColor.opacity(0.9) : theme.lightSquareColor.opacity(0.9)
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // 1. Base Tile Color
                Rectangle()
                    .fill(squareBaseColor)
                
                // 2. Last Move Highlight
                if isLastMoveSquare {
                    Rectangle()
                        .fill(Color.yellow.opacity(0.38))
                }
                
                // 3. Selection Highlight
                if isSelected {
                    Rectangle()
                        .fill(Color.blue.opacity(0.32))
                    Rectangle()
                        .strokeBorder(Color.blue, lineWidth: 2)
                }
                
                // 4. King In Check Glow
                if isKingInCheck {
                    RadialGradient(
                        colors: [Color.red.opacity(0.85), Color.red.opacity(0.15), .clear],
                        center: .center,
                        startRadius: 4,
                        endRadius: size * 0.48
                    )
                }
                
                // 5. Board Coordinate Labels
                VStack {
                    HStack {
                        if showRankLabel {
                            Text("\(square.rank)")
                                .font(.system(size: max(10, size * 0.2), weight: .bold))
                                .foregroundColor(labelColor)
                                .padding(3)
                        }
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        if showFileLabel {
                            Text(String(square.fileCharacter))
                                .font(.system(size: max(10, size * 0.2), weight: .bold))
                                .foregroundColor(labelColor)
                                .padding(3)
                        }
                    }
                }
                
                // 6. Chess Piece
                if let piece = piece {
                    ChessPieceView(piece: piece, size: size)
                        .transition(.scale.combined(with: .opacity))
                }
                
                // 7. Legal Move Indicator
                if isLegalDestination {
                    if piece == nil {
                        // Empty square: solid translucent dot
                        Circle()
                            .fill(Color.primary.opacity(0.25))
                            .frame(width: size * 0.28, height: size * 0.28)
                    } else {
                        // Capture: prominent targeting ring
                        Circle()
                            .strokeBorder(Color.red.opacity(0.65), lineWidth: max(2.5, size * 0.07))
                            .frame(width: size * 0.84, height: size * 0.84)
                    }
                }
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Chess Board View
struct ChessBoardView: View {
    @Bindable var viewModel: ChessGameViewModel
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let availableHeight = geometry.size.height
            let sideLength = min(availableWidth, availableHeight)
            let boardBorderWidth: CGFloat = 8
            let boardInnerSize = sideLength - (boardBorderWidth * 2)
            let squareSize = floor(boardInnerSize / 8)
            let totalBoardSize = (squareSize * 8) + (boardBorderWidth * 2)
            
            ZStack {
                // Board Outer Border Frame
                RoundedRectangle(cornerRadius: 12)
                    .fill(viewModel.boardTheme.boardBorderColor)
                    .frame(width: totalBoardSize, height: totalBoardSize)
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                
                // Inner Board (8x8 squares)
                VStack(spacing: 0) {
                    let rows = viewModel.isBoardVisuallyFlipped ? Array((0..<8).reversed()) : Array(0..<8)
                    let cols = viewModel.isBoardVisuallyFlipped ? Array((0..<8).reversed()) : Array(0..<8)
                    
                    ForEach(rows, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(cols, id: \.self) { col in
                                let sq = Square(row, col)
                                let piece = viewModel.board[sq]
                                let isSelected = viewModel.selectedSquare == sq
                                let isLegal = viewModel.showLegalMoveHints && viewModel.legalDestinations.contains(sq)
                                let isLastMove = (viewModel.lastMove?.from == sq || viewModel.lastMove?.to == sq)
                                let isCheck = (viewModel.kingInCheckSquare == sq)
                                
                                ChessSquareView(
                                    square: sq,
                                    piece: piece,
                                    size: squareSize,
                                    isSelected: isSelected,
                                    isLegalDestination: isLegal,
                                    isLastMoveSquare: isLastMove,
                                    isKingInCheck: isCheck,
                                    theme: viewModel.boardTheme,
                                    isFlipped: viewModel.isBoardVisuallyFlipped,
                                    onTap: {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            viewModel.tapSquare(sq)
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
