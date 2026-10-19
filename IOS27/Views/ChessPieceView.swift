import SwiftUI

// MARK: - Chess Piece View
struct ChessPieceView: View {
    let piece: ChessPiece
    let size: CGFloat
    
    var body: some View {
        ZStack {
            if piece.color == .white {
                // White piece: Pearl / Ivory fill with dark edge outline for crisp contrast
                // 1. Dark backing drop shadow for high contrast on light squares
                Text(piece.type.glyph(color: .white))
                    .font(.system(size: size * 0.78, weight: .bold))
                    .foregroundColor(Color.black.opacity(0.85))
                    .offset(x: 0, y: 1.2)
                
                // 2. White piece body
                Text(piece.type.glyph(color: .white))
                    .font(.system(size: size * 0.78, weight: .bold))
                    .foregroundColor(Color(red: 254/255, green: 252/255, blue: 245/255))
                    .shadow(color: Color.black.opacity(0.4), radius: 1, x: 0, y: 0.5)
            } else {
                // Black piece: Rich charcoal / obsidian with subtle silver rim for dark squares
                // 1. Subtle light highlight rim for contrast on dark squares
                Text(piece.type.glyph(color: .black))
                    .font(.system(size: size * 0.78, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.4))
                    .offset(x: 0, y: 0.8)
                
                // 2. Black piece body
                Text(piece.type.glyph(color: .black))
                    .font(.system(size: size * 0.78, weight: .bold))
                    .foregroundColor(Color(red: 28/255, green: 28/255, blue: 32/255))
                    .shadow(color: Color.black.opacity(0.5), radius: 1.5, x: 0, y: 1.5)
            }
        }
        .frame(width: size, height: size)
        .contentShape(Rectangle())
        .accessibilityLabel("\(piece.color.rawValue) \(piece.type.rawValue)")
    }
}
