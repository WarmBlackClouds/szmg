//
//  GameViewController.swift
//  badx T DM
//
//  Created by AI Assistant on 2025/1/10.
//

import UIKit

class GameViewController: UIViewController {
    
    // MARK: - Properties
    private let gameMode: GameMode
    private let difficulty: DifficultyLevel
    private let level: Int
    
    private var gameViewModel: GameViewModel!
    private let soundManager = SoundManager.shared
    
    // MARK: - UI Elements
    private let backgroundImageView = UIImageView()

    // Main layout containers
    private let leftContainerView = UIView()
    private let rightContainerView = UIView()

    // Game area (left side top)
    private let gameContainerView = UIView()
    private let mazeGridView = UIView()
    private let pathDrawingLayer = CAShapeLayer()
    private var mazeCells: [[UIView]] = []

    // Status area (left side bottom)
    private let statusContainerView = UIView()
    private let statusStackView = UIStackView()
    private let levelLabel = UILabel()
    private let scoreLabel = UILabel()
    private let timeLabel = UILabel()
    private let hintsLabel = UILabel()

    // Control area (right side)
    private let buttonStackView = UIStackView()
    private let pauseButton = UIButton(type: .system)
    private let hintButton = UIButton(type: .system)
    private let undoButton = UIButton(type: .system)
    private let restartButton = UIButton(type: .system)
    private let exitButton = UIButton(type: .system)
    
    // Game state
    private var selectedCell: Position?
    private var isGameActive = false

    // Connection animation properties (no longer needed for dragging)
    
    // MARK: - Initialization
    init(gameMode: GameMode, difficulty: DifficultyLevel, level: Int = 1) {
        self.gameMode = gameMode
        self.difficulty = difficulty
        self.level = level
        
        // Initialize maze grid view
        self.mazeGridView.backgroundColor = UIColor.clear
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupUI()
        setupConstraints()
        setupMazeGrid()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Debug view hierarchy
        print("🔧 ViewDidAppear: view bounds: \(view.bounds)")
        print("🔧 ViewDidAppear: gameContainerView bounds: \(gameContainerView.bounds)")
        print("🔧 ViewDidAppear: mazeGridView bounds: \(mazeGridView.bounds)")
        print("🔧 ViewDidAppear: mazeGridView userInteractionEnabled: \(mazeGridView.isUserInteractionEnabled)")

        // Start the game after the view has appeared
        startGame()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NSLog("🔄 SZMG ViewWillDisappear: Cleaning up resources")
        // Clean up when view is about to disappear
        cleanupResources()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NSLog("🔄 SZMG ViewDidDisappear: Game inactive")
        // Additional cleanup when view has disappeared
        isGameActive = false
    }

    private var hasCreatedInitialGrid = false

    // Alert display tracking to prevent duplicates
    private var hasShownCompletionAlert = false
    private var hasShownFailureAlert = false
    private var currentlyPresentingAlert = false

    // Timer for UI updates
    private var uiUpdateTimer: Timer?

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Only create grid once when layout is complete and game is active
        if isGameActive && !hasCreatedInitialGrid && mazeGridView.bounds.width > 0 {
            DispatchQueue.main.async {
                self.createMazeGrid()
                self.hasCreatedInitialGrid = true
            }
        }
    }

    // MARK: - Cleanup
    private func cleanupResources() {
        NSLog("🧹 SZMG CleanupResources: Starting cleanup")

        // Cancel UI update timer
        uiUpdateTimer?.invalidate()
        uiUpdateTimer = nil

        // Cancel GameViewModel bindings to prevent continued status monitoring
        gameViewModel?.cancelAllBindings()

        // Disable user interaction to prevent further taps
        mazeGridView.isUserInteractionEnabled = false
        view.isUserInteractionEnabled = false

        // Clear all gesture recognizers from cells
        mazeCells.forEach { row in
            row.forEach { cell in
                cell.gestureRecognizers?.forEach { gesture in
                    cell.removeGestureRecognizer(gesture)
                }
                cell.isUserInteractionEnabled = false
            }
        }

        // Clear any pending animations
        mazeGridView.layer.removeAllAnimations()
        pathDrawingLayer.removeAllAnimations()

        // Reset tap tracking
        lastTapTime = 0
        lastTapPosition = nil

        // Reset alert tracking
        hasShownCompletionAlert = false
        hasShownFailureAlert = false
        currentlyPresentingAlert = false

        NSLog("🧹 SZMG CleanupResources: Cleanup completed")
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    // MARK: - Setup
    private func setupViewModel() {
        gameViewModel = GameViewModel(gameMode: gameMode, difficulty: difficulty, level: level)
        // Add observers for game state changes
        setupGameStateObservers()
    }
    
    private func setupGameStateObservers() {
        // Timer for updating UI
        uiUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .black

        // Background
        backgroundImageView.image = UIImage(named: "bg")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)

        // Overlay - Made transparent to show background image
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)

        setupMainContainers()
        setupGameArea()
        setupControlArea()
    }
    
    private func setupMainContainers() {
        // Left container for game
        leftContainerView.backgroundColor = UIColor.clear
        leftContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(leftContainerView)

        // Right container for controls
        rightContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        rightContainerView.layer.cornerRadius = 15
        rightContainerView.layer.borderWidth = 1
        rightContainerView.layer.borderColor = UIColor.systemPink.withAlphaComponent(0.3).cgColor
        rightContainerView.layer.shadowColor = UIColor.systemPink.cgColor
        rightContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        rightContainerView.layer.shadowRadius = 6
        rightContainerView.layer.shadowOpacity = 0.2
        rightContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rightContainerView)
    }
    
    private func setupGameArea() {
        // Game container in left side top
        gameContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        gameContainerView.layer.cornerRadius = 15
        gameContainerView.layer.borderWidth = 2
        gameContainerView.layer.borderColor = UIColor.systemPink.withAlphaComponent(0.3).cgColor
        gameContainerView.layer.shadowColor = UIColor.systemPink.cgColor
        gameContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        gameContainerView.layer.shadowRadius = 6
        gameContainerView.layer.shadowOpacity = 0.2
        gameContainerView.translatesAutoresizingMaskIntoConstraints = false
        leftContainerView.addSubview(gameContainerView)

        mazeGridView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        mazeGridView.layer.shadowColor = UIColor.systemPink.cgColor
        mazeGridView.layer.shadowOffset = CGSize(width: 0, height: 2)
        mazeGridView.layer.shadowRadius = 4
        mazeGridView.layer.shadowOpacity = 0.15
        mazeGridView.translatesAutoresizingMaskIntoConstraints = false
        mazeGridView.isUserInteractionEnabled = true
        mazeGridView.layer.borderWidth = 2
        mazeGridView.layer.borderColor = UIColor.systemPink.withAlphaComponent(0.3).cgColor
        gameContainerView.addSubview(mazeGridView)

        // Setup path drawing layer
        setupPathDrawingLayer()

        print("🔧 Setup: mazeGridView configured with user interaction enabled")

        // Status container in left side bottom
        statusContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        statusContainerView.layer.cornerRadius = 15
        statusContainerView.layer.borderWidth = 1
        statusContainerView.layer.borderColor = UIColor.systemPink.withAlphaComponent(0.3).cgColor
        statusContainerView.layer.shadowColor = UIColor.systemPink.cgColor
        statusContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        statusContainerView.layer.shadowRadius = 4
        statusContainerView.layer.shadowOpacity = 0.2
        statusContainerView.translatesAutoresizingMaskIntoConstraints = false
        leftContainerView.addSubview(statusContainerView)

        // Status stack view for game stats
        statusStackView.axis = .horizontal
        statusStackView.distribution = .fillEqually
        statusStackView.spacing = 8
        statusStackView.translatesAutoresizingMaskIntoConstraints = false
        statusContainerView.addSubview(statusStackView)

        // Setup status labels
        setupStatusLabel(levelLabel, title: "Level")
        setupStatusLabel(scoreLabel, title: "Score")
        setupStatusLabel(timeLabel, title: "Time")
        setupStatusLabel(hintsLabel, title: "Hints")

        statusStackView.addArrangedSubview(levelLabel)
        statusStackView.addArrangedSubview(scoreLabel)
        statusStackView.addArrangedSubview(timeLabel)
        statusStackView.addArrangedSubview(hintsLabel)
    }
    
    private func setupControlArea() {
        // Button stack view for game controls (right side)
        buttonStackView.axis = .vertical
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 15
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        rightContainerView.addSubview(buttonStackView)

        // Setup buttons - Colors that complement light pink background
        setupGameButton(pauseButton, title: "⏸️ Pause", color: .systemIndigo)
        setupGameButton(hintButton, title: "💡 Hint", color: .systemYellow)
        setupGameButton(undoButton, title: "↶ Undo", color: .systemTeal)
        setupGameButton(restartButton, title: "🔄 Restart", color: .systemOrange)
        setupGameButton(exitButton, title: "❌ Exit", color: .systemBrown)

        pauseButton.addTarget(self, action: #selector(pauseTapped), for: .touchUpInside)
        hintButton.addTarget(self, action: #selector(hintTapped), for: .touchUpInside)
        undoButton.addTarget(self, action: #selector(undoTapped), for: .touchUpInside)
        restartButton.addTarget(self, action: #selector(restartTapped), for: .touchUpInside)
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)

        buttonStackView.addArrangedSubview(pauseButton)
        buttonStackView.addArrangedSubview(hintButton)
        buttonStackView.addArrangedSubview(undoButton)
        buttonStackView.addArrangedSubview(restartButton)
        buttonStackView.addArrangedSubview(exitButton)
    }

    private func setupStatusLabel(_ label: UILabel, title: String) {
        label.text = "\(title)\n0"
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .black
        label.backgroundColor = UIColor.systemPink.withAlphaComponent(0.1)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.layer.shadowColor = UIColor.systemPink.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shadowRadius = 2
        label.layer.shadowOpacity = 0.1
    }
    
    private func setupGameButton(_ button: UIButton, title: String, color: UIColor) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        button.backgroundColor = color
        button.layer.cornerRadius = 8
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 2
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
    }
    
    private func setupMazeGrid() {
        // This will be called after the game starts to create the actual grid
    }

    private func setupPathDrawingLayer() {
        pathDrawingLayer.strokeColor = UIColor.systemGreen.cgColor
        pathDrawingLayer.lineWidth = 4.0
        pathDrawingLayer.lineCap = .round
        pathDrawingLayer.lineJoin = .round
        pathDrawingLayer.fillColor = UIColor.clear.cgColor
        mazeGridView.layer.addSublayer(pathDrawingLayer)
    }

    private func createMazeGrid() {
        guard let gameState = gameViewModel?.gameState else {
            print("🔴 CreateMazeGrid: No game state")
            return
        }

        print("🔧 CreateMazeGrid: Starting grid creation")

        // Clear existing cells and their gesture recognizers
        mazeCells.forEach { row in
            row.forEach { cell in
                // Remove all gesture recognizers before removing from superview
                cell.gestureRecognizers?.forEach { gesture in
                    cell.removeGestureRecognizer(gesture)
                }
                cell.removeFromSuperview()
            }
        }
        mazeCells.removeAll()

        let mazeSize = gameState.maze.size

        // Use the full available space, ensuring the grid fills the container
        let availableWidth = mazeGridView.bounds.width
        let availableHeight = mazeGridView.bounds.height
        let gridSize = min(availableWidth, availableHeight)

        print("🔧 CreateMazeGrid: mazeGridView bounds: \(mazeGridView.bounds)")
        print("🔧 CreateMazeGrid: Available size: \(availableWidth) x \(availableHeight), gridSize: \(gridSize)")

        // Calculate cell size with minimal spacing
        let spacing: CGFloat = 4
        let totalSpacing = spacing * CGFloat(mazeSize - 1)
        let cellSize = (gridSize - totalSpacing) / CGFloat(mazeSize)

        // Center the grid in the available space
        let totalGridWidth = CGFloat(mazeSize) * cellSize + totalSpacing
        let totalGridHeight = totalGridWidth
        let startX = (availableWidth - totalGridWidth) / 2
        let startY = (availableHeight - totalGridHeight) / 2

        print("🔧 CreateMazeGrid: Cell size: \(cellSize), start position: (\(startX), \(startY))")

        // Create grid of cells
        for row in 0..<mazeSize {
            var cellRow: [UIView] = []
            for col in 0..<mazeSize {
                let position = Position(row, col)
                let cellView = createCellView(for: position, size: cellSize)

                let x = startX + CGFloat(col) * (cellSize + spacing)
                let y = startY + CGFloat(row) * (cellSize + spacing)
                cellView.frame = CGRect(x: x, y: y, width: cellSize, height: cellSize)

                mazeGridView.addSubview(cellView)
                cellRow.append(cellView)
            }
            mazeCells.append(cellRow)
        }

        print("🔧 CreateMazeGrid: Created \(mazeCells.count) x \(mazeCells.first?.count ?? 0) grid")
    }

    private func createCellView(for position: Position, size: CGFloat) -> UIView {
        guard let gameState = gameViewModel?.gameState,
              let cell = gameState.maze.cell(at: position) else {
            return UIView()
        }

        let cellView = UIView()
        cellView.backgroundColor = getCellBackgroundColor(for: cell, gameState: gameState)
        cellView.layer.cornerRadius = 8
        cellView.layer.borderWidth = 2
        cellView.layer.borderColor = getCellBorderColor(for: cell, gameState: gameState).cgColor

        // Add number label if cell is numbered
        if cell.isNumbered, let number = cell.number {
            let label = UILabel()
            label.text = "\(number)"
            label.textAlignment = .center
            // Make font size larger and more readable
            let fontSize = max(16, size * 0.6) // Minimum 16pt, or 60% of cell size
            label.font = UIFont.boldSystemFont(ofSize: fontSize)
            label.textColor = getCellTextColor(for: cell, gameState: gameState)
            label.frame = CGRect(x: 0, y: 0, width: size, height: size)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            cellView.addSubview(label)
        }

        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
        cellView.addGestureRecognizer(tapGesture)
        cellView.tag = position.row * 100 + position.col // Store position in tag

        return cellView
    }

    private func getCellBackgroundColor(for cell: MazeCell, gameState: GameState) -> UIColor {
        switch cell.type {
        case .obstacle:
            return UIColor.systemGray2
        case .numbered(_):
            let isInPath = gameState.isPositionInPath(cell.position)
            if isInPath {
                return UIColor.systemGreen
            } else if cell.isSelected {
                return UIColor.systemBlue
            } else {
                return UIColor.systemYellow
            }
        case .path:
            return UIColor.systemGreen
        case .empty:
            return UIColor.systemGray5
        }
    }

    private func getCellBorderColor(for cell: MazeCell, gameState: GameState) -> UIColor {
        if cell.isSelected {
            return UIColor.systemBlue
        } else {
            let isInPath = gameState.isPositionInPath(cell.position)
            if isInPath {
                return UIColor.systemGreen
            } else {
                return UIColor.systemGray2
            }
        }
    }

    private func getCellTextColor(for cell: MazeCell, gameState: GameState) -> UIColor {
        let isInPath = gameState.isPositionInPath(cell.position)
        if isInPath || cell.isSelected {
            return UIColor.white
        } else {
            return UIColor.black
        }
    }

    // Add a property to prevent rapid repeated taps
    private var lastTapTime: TimeInterval = 0
    private var lastTapPosition: Position?

    @objc private func cellTapped(_ gesture: UITapGestureRecognizer) {
        guard let cellView = gesture.view else { return }

        // Only process tap if gesture is in ended state
        guard gesture.state == .ended else { return }

        // Only handle taps if this view controller is active and visible
        guard isGameActive,
              view.window != nil,
              navigationController?.topViewController == self else {
            NSLog("⚠️ SZMG CellTapped: View controller not active, ignoring tap")
            return
        }

        let row = cellView.tag / 100
        let col = cellView.tag % 100
        let position = Position(row, col)

        // Prevent rapid repeated taps on the same cell
        let currentTime = CACurrentMediaTime()
        if let lastPos = lastTapPosition,
           lastPos == position,
           currentTime - lastTapTime < 0.5 {
            NSLog("⚠️ SZMG CellTapped: Ignoring rapid repeated tap")
            return
        }

        lastTapTime = currentTime
        lastTapPosition = position

        handleCellClick(at: position)
    }

    private func updateMazeGrid() {
        guard let gameState = gameViewModel?.gameState else { return }

        for row in 0..<mazeCells.count {
            for col in 0..<mazeCells[row].count {
                let position = Position(row, col)
                guard let cell = gameState.maze.cell(at: position) else { continue }

                let cellView = mazeCells[row][col]
                cellView.backgroundColor = getCellBackgroundColor(for: cell, gameState: gameState)
                cellView.layer.borderColor = getCellBorderColor(for: cell, gameState: gameState).cgColor

                // Update text color if there's a label
                if let label = cellView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                    label.textColor = getCellTextColor(for: cell, gameState: gameState)
                }
            }
        }

        // Update path drawing
        updatePathDrawing()
    }
    
    private func startGame() {
        gameViewModel.startGame()
        isGameActive = true
        hasCreatedInitialGrid = false // Reset flag

        // Reset alert tracking for new game
        hasShownCompletionAlert = false
        hasShownFailureAlert = false
        currentlyPresentingAlert = false

        // Ensure layout is complete before creating grid
        view.layoutIfNeeded()

        // Create the maze grid and update UI
        DispatchQueue.main.async {
            self.view.layoutIfNeeded() // Ensure mazeGridView has correct bounds
            self.createMazeGrid()
            self.hasCreatedInitialGrid = true
            self.updateUI()
        }
    }
    
    // MARK: - UI Updates
    private func updateUI() {
        guard let gameState = gameViewModel?.gameState else { return }
        
        levelLabel.text = "Level\n\(gameState.currentLevel)"
        scoreLabel.text = "Score\n\(gameState.score)"
        timeLabel.text = "Time\n\(gameState.getFormattedTime())"
        hintsLabel.text = "Hints\n\(gameState.hintsRemaining)"
        
        hintButton.isEnabled = gameState.hintsRemaining > 0
        hintButton.alpha = gameState.hintsRemaining > 0 ? 1.0 : 0.5

        updateMazeGrid()
        
        // Check game status - but only show alerts once
        switch gameState.status {
        case .completed:
            if !hasShownCompletionAlert && !currentlyPresentingAlert {
                hasShownCompletionAlert = true
                showGameCompleted()
            }
        case .failed, .timeUp:
            if !hasShownFailureAlert && !currentlyPresentingAlert {
                hasShownFailureAlert = true
                showGameFailed()
            }
        default:
            break
        }
    }
    
    // MARK: - Game Actions
    @objc private func pauseTapped() {
        soundManager.playUISound()
        gameViewModel.pauseGame()
        showPauseMenu()
    }
    
    @objc private func hintTapped() {
        soundManager.playUISound()
        gameViewModel.useHint()
    }
    
    @objc private func undoTapped() {
        soundManager.playUISound()
        gameViewModel.undoLastMove()
    }
    
    @objc private func restartTapped() {
        soundManager.playUISound()
        gameViewModel.restartGame()
        hasCreatedInitialGrid = false // Reset flag

        // Force refresh after restart
        DispatchQueue.main.async {
            self.view.layoutIfNeeded() // Ensure mazeGridView has correct bounds
            self.createMazeGrid()
            self.hasCreatedInitialGrid = true
            self.updateUI()
        }
    }
    
    @objc private func exitTapped() {
        soundManager.playUISound()
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Game State Handling
    private func showGameCompleted() {
        NSLog("🎉 SZMG ShowGameCompleted: Showing completion alert")
        currentlyPresentingAlert = true

        let alert = UIAlertController(title: "Congratulations!", message: "You completed the level!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Next Level", style: .default) { _ in
            NSLog("🎉 SZMG ShowGameCompleted: Next Level selected")
            self.currentlyPresentingAlert = false
            // Load next level
            self.loadNextLevel()
        })
        alert.addAction(UIAlertAction(title: "Menu", style: .cancel) { _ in
            NSLog("🎉 SZMG ShowGameCompleted: Menu selected")
            self.currentlyPresentingAlert = false
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func showGameFailed() {
        NSLog("💥 SZMG ShowGameFailed: Showing failure alert")
        currentlyPresentingAlert = true

        let alert = UIAlertController(title: "Game Over", message: "Try again!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
            NSLog("💥 SZMG ShowGameFailed: Retry selected")
            self.currentlyPresentingAlert = false
            self.hasShownFailureAlert = false // Reset for retry
            self.gameViewModel.restartGame()
        })
        alert.addAction(UIAlertAction(title: "Menu", style: .cancel) { _ in
            NSLog("💥 SZMG ShowGameFailed: Menu selected")
            self.currentlyPresentingAlert = false
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func showPauseMenu() {
        let alert = UIAlertController(title: "Game Paused", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Resume", style: .default) { _ in
            self.gameViewModel.resumeGame()
        })
        alert.addAction(UIAlertAction(title: "Restart", style: .destructive) { _ in
            self.gameViewModel.restartGame()
        })
        alert.addAction(UIAlertAction(title: "Exit", style: .cancel) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func loadNextLevel() {
        let nextLevel = level + 1
        let nextGameVC = GameViewController(gameMode: gameMode, difficulty: difficulty, level: nextLevel)
        navigationController?.pushViewController(nextGameVC, animated: true)
    }

    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Left container (60% width for game + status)
            leftContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            leftContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            leftContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            leftContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),

            // Right container (40% width for controls)
            rightContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            rightContainerView.leadingAnchor.constraint(equalTo: leftContainerView.trailingAnchor, constant: 10),
            rightContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            rightContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),

            // Status container (bottom part of left container, fixed height)
            statusContainerView.bottomAnchor.constraint(equalTo: leftContainerView.bottomAnchor),
            statusContainerView.leadingAnchor.constraint(equalTo: leftContainerView.leadingAnchor),
            statusContainerView.trailingAnchor.constraint(equalTo: leftContainerView.trailingAnchor),
            statusContainerView.heightAnchor.constraint(equalToConstant: 60),

            // Game container (remaining space in left container)
            gameContainerView.topAnchor.constraint(equalTo: leftContainerView.topAnchor),
            gameContainerView.leadingAnchor.constraint(equalTo: leftContainerView.leadingAnchor),
            gameContainerView.trailingAnchor.constraint(equalTo: leftContainerView.trailingAnchor),
            gameContainerView.bottomAnchor.constraint(equalTo: statusContainerView.topAnchor),

            // Maze grid view (15px margins from game container, square aspect ratio)
            mazeGridView.topAnchor.constraint(equalTo: gameContainerView.topAnchor, constant: 15),
            mazeGridView.bottomAnchor.constraint(equalTo: gameContainerView.bottomAnchor, constant: -15),
            mazeGridView.leadingAnchor.constraint(equalTo: gameContainerView.leadingAnchor, constant: 15),
            mazeGridView.trailingAnchor.constraint(equalTo: gameContainerView.trailingAnchor, constant: -15),
            mazeGridView.widthAnchor.constraint(equalTo: mazeGridView.heightAnchor), // Square aspect ratio

            // Status stack view (inside status container)
            statusStackView.topAnchor.constraint(equalTo: statusContainerView.topAnchor, constant: 8),
            statusStackView.leadingAnchor.constraint(equalTo: statusContainerView.leadingAnchor, constant: 8),
            statusStackView.trailingAnchor.constraint(equalTo: statusContainerView.trailingAnchor, constant: -8),
            statusStackView.bottomAnchor.constraint(equalTo: statusContainerView.bottomAnchor, constant: -8),

            // Button stack view (inside right container)
            buttonStackView.topAnchor.constraint(equalTo: rightContainerView.topAnchor, constant: 20),
            buttonStackView.leadingAnchor.constraint(equalTo: rightContainerView.leadingAnchor, constant: 15),
            buttonStackView.trailingAnchor.constraint(equalTo: rightContainerView.trailingAnchor, constant: -15),
            buttonStackView.bottomAnchor.constraint(equalTo: rightContainerView.bottomAnchor, constant: -20),
        ])
    }

    // MARK: - Click Connection Logic
    private func handleCellClick(at position: Position) {
        NSLog("🚀 SZMG HandleCellClick: Clicked at position (\(position.row), \(position.col))")

        // Only handle clicks if this view controller is active and visible
        guard isGameActive,
              view.window != nil,
              navigationController?.topViewController == self else {
            NSLog("🔴 SZMG HandleCellClick: View controller not active or not top controller")
            return
        }

        guard let gameState = gameViewModel?.gameState else {
            NSLog("🔴 SZMG HandleCellClick: No game state")
            return
        }

        // Check if this is a valid cell
        guard let cell = gameState.maze.cell(at: position),
              cell.isNumbered,
              let number = cell.number else {
            NSLog("🔴 SZMG HandleCellClick: Invalid cell or not numbered at position (\(position.row), \(position.col))")
            return
        }

        let requiredNumber = gameState.getNextRequiredNumber()
        let isInPath = gameState.isPositionInPath(position)
        let currentSelected = gameViewModel.selectedPosition

        NSLog("🔍 SZMG HandleCellClick: Cell number: \(number), required: \(requiredNumber), isInPath: \(isInPath)")
        NSLog("🔍 SZMG HandleCellClick: Current selected: \(currentSelected != nil ? "(\(currentSelected!.row), \(currentSelected!.col))" : "none")")

        // Case 1: No cell is currently selected
        if currentSelected == nil {
            NSLog("🔄 SZMG HandleCellClick: No cell currently selected")
            if number == requiredNumber {
                NSLog("✅ SZMG HandleCellClick: Number matches required: \(number)")
                // If this is the first number (1) and path is empty, start the path
                if number == 1 && gameState.path.connections.isEmpty {
                    NSLog("🎯 SZMG HandleCellClick: Starting path with number 1")
                    let success = gameState.startPath(at: position)
                    if success {
                        NSLog("✅ SZMG HandleCellClick: Successfully started path")
                        selectCell(at: position)
                        updateMazeGrid()
                        updatePathDrawing()
                        soundManager.playSound(.move)
                    } else {
                        NSLog("❌ SZMG HandleCellClick: Failed to start path")
                        showInvalidMoveAnimation(at: position)
                    }
                } else {
                    NSLog("🔄 SZMG HandleCellClick: Selecting cell (not first number)")
                    selectCell(at: position)
                }
            } else if isInPath {
                NSLog("🔄 SZMG HandleCellClick: Cell is in path, selecting")
                selectCell(at: position)
            } else {
                NSLog("❌ SZMG HandleCellClick: Cannot start from number \(number), required: \(requiredNumber)")
                showInvalidMoveAnimation(at: position)
            }
        }
        // Case 2: Same cell clicked again - deselect
        else if currentSelected == position {
            deselectCurrentCell()
        }
        // Case 3: Different cell clicked - try to connect
        else {
            attemptConnection(from: currentSelected!, to: position)
        }
    }

    private func selectCell(at position: Position) {
        print("✅ SelectCell: Selecting cell at position (\(position.row), \(position.col))")
        gameViewModel.selectedPosition = position
        gameViewModel.gameState.maze.clearSelections()
        gameViewModel.gameState.maze.selectCell(at: position)
        updateMazeGrid()
        soundManager.playUISound()
    }

    private func deselectCurrentCell() {
        print("🔄 DeselectCurrentCell: Deselecting current cell")
        gameViewModel.selectedPosition = nil
        gameViewModel.gameState.maze.clearSelections()
        updateMazeGrid()
        soundManager.playUISound()
    }

    private func attemptConnection(from fromPosition: Position, to toPosition: Position) {
        print("🔗 AttemptConnection: From (\(fromPosition.row), \(fromPosition.col)) to (\(toPosition.row), \(toPosition.col))")

        guard let gameState = gameViewModel?.gameState else { return }

        // Check if positions are adjacent
        guard fromPosition.isAdjacent(to: toPosition) else {
            print("❌ AttemptConnection: Positions are not adjacent")
            showInvalidMoveAnimation(at: toPosition)
            return
        }

        // Check if target cell is valid
        guard let toCell = gameState.maze.cell(at: toPosition),
              toCell.isNumbered,
              let toNumber = toCell.number else {
            print("❌ AttemptConnection: Target cell is not numbered")
            showInvalidMoveAnimation(at: toPosition)
            return
        }

        let requiredNumber = gameState.getNextRequiredNumber()

        // Check if this is the correct next number
        if toNumber == requiredNumber {
            // Make the connection
            let success = gameState.makeMove(from: fromPosition, to: toPosition)
            if success {
                print("✅ AttemptConnection: Connection successful!")

                // Show connection animation
                showConnectionAnimation(from: fromPosition, to: toPosition)

                // Update selection to new position
                gameViewModel.selectedPosition = toPosition
                gameViewModel.gameState.maze.clearSelections()
                gameViewModel.gameState.maze.selectCell(at: toPosition)

                // Update UI
                updateMazeGrid()
                updatePathDrawing()
                soundManager.playSound(.move)

                // Check if game is complete
                if gameState.status == .completed {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.showGameComplete()
                    }
                }
            } else {
                print("❌ AttemptConnection: Move failed")
                showInvalidMoveAnimation(at: toPosition)
            }
        } else {
            print("❌ AttemptConnection: Wrong number - expected \(requiredNumber), got \(toNumber)")
            showInvalidMoveAnimation(at: toPosition)
        }
    }

    private func showConnectionAnimation(from fromPosition: Position, to toPosition: Position) {
        print("🎬 ShowConnectionAnimation: From (\(fromPosition.row), \(fromPosition.col)) to (\(toPosition.row), \(toPosition.col))")

        // Prevent multiple connection animations
        let animationKey = "connection_\(fromPosition.row)_\(fromPosition.col)_to_\(toPosition.row)_\(toPosition.col)"
        if mazeGridView.layer.animation(forKey: animationKey) != nil {
            print("⚠️ ShowConnectionAnimation: Animation already running, skipping")
            return
        }

        // Get cell centers for animation
        let fromCenter = getCellCenter(for: fromPosition)
        let toCenter = getCellCenter(for: toPosition)

        // Create temporary line layer for animation
        let animationLayer = CAShapeLayer()
        animationLayer.strokeColor = UIColor.systemGreen.cgColor
        animationLayer.lineWidth = 6.0
        animationLayer.lineCap = .round

        // Create path from center to center
        let path = UIBezierPath()
        path.move(to: fromCenter)
        path.addLine(to: toCenter)
        animationLayer.path = path.cgPath

        // Add to maze grid view
        mazeGridView.layer.addSublayer(animationLayer)

        // Animate the line drawing
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        // Remove animation layer after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            animationLayer.removeFromSuperlayer()
        }

        animationLayer.add(animation, forKey: "drawLine")
    }

    private func showInvalidMoveAnimation(at position: Position) {
        print("❌ ShowInvalidMoveAnimation: At position (\(position.row), \(position.col))")

        guard position.row < mazeCells.count,
              position.col < mazeCells[position.row].count else { return }

        let cellView = mazeCells[position.row][position.col]

        // Prevent multiple animations on the same cell
        if cellView.layer.animation(forKey: "shake") != nil {
            print("⚠️ ShowInvalidMoveAnimation: Animation already running, skipping")
            return
        }

        // Shake animation
        let shakeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shakeAnimation.values = [0, -10, 10, -10, 10, 0]
        shakeAnimation.duration = 0.5
        shakeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        // Color flash animation
        let originalBackgroundColor = cellView.backgroundColor
        UIView.animate(withDuration: 0.2, animations: {
            cellView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.7)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                cellView.backgroundColor = originalBackgroundColor
            }
        }

        cellView.layer.add(shakeAnimation, forKey: "shake")
        soundManager.playSound(.error)
    }

    private func updatePathDrawing() {
        guard let gameState = gameViewModel?.gameState else {
            pathDrawingLayer.path = nil
            return
        }

        let path = UIBezierPath()
        let connections = gameState.path.connections

        // Draw existing path connections
        for connection in connections {
            let fromCenter = getCellCenter(for: connection.from)
            let toCenter = getCellCenter(for: connection.to)

            if path.isEmpty {
                path.move(to: fromCenter)
            }
            path.addLine(to: toCenter)
        }

        pathDrawingLayer.path = path.cgPath
    }

    private func getCellCenter(for position: Position) -> CGPoint {
        guard position.row < mazeCells.count,
              position.col < mazeCells[position.row].count else {
            return CGPoint.zero
        }

        let cellView = mazeCells[position.row][position.col]
        return CGPoint(x: cellView.frame.midX, y: cellView.frame.midY)
    }

    private func showGameComplete() {
        soundManager.playSound(.levelComplete)

        let alert = UIAlertController(title: "Congratulations!",
                                    message: "You completed the maze!",
                                    preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Next Level", style: .default) { _ in
            // TODO: Load next level
        })

        alert.addAction(UIAlertAction(title: "Main Menu", style: .default) { _ in
            self.exitTapped()
        })

        present(alert, animated: true)
    }
}
