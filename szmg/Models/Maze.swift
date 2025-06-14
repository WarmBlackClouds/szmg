//
//  Maze.swift
//  badx T DM
//
//  Created by AI Assistant on 2025/1/10.
//

import Foundation

// MARK: - Cell Types
enum CellType: Equatable {
    case empty          // Empty cell that can be filled with path
    case numbered(Int)  // Cell with a number (1, 2, 3, etc.)
    case obstacle       // Wall/obstacle that blocks movement
    case path           // Cell that's part of the current path
}

// MARK: - Cell Position
struct Position: Equatable, Hashable {
    let row: Int
    let col: Int
    
    init(_ row: Int, _ col: Int) {
        self.row = row
        self.col = col
    }
    
    // Get all 8 adjacent positions (including diagonals)
    func adjacentPositions() -> [Position] {
        return [
            Position(row - 1, col - 1), // Top-left
            Position(row - 1, col),     // Top
            Position(row - 1, col + 1), // Top-right
            Position(row, col - 1),     // Left
            Position(row, col + 1),     // Right
            Position(row + 1, col - 1), // Bottom-left
            Position(row + 1, col),     // Bottom
            Position(row + 1, col + 1)  // Bottom-right
        ]
    }
    
    // Check if position is adjacent to another position
    func isAdjacent(to other: Position) -> Bool {
        let rowDiff = abs(self.row - other.row)
        let colDiff = abs(self.col - other.col)
        return rowDiff <= 1 && colDiff <= 1 && (rowDiff + colDiff > 0)
    }
}

// MARK: - Maze Cell
struct MazeCell {
    let position: Position
    var type: CellType
    var isHighlighted: Bool = false  // For hints
    var isSelected: Bool = false     // For current selection
    
    init(position: Position, type: CellType) {
        self.position = position
        self.type = type
    }
    
    var isNumbered: Bool {
        if case .numbered(_) = type {
            return true
        }
        return false
    }
    
    var number: Int? {
        if case .numbered(let num) = type {
            return num
        }
        return nil
    }
    
    var isTraversable: Bool {
        switch type {
        case .empty, .numbered(_), .path:
            return true
        case .obstacle:
            return false
        }
    }
}

// MARK: - Difficulty Level
enum DifficultyLevel: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var gridSize: Int {
        switch self {
        case .easy: return 4
        case .medium: return 6
        case .hard: return 8
        }
    }
    
    var maxNumber: Int {
        switch self {
        case .easy: return 8
        case .medium: return 18
        case .hard: return 32
        }
    }
    
    var obstaclePercentage: Double {
        switch self {
        case .easy: return 0.1
        case .medium: return 0.15
        case .hard: return 0.2
        }
    }
}

// MARK: - Game Mode
enum GameMode: String, CaseIterable {
    case classic = "Classic"
    case challenge = "Challenge"
    case daily = "Daily Challenge"
    
    var hasTimeLimit: Bool {
        return self == .challenge
    }
    
    var timeLimitSeconds: Int {
        return 120 // 2 minutes for challenge mode
    }
}

// MARK: - Maze
class Maze: ObservableObject {
    let size: Int
    let difficulty: DifficultyLevel
    let maxNumber: Int
    
    @Published var cells: [[MazeCell]]
    @Published var numberedCells: [Int: Position] = [:]  // number -> position mapping
    
    init(size: Int, difficulty: DifficultyLevel) {
        self.size = size
        self.difficulty = difficulty
        self.maxNumber = difficulty.maxNumber
        
        // Initialize empty grid
        self.cells = Array(0..<size).map { row in
            Array(0..<size).map { col in
                MazeCell(position: Position(row, col), type: .empty)
            }
        }
    }
    
    // MARK: - Cell Access
    func cell(at position: Position) -> MazeCell? {
        guard isValidPosition(position) else { return nil }
        return cells[position.row][position.col]
    }
    
    func setCell(at position: Position, type: CellType) {
        guard isValidPosition(position) else { return }
        cells[position.row][position.col].type = type
        
        // Update numbered cells mapping
        if case .numbered(let number) = type {
            numberedCells[number] = position
        }
    }
    
    func isValidPosition(_ position: Position) -> Bool {
        return position.row >= 0 && position.row < size &&
               position.col >= 0 && position.col < size
    }
    
    // MARK: - Highlight Management
    func highlightCell(at position: Position) {
        guard isValidPosition(position) else { return }
        cells[position.row][position.col].isHighlighted = true
    }
    
    func clearHighlights() {
        for row in 0..<size {
            for col in 0..<size {
                cells[row][col].isHighlighted = false
            }
        }
    }
    
    func selectCell(at position: Position) {
        guard isValidPosition(position) else { return }
        clearSelections()
        cells[position.row][position.col].isSelected = true
    }
    
    func clearSelections() {
        for row in 0..<size {
            for col in 0..<size {
                cells[row][col].isSelected = false
            }
        }
    }
    
    // MARK: - Path Management
    func setPath(at position: Position) {
        guard isValidPosition(position) else { return }
        if cells[position.row][position.col].type == .empty {
            cells[position.row][position.col].type = .path
        }
    }
    
    func clearPath(at position: Position) {
        guard isValidPosition(position) else { return }
        if cells[position.row][position.col].type == .path {
            cells[position.row][position.col].type = .empty
        }
    }
    
    func clearAllPaths() {
        for row in 0..<size {
            for col in 0..<size {
                if cells[row][col].type == .path {
                    cells[row][col].type = .empty
                }
            }
        }
    }
    
    // MARK: - Utility Methods
    func getAllNumberedPositions() -> [Position] {
        return numberedCells.values.sorted { pos1, pos2 in
            let num1 = numberedCells.first { $0.value == pos1 }?.key ?? 0
            let num2 = numberedCells.first { $0.value == pos2 }?.key ?? 0
            return num1 < num2
        }
    }
    
    func getEmptyPositions() -> [Position] {
        var emptyPositions: [Position] = []
        for row in 0..<size {
            for col in 0..<size {
                if cells[row][col].type == .empty {
                    emptyPositions.append(Position(row, col))
                }
            }
        }
        return emptyPositions
    }
}
