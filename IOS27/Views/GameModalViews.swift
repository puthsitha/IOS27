import SwiftUI

// MARK: - Pawn Promotion Modal Sheet
struct PawnPromotionSheet: View {
    let color: PieceColor
    var language: AppLanguage = .english
    let onSelect: (PieceType) -> Void
    let onCancel: () -> Void
    
    private let pieces: [PieceType] = [.queen, .rook, .bishop, .knight]
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 6) {
                Text(LocalizedStrings.promotePawn(in: language))
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(LocalizedStrings.choosePromotionPiece(in: language))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 16) {
                ForEach(pieces, id: \.self) { pieceType in
                    Button {
                        onSelect(pieceType)
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color(UIColor.secondarySystemBackground))
                                    .frame(width: 66, height: 66)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                
                                Text(pieceType.glyph(color: color))
                                    .font(.system(size: 44, weight: .bold))
                                    .foregroundColor(color == .white ? Color(red: 252/255, green: 248/255, blue: 240/255) : Color(white: 0.15))
                                    .shadow(color: color == .white ? Color.black.opacity(0.65) : Color.clear, radius: 1, x: 0, y: 0.5)
                            }
                            
                            Text(LocalizedStrings.pieceName(pieceType, in: language))
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
            
            Button {
                onCancel()
            } label: {
                Text(LocalizedStrings.cancel(in: language))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.35), radius: 30, x: 0, y: 15)
        )
        .padding(.horizontal, 24)
    }
}

// MARK: - Game Over Overlay Banner
struct GameOverOverlayView: View {
    let status: GameStatus
    var language: AppLanguage = .english
    let onRestart: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Trophy / Outcome Emblem
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.9), Color.orange.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 68, height: 68)
                        .shadow(color: Color.orange.opacity(0.4), radius: 10, x: 0, y: 4)
                    
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }
                .padding(.top, 8)
                
                VStack(spacing: 8) {
                    Text(LocalizedStrings.statusTitle(status: status, in: language))
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                
                // Rematch Action Button
                HStack(spacing: 12) {
                    Button {
                        onRestart()
                    } label: {
                        Text(LocalizedStrings.rematch(in: language))
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 8)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: Color.black.opacity(0.3), radius: 25, x: 0, y: 10)
            )
            .padding(24)
        }
    }
}

// MARK: - Settings Sheet View
struct SettingsSheetView: View {
    @Bindable var viewModel: ChessGameViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                // App Branding
                Section {
                    HStack(spacing: 14) {
                        if let _ = UIImage(named: "LaunchLogo") {
                            Image("LaunchLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Chess Offline")
                                .font(.headline)
                                .fontWeight(.heavy)
                            Text(LocalizedStrings.appEdition(in: viewModel.language))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                }
                
                // Language Setting (Khmer / English toggle)
                Section(header: Text(LocalizedStrings.languageSection(in: viewModel.language))) {
                    Picker("Language", selection: $viewModel.language) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text("\(lang.flag)  \(lang.displayName)").tag(lang)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // App Theme Setting (Dark, Light, System)
                Section(
                    header: Text(LocalizedStrings.appThemeSection(in: viewModel.language)),
                    footer: Text(LocalizedStrings.themeFooter(in: viewModel.language))
                ) {
                    Picker("Appearance", selection: $viewModel.appTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Label(theme.localizedName(in: viewModel.language), systemImage: theme.iconName).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Layout Mode
                Section(
                    header: Text(LocalizedStrings.twoPlayerModeSection(in: viewModel.language)),
                    footer: Text(LocalizedStrings.layoutDescription(mode: viewModel.layoutMode, in: viewModel.language))
                ) {
                    Picker(LocalizedStrings.tableOrientation(in: viewModel.language), selection: $viewModel.layoutMode) {
                        Text(LocalizedStrings.faceToFace(in: viewModel.language)).tag(TwoPlayerLayoutMode.faceToFace)
                        Text(LocalizedStrings.passAndPlay(in: viewModel.language)).tag(TwoPlayerLayoutMode.passAndPlay)
                    }
                    .pickerStyle(.segmented)
                    
                    if viewModel.layoutMode == .passAndPlay {
                        Toggle(LocalizedStrings.autoRotateBoard(in: viewModel.language), isOn: $viewModel.autoRotateBoard)
                    }
                }
                
                // Time Control
                Section(header: Text(LocalizedStrings.timeControlSection(in: viewModel.language))) {
                    Picker(LocalizedStrings.timerLabel(in: viewModel.language), selection: $viewModel.timeControl) {
                        ForEach(TimeControl.allCases) { control in
                            Text(LocalizedStrings.timeControlName(control, in: viewModel.language)).tag(control)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Board Theme
                Section(header: Text(LocalizedStrings.boardThemeSection(in: viewModel.language))) {
                    ForEach(BoardTheme.allCases) { theme in
                        HStack {
                            // Mini square preview
                            HStack(spacing: 0) {
                                Rectangle().fill(theme.lightSquareColor).frame(width: 14, height: 14)
                                Rectangle().fill(theme.darkSquareColor).frame(width: 14, height: 14)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            
                            Text(LocalizedStrings.boardThemeName(theme, in: viewModel.language))
                            
                            Spacer()
                            
                            if viewModel.boardTheme == theme {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.boardTheme = theme
                        }
                    }
                }
                
                // Gameplay Assistance & Audio
                Section(header: Text(LocalizedStrings.gameplayPreferencesSection(in: viewModel.language))) {
                    Toggle(LocalizedStrings.showLegalMoveDots(in: viewModel.language), isOn: $viewModel.showLegalMoveHints)
                    Toggle(LocalizedStrings.hapticSoundEffects(in: viewModel.language), isOn: $viewModel.soundHapticsEnabled)
                }
            }
            .navigationTitle(LocalizedStrings.gameSettings(in: viewModel.language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStrings.done(in: viewModel.language)) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Move History Sheet View
struct MoveHistorySheetView: View {
    let moves: [ChessMove]
    var language: AppLanguage = .english
    @Environment(\.dismiss) private var dismiss
    
    // Group moves into pairs (White move, Black move)
    private var movePairs: [(turnNumber: Int, whiteMove: ChessMove?, blackMove: ChessMove?)] {
        var pairs: [(Int, ChessMove?, ChessMove?)] = []
        var i = 0
        var turn = 1
        while i < moves.count {
            let white = moves[i]
            let black = (i + 1 < moves.count) ? moves[i + 1] : nil
            pairs.append((turn, white, black))
            i += 2
            turn += 1
        }
        return pairs
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if moves.isEmpty {
                    ContentUnavailableView(
                        LocalizedStrings.noMovesYet(in: language),
                        systemImage: "list.bullet.rectangle.portrait",
                        description: Text(language == .khmer ? "ការដើរទាំងអស់នឹងត្រូវបានកត់ត្រានៅទីនេះ។" : "Moves played during the game will be recorded here.")
                    )
                } else {
                    List {
                        Section(header: HStack {
                            Text("#")
                                .frame(width: 32, alignment: .leading)
                            Text(LocalizedStrings.colorName(.white, in: language))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(LocalizedStrings.colorName(.black, in: language))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }) {
                            ForEach(movePairs, id: \.turnNumber) { pair in
                                HStack {
                                    Text("\(pair.turnNumber).")
                                        .font(.system(.subheadline, design: .monospaced))
                                        .foregroundColor(.secondary)
                                        .frame(width: 32, alignment: .leading)
                                    
                                    if let w = pair.whiteMove {
                                        Text(w.san)
                                            .font(.system(.subheadline, design: .monospaced, weight: .bold))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    } else {
                                        Text("—")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    
                                    if let b = pair.blackMove {
                                        Text(b.san)
                                            .font(.system(.subheadline, design: .monospaced, weight: .bold))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    } else {
                                        Text("—")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle(LocalizedStrings.moveHistory(in: language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStrings.done(in: language)) {
                        dismiss()
                    }
                }
            }
        }
    }
}
