import SwiftUI

// MARK: - Player HUD View
struct PlayerHUDView: View {
    let color: PieceColor
    let isCurrentTurn: Bool
    let timeRemaining: TimeInterval
    let hasTimer: Bool
    let capturedPieces: [ChessPiece]
    let materialAdvantage: Int // Net difference for this player
    let isRotated180: Bool
    var language: AppLanguage = .english
    
    // Sort captured pieces by value (descending)
    private var sortedCaptured: [ChessPiece] {
        capturedPieces.sorted { $0.type.pointValue > $1.type.pointValue }
    }
    
    private var timerString: String {
        guard hasTimer else { return "—" }
        let total = max(0, Int(ceil(timeRemaining)))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var timerColor: Color {
        guard hasTimer else { return .secondary }
        if timeRemaining <= 10 {
            return .red
        } else if timeRemaining <= 30 {
            return .orange
        }
        return isCurrentTurn ? .primary : .secondary
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Player Avatar & Turn Indicator
            ZStack {
                Circle()
                    .fill(color == .white ? Color.white : Color(white: 0.18))
                    .frame(width: 40, height: 40)
                    .shadow(color: Color.black.opacity(0.25), radius: 3, x: 0, y: 1)
                
                Text(color == .white ? "♔" : "♚")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(color == .white ? Color(white: 0.1) : Color(white: 0.95))
                
                // Active Turn Ring
                if isCurrentTurn {
                    Circle()
                        .strokeBorder(Color.green, lineWidth: 3)
                        .frame(width: 46, height: 46)
                }
            }
            .frame(width: 48, height: 48)
            
            // Name & Captured Pieces
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(LocalizedStrings.colorName(color, in: language))
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    if isCurrentTurn {
                        Text(LocalizedStrings.toMove(in: language))
                            .font(.system(size: 9, weight: .heavy))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .clipShape(Capsule())
                    }
                    
                    if materialAdvantage > 0 {
                        Text("+\(materialAdvantage)")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
                
                // Captured Pieces Row
                if !sortedCaptured.isEmpty {
                    HStack(spacing: -3) {
                        ForEach(Array(sortedCaptured.prefix(12).enumerated()), id: \.offset) { _, piece in
                            Text(piece.type.glyph(color: piece.color))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(piece.color == .white ? Color(white: 0.95) : Color(white: 0.2))
                                .shadow(color: piece.color == .white ? .black.opacity(0.6) : .clear, radius: 0.6)
                        }
                        if sortedCaptured.count > 12 {
                            Text("+\(sortedCaptured.count - 12)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                                .padding(.leading, 4)
                        }
                    }
                } else {
                    Text("No captures")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.7))
                }
            }
            
            Spacer()
            
            // Clock Display
            if hasTimer {
                HStack(spacing: 5) {
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                        .foregroundColor(timerColor)
                    
                    Text(timerString)
                        .font(.system(.title3, design: .monospaced, weight: .bold))
                        .foregroundColor(timerColor)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isCurrentTurn ? Color.secondary.opacity(0.18) : Color.secondary.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(isCurrentTurn ? timerColor.opacity(0.6) : Color.clear, lineWidth: 1.5)
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        // Rotate 180° for the top player in Face to Face mode
        .rotationEffect(.degrees(isRotated180 ? 180 : 0))
    }
}
