//
//  Path.swift
//  badx T DM
//
//  Created by AI Assistant on 2025/1/10.
//

import Foundation

// MARK: - Path Connection
struct PathConnection {
    let from: Position
    let to: Position
    let fromNumber: Int
    let toNumber: Int
    
    init(from: Position, to: Position, fromNumber: Int, toNumber: Int) {
        self.from = from
        self.to = to
        self.fromNumber = fromNumber
        self.toNumber = toNumber
    }
    
    var isValid: Bool {
        return toNumber == fromNumber + 1 && from.isAdjacent(to: to)
    }
}

// MARK: - Game Path
class GamePath: ObservableObject {
    @Published var connections: [PathConnection] = []
    @Published var visitedPositions: Set<Position> = []
    @Published var currentNumber: Int = 1
    
    private let maxNumber: Int
    
    init(maxNumber: Int) {
        self.maxNumber = maxNumber
    }
    
    // MARK: - Path Management
    func addConnection(_ connection: PathConnection) -> Bool {
        guard connection.isValid else { return false }
        // Check if we're connecting from the current position (which should have currentNumber - 1)
        guard connection.fromNumber == currentNumber - 1 else { return false }
        // Check if we're connecting to the next required number
        guard connection.toNumber == currentNumber else { return false }
        guard !visitedPositions.contains(connection.to) else { return false }

        connections.append(connection)
        visitedPositions.insert(connection.from) // Also add the from position
        visitedPositions.insert(connection.to)
        currentNumber += 1

        return true
    }

    func startPath(at position: Position, withNumber number: Int) -> Bool {
        guard number == currentNumber else { return false }
        guard visitedPositions.isEmpty else { return false } // Can only start if path is empty

        visitedPositions.insert(position)
        currentNumber += 1

        return true
    }
    
    func removeLastConnection() -> PathConnection? {
        guard let lastConnection = connections.popLast() else { return nil }
        
        visitedPositions.remove(lastConnection.to)
        currentNumber = lastConnection.fromNumber
        
        return lastConnection
    }
    
    func clear() {
        connections.removeAll()
        visitedPositions.removeAll()
        currentNumber = 1
    }
    
    // MARK: - Path Validation
    func isComplete() -> Bool {
        return currentNumber > maxNumber
    }
    
    func canConnectTo(position: Position, fromPosition: Position) -> Bool {
        // Check if positions are adjacent
        guard fromPosition.isAdjacent(to: position) else { return false }
        
        // Check if target position hasn't been visited
        guard !visitedPositions.contains(position) else { return false }
        
        return true
    }
    
    func getNextRequiredNumber() -> Int {
        return currentNumber
    }
    
    func isPositionInPath(_ position: Position) -> Bool {
        return visitedPositions.contains(position)
    }
    
    // MARK: - Path Information
    func getPathLength() -> Int {
        return connections.count
    }
    
    func getLastPosition() -> Position? {
        return connections.last?.to
    }
    
    func getAllPathPositions() -> [Position] {
        var positions: [Position] = []
        if let firstConnection = connections.first {
            positions.append(firstConnection.from)
        }
        positions.append(contentsOf: connections.map { $0.to })
        return positions
    }
    
    func getConnectionsForPosition(_ position: Position) -> [PathConnection] {
        return connections.filter { $0.from == position || $0.to == position }
    }
    
    // MARK: - Path Validation Helpers
    func validatePath(in maze: Maze) -> Bool {
        // Check if all connections are valid
        for connection in connections {
            guard connection.isValid else { return false }
            
            // Check if positions exist in maze and are traversable
            guard let fromCell = maze.cell(at: connection.from),
                  let toCell = maze.cell(at: connection.to) else { return false }
            
            guard fromCell.isTraversable && toCell.isTraversable else { return false }
            
            // Check if numbers match
            guard fromCell.number == connection.fromNumber,
                  toCell.number == connection.toNumber else { return false }
        }
        
        // Check if path is continuous
        for i in 1..<connections.count {
            guard connections[i-1].to == connections[i].from else { return false }
        }
        
        return true
    }
    
    func hasValidNextMove(from position: Position, in maze: Maze) -> Bool {
        let nextNumber = getNextRequiredNumber()
        guard let nextPosition = maze.numberedCells[nextNumber] else { return false }
        
        return canConnectTo(position: nextPosition, fromPosition: position)
    }
    
    // MARK: - Hint System Support
    func getHintForNextMove(in maze: Maze) -> Position? {
        let nextNumber = getNextRequiredNumber()
        return maze.numberedCells[nextNumber]
    }
    
    func getPossibleNextPositions(from position: Position, in maze: Maze) -> [Position] {
        let adjacentPositions = position.adjacentPositions()
        return adjacentPositions.filter { pos in
            guard maze.isValidPosition(pos) else { return false }
            guard let cell = maze.cell(at: pos) else { return false }
            guard cell.isTraversable else { return false }
            guard !visitedPositions.contains(pos) else { return false }
            return true
        }
    }
}

// MARK: - Path Statistics
struct PathStatistics {
    let totalMoves: Int
    let correctMoves: Int
    let wrongMoves: Int
    let hintsUsed: Int
    let timeElapsed: TimeInterval
    
    var accuracy: Double {
        guard totalMoves > 0 else { return 0.0 }
        return Double(correctMoves) / Double(totalMoves)
    }
    
    var score: Int {
        let baseScore = correctMoves * 10
        let timeBonus = max(0, 300 - Int(timeElapsed)) // Bonus for completing quickly
        let hintPenalty = hintsUsed * 5
        return max(0, baseScore + timeBonus - hintPenalty)
    }
}
