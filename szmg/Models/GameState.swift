//
//  GameState.swift
//  badx T DM
//
//  Created by AI Assistant on 2025/1/10.
//

import Foundation
import Combine

// MARK: - Game Status
enum GameStatus {
    case notStarted
    case playing
    case paused
    case completed
    case failed
    case timeUp
}

// MARK: - Game State
class GameState: ObservableObject {
    // MARK: - Published Properties
    @Published var maze: Maze
    @Published var path: GamePath
    @Published var status: GameStatus = .notStarted
    @Published var currentLevel: Int = 1
    @Published var score: Int = 0
    @Published var hintsRemaining: Int = 3
    @Published var timeRemaining: TimeInterval = 0
    @Published var isTimerActive: Bool = false
    
    // MARK: - Game Configuration
    let gameMode: GameMode
    let difficulty: DifficultyLevel
    private var timer: Timer?
    private var startTime: Date?
    
    // MARK: - Statistics
    @Published var totalMoves: Int = 0
    @Published var correctMoves: Int = 0
    @Published var wrongMoves: Int = 0
    @Published var hintsUsed: Int = 0
    
    // MARK: - Initialization
    init(gameMode: GameMode, difficulty: DifficultyLevel, level: Int = 1) {
        self.gameMode = gameMode
        self.difficulty = difficulty
        self.currentLevel = level
        
        self.maze = Maze(size: difficulty.gridSize, difficulty: difficulty)
        self.path = GamePath(maxNumber: difficulty.maxNumber)
        
        if gameMode.hasTimeLimit {
            self.timeRemaining = TimeInterval(gameMode.timeLimitSeconds)
        }
        
        setupGame()
    }
    
    // MARK: - Game Setup
    private func setupGame() {
        // Reset statistics
        totalMoves = 0
        correctMoves = 0
        wrongMoves = 0
        hintsUsed = 0
        score = 0
        
        // Reset hints
        hintsRemaining = 3
        
        // Reset timer
        if gameMode.hasTimeLimit {
            timeRemaining = TimeInterval(gameMode.timeLimitSeconds)
        }
    }
    
    // MARK: - Game Control
    func startGame() {
        guard status == .notStarted || status == .failed else { return }
        
        status = .playing
        startTime = Date()
        
        if gameMode.hasTimeLimit {
            startTimer()
        }
    }
    
    func pauseGame() {
        guard status == .playing else { return }
        status = .paused
        stopTimer()
    }
    
    func resumeGame() {
        guard status == .paused else { return }
        status = .playing
        
        if gameMode.hasTimeLimit {
            startTimer()
        }
    }
    
    func restartGame() {
        stopTimer()
        path.clear()
        maze.clearAllPaths()
        maze.clearHighlights()
        maze.clearSelections()
        setupGame()
        status = .notStarted
    }
    
    func completeGame() {
        status = .completed
        stopTimer()
        calculateFinalScore()
        saveProgress()
    }
    
    func failGame() {
        status = .failed
        stopTimer()
    }
    
    // MARK: - Timer Management
    private func startTimer() {
        guard gameMode.hasTimeLimit else { return }
        
        isTimerActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerActive = false
    }
    
    private func updateTimer() {
        guard timeRemaining > 0 else {
            status = .timeUp
            stopTimer()
            return
        }
        
        timeRemaining -= 1
    }
    
    // MARK: - Move Management
    func makeMove(from fromPosition: Position, to toPosition: Position) -> Bool {
        guard status == .playing else { return false }

        totalMoves += 1

        // Get the numbers at these positions
        guard let fromCell = maze.cell(at: fromPosition),
              let toCell = maze.cell(at: toPosition),
              let fromNumber = fromCell.number,
              let toNumber = toCell.number else {
            wrongMoves += 1
            return false
        }

        // Create connection
        let connection = PathConnection(from: fromPosition, to: toPosition,
                                      fromNumber: fromNumber, toNumber: toNumber)

        // Try to add connection to path
        if path.addConnection(connection) {
            correctMoves += 1
            maze.setPath(at: fromPosition) // Mark from position as part of path
            maze.setPath(at: toPosition)   // Mark to position as part of path

            // Check if game is complete
            if path.isComplete() {
                completeGame()
            }

            return true
        } else {
            wrongMoves += 1
            return false
        }
    }

    func startPath(at position: Position) -> Bool {
        guard status == .playing else { return false }

        // Get the number at this position
        guard let cell = maze.cell(at: position),
              let number = cell.number else {
            return false
        }

        // Try to start path
        if path.startPath(at: position, withNumber: number) {
            maze.setPath(at: position)
            return true
        } else {
            return false
        }
    }
    
    func undoLastMove() -> Bool {
        guard status == .playing else { return false }
        guard let lastConnection = path.removeLastConnection() else { return false }
        
        maze.clearPath(at: lastConnection.to)
        return true
    }
    
    // MARK: - Hint System
    func useHint() -> Position? {
        guard status == .playing else { return nil }
        guard hintsRemaining > 0 else { return nil }
        
        hintsRemaining -= 1
        hintsUsed += 1
        
        // Get hint position
        let hintPosition = path.getHintForNextMove(in: maze)
        
        // Highlight the hint
        if let position = hintPosition {
            maze.clearHighlights()
            maze.highlightCell(at: position)
        }
        
        return hintPosition
    }
    
    // MARK: - Score Calculation
    private func calculateFinalScore() {
        let elapsedTime = startTime?.timeIntervalSinceNow ?? 0
        let statistics = PathStatistics(
            totalMoves: totalMoves,
            correctMoves: correctMoves,
            wrongMoves: wrongMoves,
            hintsUsed: hintsUsed,
            timeElapsed: abs(elapsedTime)
        )
        
        score = statistics.score
    }
    
    // MARK: - Progress Management
    private func saveProgress() {
        let userDefaults = UserDefaults.standard
        
        // Save level progress
        let currentProgress = userDefaults.integer(forKey: "maxLevel_\(difficulty.rawValue)")
        if currentLevel >= currentProgress {
            userDefaults.set(currentLevel + 1, forKey: "maxLevel_\(difficulty.rawValue)")
        }
        
        // Save high score
        let currentHighScore = userDefaults.integer(forKey: "highScore_\(difficulty.rawValue)")
        if score > currentHighScore {
            userDefaults.set(score, forKey: "highScore_\(difficulty.rawValue)")
        }
        
        // Save statistics
        let totalGames = userDefaults.integer(forKey: "totalGames_\(difficulty.rawValue)") + 1
        userDefaults.set(totalGames, forKey: "totalGames_\(difficulty.rawValue)")
        
        let totalScore = userDefaults.integer(forKey: "totalScore_\(difficulty.rawValue)") + score
        userDefaults.set(totalScore, forKey: "totalScore_\(difficulty.rawValue)")
    }
    
    // MARK: - Game Information
    func getElapsedTime() -> TimeInterval {
        guard let startTime = startTime else { return 0 }
        return abs(startTime.timeIntervalSinceNow)
    }
    
    func getFormattedTime() -> String {
        let time = gameMode.hasTimeLimit ? timeRemaining : getElapsedTime()
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func canMakeMove() -> Bool {
        return status == .playing
    }
    
    func getNextRequiredNumber() -> Int {
        return path.getNextRequiredNumber()
    }
    
    func isPositionInPath(_ position: Position) -> Bool {
        return path.isPositionInPath(position)
    }
}
