import SwiftUI
import Observation
import AudioToolbox
import UIKit

// MARK: - Pending Promotion
struct PendingPromotion: Identifiable, Equatable {
    let id = UUID()
    let from: Square
    let to: Square
    let color: PieceColor
    let capturedPiece: ChessPiece?
}

// MARK: - Chess Game View Model
@Observable
@MainActor
final class ChessGameViewModel {
    // MARK: - Engine & State
    @ObservationIgnored
    private let engine = ChessEngine()
    
    var board: [Square: ChessPiece] = [:]
    var currentTurn: PieceColor = .white
    var gameStatus: GameStatus = .active(currentTurn: .white, isCheck: false)
    var lastMove: ChessMove?
    var moveHistory: [ChessMove] = []
    var capturedByWhite: [ChessPiece] = []
    var capturedByBlack: [ChessPiece] = []
    var materialAdvantage: Int = 0 // Positive = White ahead, Negative = Black ahead
    
    // MARK: - Selection & Interactivity
    var selectedSquare: Square?
    var legalMovesForSelected: [ChessMove] = []
    var legalDestinations: Set<Square> = []
    var pendingPromotion: PendingPromotion?
    
    // MARK: - Clocks & Timers
    var timeControl: TimeControl = .rapid10 {
        didSet {
            setupTimers()
        }
    }
    var whiteTimeRemaining: TimeInterval = 600
    var blackTimeRemaining: TimeInterval = 600
    var isTimerRunning: Bool = false
    
    @ObservationIgnored
    private var timerTask: Task<Void, Never>?
    
    // MARK: - Customization & Preferences
    var boardTheme: BoardTheme = .classicWood
    var layoutMode: TwoPlayerLayoutMode = .faceToFace
    var autoRotateBoard: Bool = false
    var boardFlipped: Bool = false
    var showLegalMoveHints: Bool = true
    var soundHapticsEnabled: Bool = true
    
    // MARK: - Language & Theme Preferences
    var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "app_language")
        }
    }
    
    var appTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(appTheme.rawValue, forKey: "app_theme")
        }
    }
    
    // MARK: - Dialogs & Sheets
    var showGameOverAlert: Bool = false
    var showResetConfirmation: Bool = false
    var showResignConfirmation: Bool = false
    var showDrawConfirmation: Bool = false
    var showSettingsSheet: Bool = false
    var showHistorySheet: Bool = false
    
    init() {
        let savedLang = UserDefaults.standard.string(forKey: "app_language").flatMap(AppLanguage.init(rawValue:)) ?? .english
        self.language = savedLang
        
        let savedTheme = UserDefaults.standard.string(forKey: "app_theme").flatMap(AppTheme.init(rawValue:)) ?? .system
        self.appTheme = savedTheme
        
        syncFromEngine()
        setupTimers()
    }
    
    deinit {
        timerTask?.cancel()
    }
    
    // MARK: - Engine Synchronization
    private func syncFromEngine() {
        board = engine.board
        currentTurn = engine.currentTurn
        lastMove = engine.lastMove
        moveHistory = engine.moveHistory
        
        let allCaptured = engine.capturedPieces
        capturedByWhite = allCaptured.filter { $0.color == .black }
        capturedByBlack = allCaptured.filter { $0.color == .white }
        
        let (_, _, diff) = engine.materialScore()
        materialAdvantage = diff
        
        gameStatus = engine.evaluateGameStatus()
        
        if gameStatus.isGameOver {
            stopTimer()
            showGameOverAlert = true
            playGameOverFeedback()
        } else if case .active(_, let isCheck) = gameStatus, isCheck {
            playCheckFeedback()
        }
    }
    
    // MARK: - Timer Logic
    private func setupTimers() {
        if let total = timeControl.totalSeconds {
            whiteTimeRemaining = total
            blackTimeRemaining = total
        } else {
            whiteTimeRemaining = 0
            blackTimeRemaining = 0
        }
        stopTimer()
    }
    
    private func startTimerIfNeeded() {
        guard timeControl.totalSeconds != nil, !gameStatus.isGameOver, !isTimerRunning else { return }
        isTimerRunning = true
        
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second ticks
                guard let self = self else { break }
                
                await MainActor.run {
                    guard self.isTimerRunning, !self.gameStatus.isGameOver else { return }
                    
                    if self.currentTurn == .white {
                        self.whiteTimeRemaining = max(0, self.whiteTimeRemaining - 0.1)
                        if self.whiteTimeRemaining <= 0 {
                            self.handleTimeout(loser: .white)
                        }
                    } else {
                        self.blackTimeRemaining = max(0, self.blackTimeRemaining - 0.1)
                        if self.blackTimeRemaining <= 0 {
                            self.handleTimeout(loser: .black)
                        }
                    }
                }
            }
        }
    }
    
    private func stopTimer() {
        isTimerRunning = false
        timerTask?.cancel()
        timerTask = nil
    }
    
    private func handleTimeout(loser: PieceColor) {
        stopTimer()
        gameStatus = .timeout(winner: loser.opposite)
        showGameOverAlert = true
        playGameOverFeedback()
    }
    
    // MARK: - User Interactions
    func tapSquare(_ square: Square) {
        guard !gameStatus.isGameOver else { return }
        
        // If a square is already selected
        if let currentSelected = selectedSquare {
            // Check if tapped square is in legal destinations
            if legalDestinations.contains(square) {
                if let movingPiece = board[currentSelected] {
                    // Check for pawn promotion
                    if movingPiece.type == .pawn && square.row == movingPiece.color.promotionRow {
                        let capPiece = board[square]
                        pendingPromotion = PendingPromotion(
                            from: currentSelected,
                            to: square,
                            color: movingPiece.color,
                            capturedPiece: capPiece
                        )
                        return
                    }
                }
                
                // Execute move
                if let move = legalMovesForSelected.first(where: { $0.to == square }) {
                    executeMove(move)
                    clearSelection()
                    return
                }
            }
            
            // Switch selection to another friendly piece
            if let clickedPiece = board[square], clickedPiece.color == currentTurn {
                selectSquare(square)
                playSelectionFeedback()
                return
            }
            
            // Deselect
            clearSelection()
            return
        }
        
        // No selection: select friendly piece
        if let piece = board[square], piece.color == currentTurn {
            selectSquare(square)
            playSelectionFeedback()
        }
    }
    
    private func selectSquare(_ square: Square) {
        selectedSquare = square
        let moves = engine.legalMoves(from: square)
        legalMovesForSelected = moves
        legalDestinations = Set(moves.map { $0.to })
    }
    
    func clearSelection() {
        selectedSquare = nil
        legalMovesForSelected = []
        legalDestinations = []
    }
    
    // MARK: - Execute Move
    private func executeMove(_ move: ChessMove) {
        let isCapture = move.capturedPiece != nil || move.isEnPassant
        
        engine.makeMove(move)
        syncFromEngine()
        
        // Start clock after first move
        if moveHistory.count == 1 {
            startTimerIfNeeded()
        }
        
        // Sound and Haptic Feedback
        if isCapture {
            playCaptureFeedback()
        } else {
            playMoveFeedback()
        }
    }
    
    // MARK: - Promotion Handling
    func completePromotion(type: PieceType) {
        guard let pending = pendingPromotion else { return }
        
        if let move = legalMovesForSelected.first(where: { $0.to == pending.to && $0.promotionType == type }) {
            executeMove(move)
        }
        
        pendingPromotion = nil
        clearSelection()
    }
    
    func cancelPromotion() {
        pendingPromotion = nil
        clearSelection()
    }
    
    // MARK: - Actions (Undo, Reset, Resign, Draw)
    func undoMove() {
        guard !moveHistory.isEmpty else { return }
        engine.undoMove()
        clearSelection()
        syncFromEngine()
        playMoveFeedback()
    }
    
    func restartGame() {
        stopTimer()
        engine.resetGame()
        clearSelection()
        syncFromEngine()
        setupTimers()
        playMoveFeedback()
    }
    
    func resign(player: PieceColor) {
        guard !gameStatus.isGameOver else { return }
        stopTimer()
        gameStatus = .resignation(winner: player.opposite)
        showGameOverAlert = true
        playGameOverFeedback()
    }
    
    func agreeDraw() {
        guard !gameStatus.isGameOver else { return }
        stopTimer()
        gameStatus = .drawAgreed
        showGameOverAlert = true
        playGameOverFeedback()
    }
    
    func toggleBoardFlip() {
        boardFlipped.toggle()
        playSelectionFeedback()
    }
    
    // Perspective helper: Should board be viewed flipped?
    var isBoardVisuallyFlipped: Bool {
        if boardFlipped {
            return true
        }
        if autoRotateBoard && currentTurn == .black {
            return true
        }
        return false
    }
    
    // Player on top of the screen (far side)
    var topPlayerColor: PieceColor {
        isBoardVisuallyFlipped ? .white : .black
    }
    
    // Player on bottom of the screen (near / front side)
    var bottomPlayerColor: PieceColor {
        isBoardVisuallyFlipped ? .black : .white
    }
    
    func timeRemaining(for color: PieceColor) -> TimeInterval {
        color == .white ? whiteTimeRemaining : blackTimeRemaining
    }
    
    func capturedPieces(by color: PieceColor) -> [ChessPiece] {
        color == .white ? capturedByWhite : capturedByBlack
    }
    
    func materialAdvantage(for color: PieceColor) -> Int {
        color == .white ? materialAdvantage : -materialAdvantage
    }
    
    // King currently in check position (for highlight)
    var kingInCheckSquare: Square? {
        if case .active(let turn, let isCheck) = gameStatus, isCheck {
            return engine.findKing(color: turn)
        }
        return nil
    }
    
    // MARK: - Feedback & Sounds
    private func playSelectionFeedback() {
        guard soundHapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func playMoveFeedback() {
        guard soundHapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        AudioServicesPlaySystemSound(1104) // subtle click sound
    }
    
    private func playCaptureFeedback() {
        guard soundHapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        AudioServicesPlaySystemSound(1057) // alert sound
    }
    
    private func playCheckFeedback() {
        guard soundHapticsEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    private func playGameOverFeedback() {
        guard soundHapticsEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
