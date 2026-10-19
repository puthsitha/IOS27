import SwiftUI

// MARK: - App Language
enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case english = "en"
    case khmer = "km"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .khmer: return "ភាសាខ្មែរ"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .khmer: return "🇰🇭"
        }
    }
}

// MARK: - App Theme (Dark / Light / System)
enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil // Follows device system settings
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    func localizedName(in language: AppLanguage) -> String {
        switch (self, language) {
        case (.system, .english): return "System"
        case (.system, .khmer): return "តាមប្រព័ន្ធ"
        case (.light, .english): return "Light"
        case (.light, .khmer): return "ពន្លឺ"
        case (.dark, .english): return "Dark"
        case (.dark, .khmer): return "ងងឹត"
        }
    }
    
    var iconName: String {
        switch self {
        case .system: return "circle.righthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

// MARK: - Localized Strings Helper
enum LocalizedStrings {
    // Piece Colors
    static func colorName(_ color: PieceColor, in language: AppLanguage) -> String {
        switch (color, language) {
        case (.white, .english): return "White"
        case (.white, .khmer): return "ស"
        case (.black, .english): return "Black"
        case (.black, .khmer): return "ខ្មៅ"
        }
    }
    
    // Piece Types
    static func pieceName(_ type: PieceType, in language: AppLanguage) -> String {
        switch (type, language) {
        case (.king, .english): return "King"
        case (.king, .khmer): return "ស្តេច"
        case (.queen, .english): return "Queen"
        case (.queen, .khmer): return "នាង"
        case (.rook, .english): return "Rook"
        case (.rook, .khmer): return "ទូក"
        case (.bishop, .english): return "Bishop"
        case (.bishop, .khmer): return "គោល"
        case (.knight, .english): return "Knight"
        case (.knight, .khmer): return "សេះ"
        case (.pawn, .english): return "Pawn"
        case (.pawn, .khmer): return "កូន"
        }
    }
    
    // HUD
    static func toMove(in language: AppLanguage) -> String {
        language == .khmer ? "វេនដើរ" : "TO MOVE"
    }
    
    static func checkWarning(color: PieceColor, in language: AppLanguage) -> String {
        let name = colorName(color, in: language)
        return language == .khmer ? "ស្តេច\(name) ជាប់អុក!" : "\(name) King is in Check!"
    }
    
    // Game Controls Bar
    static func undo(in language: AppLanguage) -> String {
        language == .khmer ? "ថយក្រោយ" : "Undo"
    }
    
    static func flip(in language: AppLanguage) -> String {
        language == .khmer ? "បង្វិល" : "Flip"
    }
    
    static func moves(count: Int, in language: AppLanguage) -> String {
        language == .khmer ? "ដើរ (\(count))" : "Moves (\(count))"
    }
    
    static func actions(in language: AppLanguage) -> String {
        language == .khmer ? "សកម្មភាព" : "Actions"
    }
    
    static func settings(in language: AppLanguage) -> String {
        language == .khmer ? "ការកំណត់" : "Settings"
    }
    
    // Actions Menu
    static func resignAction(color: PieceColor, in language: AppLanguage) -> String {
        let name = colorName(color, in: language)
        return language == .khmer ? "សុំចុះចាញ់ (\(name))" : "Resign (\(name))"
    }
    
    static func offerDraw(in language: AppLanguage) -> String {
        language == .khmer ? "ស្នើសុំស្មើ" : "Offer Mutual Draw"
    }
    
    static func restartGame(in language: AppLanguage) -> String {
        language == .khmer ? "ចាប់ផ្តើមឡើងវិញ" : "Restart Game"
    }
    
    static func cancel(in language: AppLanguage) -> String {
        language == .khmer ? "បោះបង់" : "Cancel"
    }
    
    // Alerts & Confirmations
    static func resignTitle(color: PieceColor, in language: AppLanguage) -> String {
        let name = colorName(color, in: language)
        return language == .khmer ? "សុំចុះចាញ់?" : "Resign Game?"
    }
    
    static func resignMessage(color: PieceColor, in language: AppLanguage) -> String {
        let name = colorName(color, in: language)
        let opposite = colorName(color.opposite, in: language)
        return language == .khmer ? "តើអ្នកប្រាកដជាចង់ចុះចាញ់សម្រាប់ខាង \(name)? ខាង \(opposite) នឹងទទួលបានជ័យជម្នះ។" : "Are you sure \(name) wants to resign? \(opposite) will be declared the winner."
    }
    
    static func drawTitle(in language: AppLanguage) -> String {
        language == .khmer ? "ស្នើសុំស្មើ?" : "Offer Draw?"
    }
    
    static func drawMessage(in language: AppLanguage) -> String {
        language == .khmer ? "តើអ្នកលេងទាំងសងខាងព្រមព្រៀងបញ្ចប់ការប្រកួតដោយលទ្ធផលស្មើឬទេ?" : "Do both players agree to end this match in an honorable draw?"
    }
    
    static func acceptDraw(in language: AppLanguage) -> String {
        language == .khmer ? "យល់ព្រមស្មើ" : "Accept Draw"
    }
    
    static func restartTitle(in language: AppLanguage) -> String {
        language == .khmer ? "ចាប់ផ្តើមល្បែងឡើងវិញ?" : "Restart Game?"
    }
    
    static func restartMessage(in language: AppLanguage) -> String {
        language == .khmer ? "ការដើរ និងនាឡិកាទាំងអស់នឹងត្រូវកំណត់ឡើងវិញ។" : "All current moves, clocks, and captured pieces will be reset."
    }
    
    // Game Over Sheet
    static func rematch(in language: AppLanguage) -> String {
        language == .khmer ? "លេងម្ដងទៀត" : "Rematch"
    }
    
    static func newGame(in language: AppLanguage) -> String {
        language == .khmer ? "ល្បែងថ្មី" : "New Game"
    }
    
    static func statusTitle(status: GameStatus, in language: AppLanguage) -> String {
        switch status {
        case .active(_, let isCheck):
            if isCheck {
                return language == .khmer ? "អុក!" : "Check!"
            }
            return language == .khmer ? "កំពុងលេង" : "In Progress"
        case .checkmate(let winner):
            let name = colorName(winner, in: language)
            return language == .khmer ? "អុកស្លាប់! ខាង \(name) ឈ្នះ!" : "Checkmate! \(name) Wins!"
        case .stalemate:
            return language == .khmer ? "ស្មើដោយទាល់ (Stalemate)" : "Draw by Stalemate"
        case .resignation(let winner):
            let name = colorName(winner, in: language)
            return language == .khmer ? "ខាង \(name) ឈ្នះដោយសារគូប្រកួតចុះចាញ់" : "\(name) Wins by Resignation"
        case .timeout(let winner):
            let name = colorName(winner, in: language)
            return language == .khmer ? "ខាង \(name) ឈ្នះដោយសារគូប្រកួតអស់ម៉ោង" : "\(name) Wins on Time"
        case .drawAgreed:
            return language == .khmer ? "ស្មើដោយការព្រមព្រៀងគ្នា" : "Draw by Mutual Agreement"
        }
    }
    
    // Pawn Promotion
    static func promotePawn(in language: AppLanguage) -> String {
        language == .khmer ? "ដំឡើងស័ក្តិកូនអុក" : "Promote Pawn"
    }
    
    static func choosePromotionPiece(in language: AppLanguage) -> String {
        language == .khmer ? "ជ្រើសរើសកូនអុកថ្មីដើម្បីដំឡើងស័ក្តិ" : "Choose a piece to replace your pawn"
    }
    
    // Move History
    static func moveHistory(in language: AppLanguage) -> String {
        language == .khmer ? "ប្រវត្តិដើរអុក" : "Move History"
    }
    
    static func noMovesYet(in language: AppLanguage) -> String {
        language == .khmer ? "មិនទាន់មានការដើរនៅឡើយទេ" : "No moves played yet"
    }
    
    static func close(in language: AppLanguage) -> String {
        language == .khmer ? "បិទ" : "Close"
    }
    
    static func done(in language: AppLanguage) -> String {
        language == .khmer ? "រួចរាល់" : "Done"
    }
    
    // Settings Sections & Items
    static func gameSettings(in language: AppLanguage) -> String {
        language == .khmer ? "ការកំណត់ល្បែង" : "Game Settings"
    }
    
    static func languageSection(in language: AppLanguage) -> String {
        language == .khmer ? "ភាសា / Language" : "Language"
    }
    
    static func appThemeSection(in language: AppLanguage) -> String {
        language == .khmer ? "រូបរាងកម្មវិធី (Theme)" : "Appearance"
    }
    
    static func themeFooter(in language: AppLanguage) -> String {
        language == .khmer ? "ជ្រើសរើសរបៀបពន្លឺ ងងឹត ឬផ្លាស់ប្តូរស្វ័យប្រវត្តិតាមការកំណត់ប្រព័ន្ធទូរស័ព្ទ" : "Choose Light, Dark, or follow the system device appearance automatically."
    }
    
    static func twoPlayerModeSection(in language: AppLanguage) -> String {
        language == .khmer ? "របៀបអ្នកលេង ២នាក់" : "Two-Player Mode"
    }
    
    static func tableOrientation(in language: AppLanguage) -> String {
        language == .khmer ? "ទិសដៅក្តារ" : "Table Orientation"
    }
    
    static func faceToFace(in language: AppLanguage) -> String {
        language == .khmer ? "ទល់មុខគ្នា" : "Face to Face"
    }
    
    static func passAndPlay(in language: AppLanguage) -> String {
        language == .khmer ? "ហុចលេងប្តូរវេន" : "Pass & Play"
    }
    
    static func layoutDescription(mode: TwoPlayerLayoutMode, in language: AppLanguage) -> String {
        switch (mode, language) {
        case (.faceToFace, .english):
            return "Black HUD is rotated 180° for two players sitting across each other"
        case (.faceToFace, .khmer):
            return "ផ្ទៃពត៌មានខាងលើត្រូវបានបង្វិល ១៨០° សម្រាប់អ្នកលេងអង្គុយទល់មុខគ្នា"
        case (.passAndPlay, .english):
            return "Both players view from standard orientation, with optional auto-rotation"
        case (.passAndPlay, .khmer):
            return "អ្នកលេងទាំងពីរមើលទិសដៅធម្មតា ជាមួយមុខងារបង្វិលក្តារស្វ័យប្រវត្តិ"
        }
    }
    
    static func autoRotateBoard(in language: AppLanguage) -> String {
        language == .khmer ? "បង្វិលក្តារស្វ័យប្រវត្តិតាមវេន" : "Auto-Rotate Board on Turn"
    }
    
    static func timeControlSection(in language: AppLanguage) -> String {
        language == .khmer ? "កំណត់ពេលវេលា" : "Time Control"
    }
    
    static func timerLabel(in language: AppLanguage) -> String {
        language == .khmer ? "នាឡិកា" : "Timer"
    }
    
    static func timeControlName(_ control: TimeControl, in language: AppLanguage) -> String {
        switch (control, language) {
        case (.unlimited, .khmer): return "គ្មានកំណត់ពេល"
        case (.unlimited, .english): return "No Timer"
        case (.blitz3, .khmer): return "៣ នាទី (Blitz)"
        case (.blitz3, .english): return "3 min"
        case (.blitz5, .khmer): return "៥ នាទី (Blitz)"
        case (.blitz5, .english): return "5 min"
        case (.rapid10, .khmer): return "១០ នាទី (Rapid)"
        case (.rapid10, .english): return "10 min"
        case (.rapid15, .khmer): return "១៥ នាទី (Rapid)"
        case (.rapid15, .english): return "15 min"
        case (.classical30, .khmer): return "៣០ នាទី (Classical)"
        case (.classical30, .english): return "30 min"
        }
    }
    
    static func boardThemeSection(in language: AppLanguage) -> String {
        language == .khmer ? "ស្បែកក្តារអុក" : "Board Theme"
    }
    
    static func boardThemeName(_ theme: BoardTheme, in language: AppLanguage) -> String {
        switch (theme, language) {
        case (.classicWood, .khmer): return "ឈើបុរាណ"
        case (.classicWood, .english): return "Classic Wood"
        case (.emerald, .khmer): return "ត្បូងមរកត"
        case (.emerald, .english): return "Tournament Emerald"
        case (.slate, .khmer): return "ថ្មក្រានីតទំនើប"
        case (.slate, .english): return "Modern Slate"
        case (.ocean, .khmer): return "សមុទ្រជ្រៅ"
        case (.ocean, .english): return "Deep Ocean"
        }
    }
    
    static func gameplayPreferencesSection(in language: AppLanguage) -> String {
        language == .khmer ? "ការកំណត់ការលេង" : "Gameplay Preferences"
    }
    
    static func showLegalMoveDots(in language: AppLanguage) -> String {
        language == .khmer ? "បង្ហាញចំណុចជំនួយការដើរ" : "Show Legal Move Dots"
    }
    
    static func hapticSoundEffects(in language: AppLanguage) -> String {
        language == .khmer ? "សំឡេង និងរំញ័រ" : "Haptic & Sound Effects"
    }
    
    static func appEdition(in language: AppLanguage) -> String {
        language == .khmer ? "អុកចត្រង្គ - អ្នកលេង ២នាក់ក្រៅបណ្ដាញ" : "Offline Two-Player Edition"
    }
    
    static func launchSubtitle(in language: AppLanguage) -> String {
        language == .khmer ? "អ្នកលេង ២នាក់ក្រៅបណ្ដាញ" : "TWO-PLAYER OFFLINE"
    }
    
    static func tapToBegin(in language: AppLanguage) -> String {
        language == .khmer ? "ចុចទីណាក៏បានដើម្បីចាប់ផ្ដើម" : "Tap anywhere to begin"
    }
}
