//
//  MazeGenerator.swift
//  badx T DM
//
//  Created by AI Assistant on 2025/1/10.
//

import Foundation

class MazeGenerator {
    
    // MARK: - Generation Methods
    static func generateMaze(difficulty: DifficultyLevel, level: Int = 1) -> Maze {
        let maze = Maze(size: difficulty.gridSize, difficulty: difficulty)

        // Generate numbered positions
        let numberedPositions = generateNumberedPositions(for: maze, difficulty: difficulty)

        // Place numbered cells
        for (number, position) in numberedPositions {
            maze.setCell(at: position, type: .numbered(number))
        }

        // Generate obstacles
        generateObstacles(for: maze, difficulty: difficulty, avoidingPositions: Array(numberedPositions.values))

        // Ensure maze is solvable
        if !isMazeSolvable(maze) {
            // If not solvable, try again with fewer obstacles
            return generateSimplifiedMaze(difficulty: difficulty, numberedPositions: numberedPositions)
        }

        return maze
    }
    
    // MARK: - Number Placement
    private static func generateNumberedPositions(for maze: Maze, difficulty: DifficultyLevel) -> [Int: Position] {
        var numberedPositions: [Int: Position] = [:]
        var availablePositions = getAllPositions(size: maze.size)
        
        // Always start with number 1 in a corner or edge for easier gameplay
        let startPosition = getGoodStartPosition(size: maze.size)
        numberedPositions[1] = startPosition
        availablePositions.removeAll { $0 == startPosition }
        
        // Place remaining numbers
        for number in 2...difficulty.maxNumber {
            if let position = findBestPositionForNumber(number, 
                                                       previousPosition: numberedPositions[number - 1]!,
                                                       availablePositions: availablePositions,
                                                       maze: maze) {
                numberedPositions[number] = position
                availablePositions.removeAll { $0 == position }
            }
        }
        
        return numberedPositions
    }
    
    private static func getGoodStartPosition(size: Int) -> Position {
        let corners = [
            Position(0, 0),
            Position(0, size - 1),
            Position(size - 1, 0),
            Position(size - 1, size - 1)
        ]
        return corners.randomElement() ?? Position(0, 0)
    }
    
    private static func findBestPositionForNumber(_ number: Int, 
                                                 previousPosition: Position,
                                                 availablePositions: [Position],
                                                 maze: Maze) -> Position? {
        
        // For early numbers, prefer positions that are reachable but not too close
        if number <= 5 {
            let adjacentPositions = previousPosition.adjacentPositions().filter { pos in
                maze.isValidPosition(pos) && availablePositions.contains(pos)
            }
            
            if !adjacentPositions.isEmpty {
                return adjacentPositions.randomElement()
            }
        }
        
        // For later numbers, find positions that maintain good connectivity
        let reachablePositions = availablePositions.filter { pos in
            previousPosition.isAdjacent(to: pos)
        }
        
        if !reachablePositions.isEmpty {
            return reachablePositions.randomElement()
        }
        
        // If no adjacent positions, find the closest available position
        return availablePositions.min { pos1, pos2 in
            distance(from: previousPosition, to: pos1) < distance(from: previousPosition, to: pos2)
        }
    }
    
    // MARK: - Obstacle Generation
    private static func generateObstacles(for maze: Maze, 
                                        difficulty: DifficultyLevel, 
                                        avoidingPositions: [Position]) {
        let totalCells = maze.size * maze.size
        let numberedCells = avoidingPositions.count
        let availableCells = totalCells - numberedCells
        let obstacleCount = Int(Double(availableCells) * difficulty.obstaclePercentage)
        
        var availablePositions = getAllPositions(size: maze.size)
        availablePositions.removeAll { avoidingPositions.contains($0) }
        
        var placedObstacles = 0
        var attempts = 0
        let maxAttempts = obstacleCount * 3
        
        while placedObstacles < obstacleCount && attempts < maxAttempts {
            attempts += 1
            
            guard let randomPosition = availablePositions.randomElement() else { break }
            
            // Temporarily place obstacle
            maze.setCell(at: randomPosition, type: .obstacle)
            
            // Check if maze is still solvable
            if isMazeSolvable(maze) {
                // Keep the obstacle
                availablePositions.removeAll { $0 == randomPosition }
                placedObstacles += 1
            } else {
                // Remove the obstacle
                maze.setCell(at: randomPosition, type: .empty)
            }
        }
    }
    
    // MARK: - Solvability Check
    private static func isMazeSolvable(_ maze: Maze) -> Bool {
        // Use A* pathfinding to check if a solution exists
        return findSolution(for: maze) != nil
    }
    
    private static func findSolution(for maze: Maze) -> [Position]? {
        guard let startPosition = maze.numberedCells[1] else { return nil }
        
        var currentPath: [Position] = [startPosition]
        var visitedPositions: Set<Position> = [startPosition]
        
        return findSolutionRecursive(maze: maze, 
                                   currentPath: currentPath, 
                                   visitedPositions: visitedPositions, 
                                   targetNumber: 2)
    }
    
    private static func findSolutionRecursive(maze: Maze, 
                                            currentPath: [Position], 
                                            visitedPositions: Set<Position>, 
                                            targetNumber: Int) -> [Position]? {
        
        // Base case: found all numbers
        if targetNumber > maze.maxNumber {
            return currentPath
        }
        
        // Get target position
        guard let targetPosition = maze.numberedCells[targetNumber] else { return nil }
        
        // Check if target is reachable from current position
        guard let currentPosition = currentPath.last else { return nil }
        
        // Find path to target using BFS
        if let pathToTarget = findPathBFS(from: currentPosition, 
                                        to: targetPosition, 
                                        in: maze, 
                                        avoiding: visitedPositions) {
            
            var newPath = currentPath
            var newVisited = visitedPositions
            
            // Add intermediate positions to path
            for position in pathToTarget.dropFirst() {
                newPath.append(position)
                newVisited.insert(position)
            }
            
            // Recursively find path to next number
            return findSolutionRecursive(maze: maze, 
                                       currentPath: newPath, 
                                       visitedPositions: newVisited, 
                                       targetNumber: targetNumber + 1)
        }
        
        return nil
    }
    
    // MARK: - Pathfinding
    private static func findPathBFS(from start: Position, 
                                  to target: Position, 
                                  in maze: Maze, 
                                  avoiding visitedPositions: Set<Position>) -> [Position]? {
        
        var queue: [(Position, [Position])] = [(start, [start])]
        var visited: Set<Position> = visitedPositions
        
        while !queue.isEmpty {
            let (currentPos, path) = queue.removeFirst()
            
            if currentPos == target {
                return path
            }
            
            for adjacentPos in currentPos.adjacentPositions() {
                guard maze.isValidPosition(adjacentPos) else { continue }
                guard !visited.contains(adjacentPos) else { continue }
                guard let cell = maze.cell(at: adjacentPos) else { continue }
                guard cell.isTraversable else { continue }
                
                visited.insert(adjacentPos)
                queue.append((adjacentPos, path + [adjacentPos]))
            }
        }
        
        return nil
    }
    
    // MARK: - Simplified Generation
    private static func generateSimplifiedMaze(difficulty: DifficultyLevel, 
                                             numberedPositions: [Int: Position]) -> Maze {
        let maze = Maze(size: difficulty.gridSize, difficulty: difficulty)
        
        // Place numbered cells
        for (number, position) in numberedPositions {
            maze.setCell(at: position, type: .numbered(number))
        }
        
        // Add minimal obstacles
        let obstacleCount = max(1, Int(Double(maze.size * maze.size) * 0.05))
        var availablePositions = getAllPositions(size: maze.size)
        availablePositions.removeAll { numberedPositions.values.contains($0) }
        
        for _ in 0..<obstacleCount {
            if let randomPosition = availablePositions.randomElement() {
                maze.setCell(at: randomPosition, type: .obstacle)
                availablePositions.removeAll { $0 == randomPosition }
            }
        }
        
        return maze
    }
    
    // MARK: - Utility Functions
    private static func getAllPositions(size: Int) -> [Position] {
        var positions: [Position] = []
        for row in 0..<size {
            for col in 0..<size {
                positions.append(Position(row, col))
            }
        }
        return positions
    }
    
    private static func distance(from pos1: Position, to pos2: Position) -> Double {
        let dx = Double(pos1.col - pos2.col)
        let dy = Double(pos1.row - pos2.row)
        return sqrt(dx * dx + dy * dy)
    }
    
    // MARK: - Preset Levels
    static func generatePresetLevel(_ level: Int, difficulty: DifficultyLevel) -> Maze {
        // Try to load from preset levels first
        if let presetMaze = LevelLoader.shared.loadLevel(level, difficulty: difficulty) {
            return presetMaze
        }

        // Fallback to generated maze
        return generateMaze(difficulty: difficulty, level: level)
    }

    // MARK: - Daily Challenge
    static func generateDailyChallenge() -> Maze {
        let date = Date()
        // Try to load daily challenge
        if let dailyMaze = LevelLoader.shared.loadDailyChallenge(for: date) {
            return dailyMaze
        }

        // Fallback to medium difficulty generated maze
        return generateMaze(difficulty: .medium, level: 1)
    }
}
