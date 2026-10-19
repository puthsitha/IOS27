import SwiftUI

// MARK: - Piece Color
enum PieceColor: String, Codable, CaseIterable {
    case white = "White"
    case black = "Black"
    
    var opposite: PieceColor {
        self == .white ? .black : .white
    }
    
    var pawnDirection: Int {
        self == .white ? -1 : 1
    }
    
    var pawnStartRow: Int {
        self == .white ? 6 : 1
    }
    
    var promotionRow: Int {
        self == .white ? 0 : 7
    }
    
    var backRankRow: Int {
        self == .white ? 7 : 0
    }
}

// MARK: - Piece Type
enum PieceType: String, Codable, CaseIterable {
    case pawn = "Pawn"
    case knight = "Knight"
    case bishop = "Bishop"
    case rook = "Rook"
    case queen = "Queen"
    case king = "King"
    
    var pointValue: Int {
        switch self {
        case .pawn: return 1
        case .knight: return 3
        case .bishop: return 3
        case .rook: return 5
        case .queen: return 9
        case .king: return 0
        }
    }
    
    var notationSymbol: String {
        switch self {
        case .pawn: return ""
        case .knight: return "N"
        case .bishop: return "B"
        case .rook: return "R"
        case .queen: return "Q"
        case .king: return "K"
        }
    }
    
    func glyph(color: PieceColor) -> String {
        switch (self, color) {
        case (.king, .white): return "♔"
        case (.queen, .white): return "♕"
        case (.rook, .white): return "♖"
        case (.bishop, .white): return "♗"
        case (.knight, .white): return "♘"
        case (.pawn, .white): return "♙"
        case (.king, .black): return "♚"
        case (.queen, .black): return "♛"
        case (.rook, .black): return "♜"
        case (.bishop, .black): return "♝"
        case (.knight, .black): return "♞"
        case (.pawn, .black): return "♟\u{FE0E}"
        }
    }
    
    // Filled glyph for consistent high-contrast rendering
    var solidGlyph: String {
        switch self {
        case .king: return "♚"
        case .queen: return "♛"
        case .rook: return "♜"
        case .bishop: return "♝"
        case .knight: return "♞"
        case .pawn: return "♟\u{FE0E}"
        }
    }
}

// MARK: - Board Square
struct Square: Hashable, Codable, CustomStringConvertible {
    let row: Int // 0...7 (0 is 8th rank, 7 is 1st rank)
    let col: Int // 0...7 (0 is 'a', 7 is 'h')
    
    init(_ row: Int, _ col: Int) {
        self.row = row
        self.col = col
    }
    
    var isValid: Bool {
        row >= 0 && row < 8 && col >= 0 && col < 8
    }
    
    var isLight: Bool {
        (row + col) % 2 == 0
    }
    
    var rank: Int {
        8 - row
    }
    
    var fileCharacter: Character {
        let files: [Character] = ["a", "b", "c", "d", "e", "f", "g", "h"]
        guard col >= 0 && col < 8 else { return "?" }
        return files[col]
    }
    
    var algebraic: String {
        "\(fileCharacter)\(rank)"
    }
    
    var description: String {
        algebraic
    }
}

// MARK: - Chess Piece
struct ChessPiece: Identifiable, Hashable, Codable {
    let id: UUID
    var type: PieceType
    let color: PieceColor
    var hasMoved: Bool
    
    init(type: PieceType, color: PieceColor, hasMoved: Bool = false, id: UUID = UUID()) {
        self.id = id
        self.type = type
        self.color = color
        self.hasMoved = hasMoved
    }
}

// MARK: - Chess Move
struct ChessMove: Identifiable, Hashable, Codable {
    let id: UUID
    let from: Square
    let to: Square
    let piece: ChessPiece
    let capturedPiece: ChessPiece?
    let isEnPassant: Bool
    let isCastling: Bool
    let promotionType: PieceType?
    var isCheck: Bool
    var isCheckmate: Bool
    
    init(
        from: Square,
        to: Square,
        piece: ChessPiece,
        capturedPiece: ChessPiece? = nil,
        isEnPassant: Bool = false,
        isCastling: Bool = false,
        promotionType: PieceType? = nil,
        isCheck: Bool = false,
        isCheckmate: Bool = false,
        id: UUID = UUID()
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.piece = piece
        self.capturedPiece = capturedPiece
        self.isEnPassant = isEnPassant
        self.isCastling = isCastling
        self.promotionType = promotionType
        self.isCheck = isCheck
        self.isCheckmate = isCheckmate
    }
    
    var san: String {
        if isCastling {
            return to.col > from.col ? "O-O" : "O-O-O"
        }
        
        var str = ""
        if piece.type == .pawn {
            if capturedPiece != nil || isEnPassant {
                str += "\(from.fileCharacter)x\(to.algebraic)"
            } else {
                str += to.algebraic
            }
            if let promotion = promotionType {
                str += "=\(promotion.notationSymbol)"
            }
        } else {
            str += piece.type.notationSymbol
            if capturedPiece != nil {
                str += "x"
            }
            str += to.algebraic
        }
        
        if isCheckmate {
            str += "#"
        } else if isCheck {
            str += "+"
        }
        
        return str
    }
}

// MARK: - Game Status
enum GameStatus: Equatable {
    case active(currentTurn: PieceColor, isCheck: Bool)
    case checkmate(winner: PieceColor)
    case stalemate
    case resignation(winner: PieceColor)
    case timeout(winner: PieceColor)
    case drawAgreed
    
    var isGameOver: Bool {
        switch self {
        case .active: return false
        default: return true
        }
    }
    
    var title: String {
        switch self {
        case .active(_, let isCheck):
            return isCheck ? "Check!" : "In Progress"
        case .checkmate(let winner):
            return "Checkmate! \(winner.rawValue) Wins!"
        case .stalemate:
            return "Draw by Stalemate"
        case .resignation(let winner):
            return "\(winner.rawValue) Wins by Resignation"
        case .timeout(let winner):
            return "\(winner.rawValue) Wins on Time"
        case .drawAgreed:
            return "Draw by Mutual Agreement"
        }
    }
}

// MARK: - Board Theme
enum BoardTheme: String, CaseIterable, Identifiable {
    case classicWood = "Classic Wood"
    case emerald = "Tournament Emerald"
    case slate = "Modern Slate"
    case ocean = "Deep Ocean"
    
    var id: String { rawValue }
    
    var lightSquareColor: Color {
        switch self {
        case .classicWood:
            return Color(red: 240/255, green: 217/255, blue: 181/255)
        case .emerald:
            return Color(red: 238/255, green: 238/255, blue: 210/255)
        case .slate:
            return Color(red: 228/255, green: 230/255, blue: 235/255)
        case .ocean:
            return Color(red: 220/255, green: 235/255, blue: 245/255)
        }
    }
    
    var darkSquareColor: Color {
        switch self {
        case .classicWood:
            return Color(red: 181/255, green: 136/255, blue: 99/255)
        case .emerald:
            return Color(red: 118/255, green: 150/255, blue: 86/255)
        case .slate:
            return Color(red: 130/255, green: 140/255, blue: 155/255)
        case .ocean:
            return Color(red: 70/255, green: 115/255, blue: 160/255)
        }
    }
    
    var boardBorderColor: Color {
        switch self {
        case .classicWood:
            return Color(red: 110/255, green: 75/255, blue: 50/255)
        case .emerald:
            return Color(red: 60/255, green: 80/255, blue: 45/255)
        case .slate:
            return Color(red: 70/255, green: 75/255, blue: 85/255)
        case .ocean:
            return Color(red: 35/255, green: 65/255, blue: 95/255)
        }
    }
}

// MARK: - Time Control
enum TimeControl: String, CaseIterable, Identifiable {
    case unlimited = "No Timer"
    case blitz3 = "3 min"
    case blitz5 = "5 min"
    case rapid10 = "10 min"
    case rapid15 = "15 min"
    case classical30 = "30 min"
    
    var id: String { rawValue }
    
    var totalSeconds: TimeInterval? {
        switch self {
        case .unlimited: return nil
        case .blitz3: return 180
        case .blitz5: return 300
        case .rapid10: return 600
        case .rapid15: return 900
        case .classical30: return 1800
        }
    }
}

// MARK: - Two-Player Offline Layout Mode
enum TwoPlayerLayoutMode: String, CaseIterable, Identifiable {
    case faceToFace = "Face to Face"
    case passAndPlay = "Pass & Play"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .faceToFace:
            return "Black HUD is rotated 180° for two players sitting across each other"
        case .passAndPlay:
            return "Both players view from standard orientation, with optional auto-rotation"
        }
    }
}
