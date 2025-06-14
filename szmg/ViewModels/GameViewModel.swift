//
//  GameViewModel.swift
//  badx T DM
//
//  Created by AI Assistant on 2025/1/10.
//

import Foundation
import Combine
import UIKit

class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var gameState: GameState
    @Published var selectedPosition: Position?
    @Published var isShowingHint: Bool = false
    @Published var showingAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showingPauseMenu: Bool = false
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let soundManager = SoundManager.shared
    
    // MARK: - Initialization
    init(gameMode: GameMode, difficulty: DifficultyLevel, level: Int = 1) {
        self.gameState = GameState(gameMode: gameMode, difficulty: difficulty, level: level)
        setupBindings()
        generateMaze()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Listen to game state changes
        gameState.$status
            .sink { [weak self] status in
                self?.handleGameStatusChange(status)
            }
            .store(in: &cancellables)
        
        // Listen to time changes for challenge mode
        gameState.$timeRemaining
            .sink { [weak self] timeRemaining in
                if timeRemaining <= 10 && timeRemaining > 0 {
                    // Play warning sound when time is running out
                    self?.soundManager.playSound(.wrongMove)
                }
            }
            .store(in: &cancellables)
    }
    
    private func generateMaze() {
        let maze: Maze

        switch gameState.gameMode {
        case .classic:
            maze = MazeGenerator.generatePresetLevel(gameState.currentLevel, difficulty: gameState.difficulty)
        case .daily:
            maze = MazeGenerator.generateDailyChallenge()
        case .challenge:
            maze = MazeGenerator.generateMaze(difficulty: gameState.difficulty, level: gameState.currentLevel)
        }

        gameState.maze = maze
        gameState.path = GamePath(maxNumber: gameState.difficulty.maxNumber)
    }
    
    // MARK: - Game Control
    func startGame() {
        gameState.startGame()
        soundManager.playGameSounds()
    }
    
    func pauseGame() {
        gameState.pauseGame()
        showingPauseMenu = true
        soundManager.pauseBackgroundMusic()
    }
    
    func resumeGame() {
        gameState.resumeGame()
        showingPauseMenu = false
        soundManager.resumeBackgroundMusic()
    }
    
    func restartGame() {
        gameState.restartGame()
        generateMaze()
        selectedPosition = nil
        clearHints()
        showingPauseMenu = false
    }
    
    func nextLevel() {
        gameState.currentLevel += 1
        restartGame()
    }
    
    // MARK: - Move Handling
    func handleCellTap(at position: Position) {
        guard gameState.canMakeMove() else { return }
        
        soundManager.playUISound()
        
        // Clear any existing hints
        clearHints()
        
        guard let cell = gameState.maze.cell(at: position) else { return }
        
        // Handle numbered cell selection
        if cell.isNumbered {
            handleNumberedCellTap(at: position, number: cell.number!)
        } else {
            // Clear selection if tapping empty cell
            selectedPosition = nil
            gameState.maze.clearSelections()
        }
    }
    
    private func handleNumberedCellTap(at position: Position, number: Int) {
        let requiredNumber = gameState.getNextRequiredNumber()
        
        // If this is the next required number
        if number == requiredNumber {
            if let selectedPos = selectedPosition {
                // Try to make a move from selected position to this position
                attemptMove(from: selectedPos, to: position)
            } else {
                // Select this position as starting point
                selectPosition(position)
            }
        } else if number == requiredNumber - 1 {
            // Allow selecting the previous number to continue from there
            selectPosition(position)
        } else {
            // Invalid selection
            showAlert(title: "Invalid Move", message: "You need to connect to number \(requiredNumber) next.")
            soundManager.playSound(.wrongMove)
        }
    }
    
    private func selectPosition(_ position: Position) {
        selectedPosition = position
        gameState.maze.clearSelections()
        gameState.maze.selectCell(at: position)
    }
    
    private func attemptMove(from fromPosition: Position, to toPosition: Position) {
        let success = gameState.makeMove(from: fromPosition, to: toPosition)
        
        if success {
            soundManager.playMoveSound(isCorrect: true)
            selectedPosition = toPosition
            gameState.maze.clearSelections()
            gameState.maze.selectCell(at: toPosition)
        } else {
            soundManager.playMoveSound(isCorrect: false)
            showAlert(title: "Invalid Move", message: "You can only connect adjacent numbers in sequence.")
        }
    }
    
    // MARK: - Game Actions
    func useHint() {
        guard gameState.hintsRemaining > 0 else {
            showAlert(title: "No Hints", message: "You have no hints remaining.")
            return
        }
        
        if let hintPosition = gameState.useHint() {
            isShowingHint = true
            soundManager.playHintSound()
            
            // Auto-hide hint after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.clearHints()
            }
        } else {
            showAlert(title: "No Hint Available", message: "Cannot provide hint at this time.")
        }
    }
    
    func undoLastMove() {
        if gameState.undoLastMove() {
            soundManager.playUndoSound()
            
            // Update selection to the new last position
            if let lastPosition = gameState.path.getLastPosition() {
                selectedPosition = lastPosition
                gameState.maze.clearSelections()
                gameState.maze.selectCell(at: lastPosition)
            } else {
                selectedPosition = nil
                gameState.maze.clearSelections()
            }
        } else {
            showAlert(title: "Cannot Undo", message: "No moves to undo.")
        }
    }
    
    private func clearHints() {
        isShowingHint = false
        gameState.maze.clearHighlights()
    }
    
    // MARK: - Game Status Handling
    private func handleGameStatusChange(_ status: GameStatus) {
        switch status {
        case .completed:
            soundManager.playVictorySound()
            // Note: Alert display is handled by GameViewController

        case .failed:
            soundManager.playGameOverSound()
            // Note: Alert display is handled by GameViewController

        case .timeUp:
            soundManager.playGameOverSound()
            // Note: Alert display is handled by GameViewController

        default:
            break
        }
    }
    
    // MARK: - Alert Management
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }

    // MARK: - Cleanup
    func cancelAllBindings() {
        print("🧹 GameViewModel: Cancelling all Combine bindings")
        cancellables.removeAll()
    }
    
    // MARK: - Game Information
    func getCellColor(for position: Position) -> UIColor {
        guard let cell = gameState.maze.cell(at: position) else { return .gray }

        if cell.isHighlighted {
            return .systemYellow
        }

        if cell.isSelected {
            return .systemBlue
        }

        if gameState.isPositionInPath(position) {
            return .systemGreen
        }

        switch cell.type {
        case .numbered(_):
            return UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
        case .obstacle:
            return .black
        case .empty:
            return .white
        case .path:
            return .systemGreen
        }
    }
    
    func getCellText(for position: Position) -> String {
        guard let cell = gameState.maze.cell(at: position) else { return "" }
        
        if let number = cell.number {
            return "\(number)"
        }
        
        return ""
    }
    
    func shouldShowNumber(at position: Position) -> Bool {
        guard let cell = gameState.maze.cell(at: position) else { return false }
        return cell.isNumbered
    }
    
    func isObstacle(at position: Position) -> Bool {
        guard let cell = gameState.maze.cell(at: position) else { return false }
        return cell.type == .obstacle
    }
    
    // MARK: - Statistics
    func getAccuracy() -> Double {
        guard gameState.totalMoves > 0 else { return 0.0 }
        return Double(gameState.correctMoves) / Double(gameState.totalMoves)
    }
    
    func getProgressPercentage() -> Double {
        let currentNumber = gameState.getNextRequiredNumber()
        let maxNumber = gameState.difficulty.maxNumber
        return Double(currentNumber - 1) / Double(maxNumber)
    }
}
