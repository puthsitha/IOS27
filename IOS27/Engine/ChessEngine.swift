import Foundation

// MARK: - Game State Snapshot (for History and Undo)
struct GameStateSnapshot: Codable {
    let board: [Square: ChessPiece]
    let currentTurn: PieceColor
    let enPassantTarget: Square?
    let lastMove: ChessMove?
    let capturedPieces: [ChessPiece]
}

// MARK: - Chess Engine
final class ChessEngine {
    private(set) var board: [Square: ChessPiece] = [:]
    private(set) var currentTurn: PieceColor = .white
    private(set) var enPassantTarget: Square?
    private(set) var lastMove: ChessMove?
    private(set) var moveHistory: [ChessMove] = []
    private(set) var capturedPieces: [ChessPiece] = []
    private var stateHistory: [GameStateSnapshot] = []
    
    init() {
        resetGame()
    }
    
    // MARK: - Reset Game
    func resetGame() {
        board.removeAll()
        moveHistory.removeAll()
        capturedPieces.removeAll()
        stateHistory.removeAll()
        lastMove = nil
        enPassantTarget = nil
        currentTurn = .white
        
        setupInitialBoard()
    }
    
    private func setupInitialBoard() {
        // Black pieces (Rank 8: row 0, Rank 7: row 1)
        let blackBackRank: [PieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]
        for col in 0..<8 {
            board[Square(0, col)] = ChessPiece(type: blackBackRank[col], color: .black)
            board[Square(1, col)] = ChessPiece(type: .pawn, color: .black)
        }
        
        // White pieces (Rank 2: row 6, Rank 1: row 7)
        let whiteBackRank: [PieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]
        for col in 0..<8 {
            board[Square(6, col)] = ChessPiece(type: .pawn, color: .white)
            board[Square(7, col)] = ChessPiece(type: whiteBackRank[col], color: .white)
        }
    }
    
    // MARK: - Piece Access
    func piece(at square: Square) -> ChessPiece? {
        board[square]
    }
    
    // MARK: - King Position
    func findKing(color: PieceColor) -> Square? {
        for (sq, piece) in board {
            if piece.type == .king && piece.color == color {
                return sq
            }
        }
        return nil
    }
    
    // MARK: - Attack Detection
    func isSquareAttacked(_ square: Square, by attackingColor: PieceColor) -> Bool {
        // 1. Attacked by pawns
        let pawnAttackRow = square.row - attackingColor.pawnDirection
        for dc in [-1, 1] {
            let pawnSq = Square(pawnAttackRow, square.col + dc)
            if pawnSq.isValid, let p = board[pawnSq], p.color == attackingColor, p.type == .pawn {
                return true
            }
        }
        
        // 2. Attacked by knights
        let knightOffsets: [(Int, Int)] = [
            (-2, -1), (-2, 1), (-1, -2), (-1, 2),
            (1, -2), (1, 2), (2, -1), (2, 1)
        ]
        for offset in knightOffsets {
            let targetSq = Square(square.row + offset.0, square.col + offset.1)
            if targetSq.isValid, let p = board[targetSq], p.color == attackingColor, p.type == .knight {
                return true
            }
        }
        
        // 3. Attacked by king
        let kingOffsets: [(Int, Int)] = [
            (-1, -1), (-1, 0), (-1, 1),
            (0, -1),           (0, 1),
            (1, -1),  (1, 0),  (1, 1)
        ]
        for offset in kingOffsets {
            let targetSq = Square(square.row + offset.0, square.col + offset.1)
            if targetSq.isValid, let p = board[targetSq], p.color == attackingColor, p.type == .king {
                return true
            }
        }
        
        // 4. Attacked by diagonals (Bishop or Queen)
        let diagonalDirections: [(Int, Int)] = [(-1, -1), (-1, 1), (1, -1), (1, 1)]
        for dir in diagonalDirections {
            var curr = Square(square.row + dir.0, square.col + dir.1)
            while curr.isValid {
                if let p = board[curr] {
                    if p.color == attackingColor && (p.type == .bishop || p.type == .queen) {
                        return true
                    }
                    break
                }
                curr = Square(curr.row + dir.0, curr.col + dir.1)
            }
        }
        
        // 5. Attacked by orthogonals (Rook or Queen)
        let orthogonalDirections: [(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        for dir in orthogonalDirections {
            var curr = Square(square.row + dir.0, square.col + dir.1)
            while curr.isValid {
                if let p = board[curr] {
                    if p.color == attackingColor && (p.type == .rook || p.type == .queen) {
                        return true
                    }
                    break
                }
                curr = Square(curr.row + dir.0, curr.col + dir.1)
            }
        }
        
        return false
    }
    
    // MARK: - Check Status
    func isKingInCheck(color: PieceColor) -> Bool {
        guard let kingSq = findKing(color: color) else { return false }
        return isSquareAttacked(kingSq, by: color.opposite)
    }
    
    // MARK: - Pseudo-Legal Moves
    func generatePseudoLegalMoves(from square: Square) -> [ChessMove] {
        guard let piece = board[square], piece.color == currentTurn else {
            return []
        }
        
        var moves: [ChessMove] = []
        
        switch piece.type {
        case .pawn:
            moves.append(contentsOf: generatePawnMoves(from: square, piece: piece))
        case .knight:
            moves.append(contentsOf: generateKnightMoves(from: square, piece: piece))
        case .bishop:
            moves.append(contentsOf: generateRayMoves(from: square, piece: piece, directions: [(-1, -1), (-1, 1), (1, -1), (1, 1)]))
        case .rook:
            moves.append(contentsOf: generateRayMoves(from: square, piece: piece, directions: [(-1, 0), (1, 0), (0, -1), (0, 1)]))
        case .queen:
            moves.append(contentsOf: generateRayMoves(from: square, piece: piece, directions: [(-1, -1), (-1, 1), (1, -1), (1, 1), (-1, 0), (1, 0), (0, -1), (0, 1)]))
        case .king:
            moves.append(contentsOf: generateKingMoves(from: square, piece: piece))
        }
        
        return moves
    }
    
    private func generatePawnMoves(from square: Square, piece: ChessPiece) -> [ChessMove] {
        var moves: [ChessMove] = []
        let dir = piece.color.pawnDirection
        
        // 1. Single forward move
        let oneStep = Square(square.row + dir, square.col)
        if oneStep.isValid && board[oneStep] == nil {
            let isPromotion = oneStep.row == piece.color.promotionRow
            if isPromotion {
                for promoType in [PieceType.queen, .rook, .bishop, .knight] {
                    moves.append(ChessMove(from: square, to: oneStep, piece: piece, promotionType: promoType))
                }
            } else {
                moves.append(ChessMove(from: square, to: oneStep, piece: piece))
            }
            
            // 2. Double forward move from start rank
            if square.row == piece.color.pawnStartRow {
                let twoStep = Square(square.row + 2 * dir, square.col)
                if twoStep.isValid && board[twoStep] == nil {
                    moves.append(ChessMove(from: square, to: twoStep, piece: piece))
                }
            }
        }
        
        // 3. Diagonal captures & En Passant
        for dc in [-1, 1] {
            let capSq = Square(square.row + dir, square.col + dc)
            guard capSq.isValid else { continue }
            
            if let destPiece = board[capSq], destPiece.color != piece.color {
                let isPromotion = capSq.row == piece.color.promotionRow
                if isPromotion {
                    for promoType in [PieceType.queen, .rook, .bishop, .knight] {
                        moves.append(ChessMove(from: square, to: capSq, piece: piece, capturedPiece: destPiece, promotionType: promoType))
                    }
                } else {
                    moves.append(ChessMove(from: square, to: capSq, piece: piece, capturedPiece: destPiece))
                }
            } else if capSq == enPassantTarget {
                // En passant capture
                let capturedPawnSq = Square(square.row, square.col + dc)
                let capturedPawn = board[capturedPawnSq]
                moves.append(ChessMove(from: square, to: capSq, piece: piece, capturedPiece: capturedPawn, isEnPassant: true))
            }
        }
        
        return moves
    }
    
    private func generateKnightMoves(from square: Square, piece: ChessPiece) -> [ChessMove] {
        var moves: [ChessMove] = []
        let offsets: [(Int, Int)] = [
            (-2, -1), (-2, 1), (-1, -2), (-1, 2),
            (1, -2), (1, 2), (2, -1), (2, 1)
        ]
        
        for offset in offsets {
            let dest = Square(square.row + offset.0, square.col + offset.1)
            guard dest.isValid else { continue }
            
            if let targetPiece = board[dest] {
                if targetPiece.color != piece.color {
                    moves.append(ChessMove(from: square, to: dest, piece: piece, capturedPiece: targetPiece))
                }
            } else {
                moves.append(ChessMove(from: square, to: dest, piece: piece))
            }
        }
        
        return moves
    }
    
    private func generateRayMoves(from square: Square, piece: ChessPiece, directions: [(Int, Int)]) -> [ChessMove] {
        var moves: [ChessMove] = []
        
        for dir in directions {
            var curr = Square(square.row + dir.0, square.col + dir.1)
            while curr.isValid {
                if let targetPiece = board[curr] {
                    if targetPiece.color != piece.color {
                        moves.append(ChessMove(from: square, to: curr, piece: piece, capturedPiece: targetPiece))
                    }
                    break
                } else {
                    moves.append(ChessMove(from: square, to: curr, piece: piece))
                }
                curr = Square(curr.row + dir.0, curr.col + dir.1)
            }
        }
        
        return moves
    }
    
    private func generateKingMoves(from square: Square, piece: ChessPiece) -> [ChessMove] {
        var moves: [ChessMove] = []
        let offsets: [(Int, Int)] = [
            (-1, -1), (-1, 0), (-1, 1),
            (0, -1),           (0, 1),
            (1, -1),  (1, 0),  (1, 1)
        ]
        
        for offset in offsets {
            let dest = Square(square.row + offset.0, square.col + offset.1)
            guard dest.isValid else { continue }
            
            if let targetPiece = board[dest] {
                if targetPiece.color != piece.color {
                    moves.append(ChessMove(from: square, to: dest, piece: piece, capturedPiece: targetPiece))
                }
            } else {
                moves.append(ChessMove(from: square, to: dest, piece: piece))
            }
        }
        
        // Castling
        if !piece.hasMoved && !isKingInCheck(color: piece.color) {
            let row = square.row
            
            // Kingside (short castle)
            let kingsideRookSq = Square(row, 7)
            if let rook = board[kingsideRookSq], rook.type == .rook && rook.color == piece.color && !rook.hasMoved {
                let fSq = Square(row, 5)
                let gSq = Square(row, 6)
                if board[fSq] == nil && board[gSq] == nil {
                    if !isSquareAttacked(fSq, by: piece.color.opposite) && !isSquareAttacked(gSq, by: piece.color.opposite) {
                        moves.append(ChessMove(from: square, to: gSq, piece: piece, isCastling: true))
                    }
                }
            }
            
            // Queenside (long castle)
            let queensideRookSq = Square(row, 0)
            if let rook = board[queensideRookSq], rook.type == .rook && rook.color == piece.color && !rook.hasMoved {
                let bSq = Square(row, 1)
                let cSq = Square(row, 2)
                let dSq = Square(row, 3)
                if board[bSq] == nil && board[cSq] == nil && board[dSq] == nil {
                    if !isSquareAttacked(dSq, by: piece.color.opposite) && !isSquareAttacked(cSq, by: piece.color.opposite) {
                        moves.append(ChessMove(from: square, to: cSq, piece: piece, isCastling: true))
                    }
                }
            }
        }
        
        return moves
    }
    
    // MARK: - Legal Moves (Safe from Check)
    func legalMoves(from square: Square) -> [ChessMove] {
        let pseudo = generatePseudoLegalMoves(from: square)
        return pseudo.filter { isMoveLegal($0) }
    }
    
    func allLegalMoves(for color: PieceColor) -> [ChessMove] {
        guard color == currentTurn else { return [] }
        var result: [ChessMove] = []
        for (sq, piece) in board where piece.color == color {
            result.append(contentsOf: legalMoves(from: sq))
        }
        return result
    }
    
    private func isMoveLegal(_ move: ChessMove) -> Bool {
        // Save current board & state
        let originalBoard = board
        let originalEnPassant = enPassantTarget
        
        // Perform move hypothetically
        applyHypotheticalMove(move)
        
        // Check if current turn's king is attacked
        let kingUnderCheck = isKingInCheck(color: move.piece.color)
        
        // Restore
        board = originalBoard
        enPassantTarget = originalEnPassant
        
        return !kingUnderCheck
    }
    
    private func applyHypotheticalMove(_ move: ChessMove) {
        board.removeValue(forKey: move.from)
        
        if move.isEnPassant {
            let capturedSq = Square(move.from.row, move.to.col)
            board.removeValue(forKey: capturedSq)
        }
        
        if move.isCastling {
            let row = move.from.row
            if move.to.col == 6 { // Kingside
                let rook = board.removeValue(forKey: Square(row, 7))
                if var r = rook {
                    r.hasMoved = true
                    board[Square(row, 5)] = r
                }
            } else if move.to.col == 2 { // Queenside
                let rook = board.removeValue(forKey: Square(row, 0))
                if var r = rook {
                    r.hasMoved = true
                    board[Square(row, 3)] = r
                }
            }
        }
        
        var movedPiece = move.piece
        movedPiece.hasMoved = true
        if let promo = move.promotionType {
            movedPiece.type = promo
        }
        board[move.to] = movedPiece
    }
    
    // MARK: - Execute Move
    @discardableResult
    func makeMove(_ move: ChessMove) -> Bool {
        // Save snapshot for undo
        let snapshot = GameStateSnapshot(
            board: board,
            currentTurn: currentTurn,
            enPassantTarget: enPassantTarget,
            lastMove: lastMove,
            capturedPieces: capturedPieces
        )
        stateHistory.append(snapshot)
        
        // Apply move
        board.removeValue(forKey: move.from)
        
        if move.isEnPassant {
            let capturedPawnSq = Square(move.from.row, move.to.col)
            if let p = board.removeValue(forKey: capturedPawnSq) {
                capturedPieces.append(p)
            }
        } else if let captured = move.capturedPiece {
            capturedPieces.append(captured)
        }
        
        if move.isCastling {
            let row = move.from.row
            if move.to.col == 6 {
                if var rook = board.removeValue(forKey: Square(row, 7)) {
                    rook.hasMoved = true
                    board[Square(row, 5)] = rook
                }
            } else if move.to.col == 2 {
                if var rook = board.removeValue(forKey: Square(row, 0)) {
                    rook.hasMoved = true
                    board[Square(row, 3)] = rook
                }
            }
        }
        
        var finalPiece = move.piece
        finalPiece.hasMoved = true
        if let promo = move.promotionType {
            finalPiece.type = promo
        }
        board[move.to] = finalPiece
        
        // Update En Passant target
        if move.piece.type == .pawn && abs(move.to.row - move.from.row) == 2 {
            enPassantTarget = Square((move.from.row + move.to.row) / 2, move.from.col)
        } else {
            enPassantTarget = nil
        }
        
        // Switch turn
        currentTurn = currentTurn.opposite
        
        // Check / Checkmate status for next player
        var completedMove = move
        let nextInCheck = isKingInCheck(color: currentTurn)
        completedMove.isCheck = nextInCheck
        
        let nextLegalMoves = allLegalMoves(for: currentTurn)
        if nextLegalMoves.isEmpty && nextInCheck {
            completedMove.isCheckmate = true
        }
        
        lastMove = completedMove
        moveHistory.append(completedMove)
        
        return true
    }
    
    // MARK: - Undo Move
    @discardableResult
    func undoMove() -> Bool {
        guard let previous = stateHistory.popLast() else {
            return false
        }
        
        board = previous.board
        currentTurn = previous.currentTurn
        enPassantTarget = previous.enPassantTarget
        lastMove = previous.lastMove
        capturedPieces = previous.capturedPieces
        
        if !moveHistory.isEmpty {
            moveHistory.removeLast()
        }
        
        return true
    }
    
    // MARK: - Evaluate Status
    func evaluateGameStatus() -> GameStatus {
        let inCheck = isKingInCheck(color: currentTurn)
        let legalMoves = allLegalMoves(for: currentTurn)
        
        if legalMoves.isEmpty {
            if inCheck {
                return .checkmate(winner: currentTurn.opposite)
            } else {
                return .stalemate
            }
        }
        
        // Insufficient material check
        if isInsufficientMaterial() {
            return .stalemate
        }
        
        return .active(currentTurn: currentTurn, isCheck: inCheck)
    }
    
    private func isInsufficientMaterial() -> Bool {
        let pieces = Array(board.values)
        if pieces.count == 2 {
            // King vs King
            return true
        }
        if pieces.count == 3 {
            // King + Bishop/Knight vs King
            if pieces.contains(where: { $0.type == .bishop || $0.type == .knight }) {
                return true
            }
        }
        return false
    }
    
    // MARK: - Material Advantage (White - Black)
    func materialScore() -> (white: Int, black: Int, difference: Int) {
        var white = 0
        var black = 0
        for piece in board.values {
            if piece.color == .white {
                white += piece.type.pointValue
            } else {
                black += piece.type.pointValue
            }
        }
        return (white, black, white - black)
    }
}
