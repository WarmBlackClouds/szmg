//
//  LevelLoader.swift
//  Ddui Cdl puzzles
//
//  Created by AI Assistant on 2025/1/10.
//

import Foundation

// MARK: - Level Data Structures
struct LevelData: Codable {
    let level: Int
    let size: Int
    let numbers: [String: PositionData]
    let obstacles: [PositionData]
}

struct PositionData: Codable {
    let row: Int
    let col: Int
}

struct LevelsContainer: Codable {
    let easy_levels: [LevelData]
    let medium_levels: [LevelData]
    let hard_levels: [LevelData]
    let daily_challenges: [DailyChallengeData]
}

struct DailyChallengeData: Codable {
    let date: String
    let difficulty: String
    let size: Int
    let numbers: [String: PositionData]
    let obstacles: [PositionData]
}

// MARK: - Level Loader
class LevelLoader {
    static let shared = LevelLoader()
    
    private var levelsContainer: LevelsContainer?
    
    private init() {
        loadLevelsData()
    }
    
    // MARK: - Data Loading
    private func loadLevelsData() {
        guard let url = Bundle.main.url(forResource: "levels", withExtension: "json") else {
            print("Could not find levels.json file")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            levelsContainer = try JSONDecoder().decode(LevelsContainer.self, from: data)
            print("Successfully loaded levels data")
        } catch {
            print("Error loading levels data: \(error)")
        }
    }
    
    // MARK: - Level Loading
    func loadLevel(_ level: Int, difficulty: DifficultyLevel) -> Maze? {
        guard let container = levelsContainer else { return nil }
        
        let levelDataArray: [LevelData]
        switch difficulty {
        case .easy:
            levelDataArray = container.easy_levels
        case .medium:
            levelDataArray = container.medium_levels
        case .hard:
            levelDataArray = container.hard_levels
        }
        
        // Find the specific level or use the last available level as template
        let levelData = levelDataArray.first { $0.level == level } ?? levelDataArray.last
        
        guard let data = levelData else {
            // Fallback to generated maze
            return MazeGenerator.generateMaze(difficulty: difficulty, level: level)
        }
        
        return createMaze(from: data, difficulty: difficulty)
    }
    
    func loadDailyChallenge(for date: Date = Date()) -> Maze? {
        guard let container = levelsContainer else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        // Find challenge for specific date or use a default one
        let challengeData = container.daily_challenges.first { $0.date == dateString } ?? container.daily_challenges.first
        
        guard let data = challengeData else { return nil }
        
        let difficulty = DifficultyLevel(rawValue: data.difficulty.capitalized) ?? .medium
        return createMaze(from: data, difficulty: difficulty)
    }
    
    // MARK: - Maze Creation
    private func createMaze(from levelData: LevelData, difficulty: DifficultyLevel) -> Maze {
        let maze = Maze(size: levelData.size, difficulty: difficulty)
        
        // Place numbered cells
        for (numberString, positionData) in levelData.numbers {
            if let number = Int(numberString) {
                let position = Position(positionData.row, positionData.col)
                maze.setCell(at: position, type: .numbered(number))
            }
        }
        
        // Place obstacles
        for obstacleData in levelData.obstacles {
            let position = Position(obstacleData.row, obstacleData.col)
            maze.setCell(at: position, type: .obstacle)
        }
        
        return maze
    }
    
    private func createMaze(from challengeData: DailyChallengeData, difficulty: DifficultyLevel) -> Maze {
        let maze = Maze(size: challengeData.size, difficulty: difficulty)
        
        // Place numbered cells
        for (numberString, positionData) in challengeData.numbers {
            if let number = Int(numberString) {
                let position = Position(positionData.row, positionData.col)
                maze.setCell(at: position, type: .numbered(number))
            }
        }
        
        // Place obstacles
        for obstacleData in challengeData.obstacles {
            let position = Position(obstacleData.row, obstacleData.col)
            maze.setCell(at: position, type: .obstacle)
        }
        
        return maze
    }
    
    // MARK: - Level Information
    func getAvailableLevels(for difficulty: DifficultyLevel) -> Int {
        guard let container = levelsContainer else { return 0 }
        
        switch difficulty {
        case .easy:
            return container.easy_levels.count
        case .medium:
            return container.medium_levels.count
        case .hard:
            return container.hard_levels.count
        }
    }
    
    func hasDailyChallengeForDate(_ date: Date) -> Bool {
        guard let container = levelsContainer else { return false }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        return container.daily_challenges.contains { $0.date == dateString }
    }
    
    func getDailyChallengeInfo(for date: Date = Date()) -> (difficulty: DifficultyLevel, size: Int)? {
        guard let container = levelsContainer else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        guard let challengeData = container.daily_challenges.first(where: { $0.date == dateString }) else {
            return nil
        }
        
        let difficulty = DifficultyLevel(rawValue: challengeData.difficulty.capitalized) ?? .medium
        return (difficulty: difficulty, size: challengeData.size)
    }
    
    // MARK: - Level Validation
    func validateLevel(_ levelData: LevelData) -> Bool {
        // Check if all positions are within bounds
        for (_, positionData) in levelData.numbers {
            if positionData.row < 0 || positionData.row >= levelData.size ||
               positionData.col < 0 || positionData.col >= levelData.size {
                return false
            }
        }
        
        for obstacleData in levelData.obstacles {
            if obstacleData.row < 0 || obstacleData.row >= levelData.size ||
               obstacleData.col < 0 || obstacleData.col >= levelData.size {
                return false
            }
        }
        
        // Check if numbers are sequential starting from 1
        let numbers = levelData.numbers.compactMap { Int($0.key) }.sorted()
        for (index, number) in numbers.enumerated() {
            if number != index + 1 {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Level Statistics
    func getLevelStatistics(level: Int, difficulty: DifficultyLevel) -> LevelStatistics? {
        let userDefaults = UserDefaults.standard
        let key = "level_\(level)_\(difficulty.rawValue)"
        
        guard let data = userDefaults.data(forKey: key),
              let stats = try? JSONDecoder().decode(LevelStatistics.self, from: data) else {
            return nil
        }
        
        return stats
    }
    
    func saveLevelStatistics(_ statistics: LevelStatistics, level: Int, difficulty: DifficultyLevel) {
        let userDefaults = UserDefaults.standard
        let key = "level_\(level)_\(difficulty.rawValue)"
        
        if let data = try? JSONEncoder().encode(statistics) {
            userDefaults.set(data, forKey: key)
        }
    }
}

// MARK: - Level Statistics
struct LevelStatistics: Codable {
    let level: Int
    let difficulty: String
    var bestTime: TimeInterval
    var bestScore: Int
    var attempts: Int
    var completed: Bool
    var stars: Int
    
    init(level: Int, difficulty: DifficultyLevel) {
        self.level = level
        self.difficulty = difficulty.rawValue
        self.bestTime = 0
        self.bestScore = 0
        self.attempts = 0
        self.completed = false
        self.stars = 0
    }
    
    mutating func updateWithCompletion(time: TimeInterval, score: Int) {
        attempts += 1
        completed = true
        
        if bestTime == 0 || time < bestTime {
            bestTime = time
        }
        
        if score > bestScore {
            bestScore = score
        }
        
        // Calculate stars based on performance
        stars = calculateStars(time: time, score: score)
    }
    
    private func calculateStars(time: TimeInterval, score: Int) -> Int {
        // Simple star calculation - can be made more sophisticated
        if score >= 800 && time <= 60 {
            return 3
        } else if score >= 600 && time <= 120 {
            return 2
        } else if completed {
            return 1
        } else {
            return 0
        }
    }
}
