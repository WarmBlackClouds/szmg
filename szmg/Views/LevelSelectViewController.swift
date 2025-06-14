//
//  LevelSelectViewController.swift
//  badx T DM
//
//  Created by AI Assistant on 2025/1/10.
//

import UIKit

class LevelSelectViewController: UIViewController {
    
    // MARK: - Properties
    private let difficulty: DifficultyLevel
    private let gameMode: GameMode
    private let soundManager = SoundManager.shared
    
    // MARK: - UI Elements
    private let backgroundImageView = UIImageView()
    private let titleLabel = UILabel()
    private let backButton = UIButton(type: .system)
    private let difficultyLabel = UILabel()
    private let collectionView: UICollectionView
    
    // Data
    private var maxUnlockedLevel: Int = 1
    private let totalLevels: Int = 50
    
    // MARK: - Initialization
    init(difficulty: DifficultyLevel, gameMode: GameMode) {
        self.difficulty = difficulty
        self.gameMode = gameMode
        
        // Setup collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProgress()
        setupUI()
        setupConstraints()
        setupCollectionView()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    // MARK: - UI Setup
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
        
        // Title
        titleLabel.text = "Select Level"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Back button
        backButton.setTitle("← Back", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        backButton.backgroundColor = UIColor.systemBlue
        backButton.layer.cornerRadius = 10
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(backButton)

        // Difficulty label
        difficultyLabel.text = "\(difficulty.rawValue) Mode - \(difficulty.gridSize)×\(difficulty.gridSize)"
        difficultyLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        difficultyLabel.textColor = UIColor.darkGray
        difficultyLabel.textAlignment = .center
        difficultyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(difficultyLabel)
        
        // Collection view
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(LevelCell.self, forCellWithReuseIdentifier: "LevelCell")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Back button
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 100),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Difficulty label
            difficultyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            difficultyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Collection view
            collectionView.topAnchor.constraint(equalTo: difficultyLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    // MARK: - Data Management
    private func loadProgress() {
        let key = "maxLevel_\(difficulty.rawValue)"
        maxUnlockedLevel = UserDefaults.standard.integer(forKey: key)
        if maxUnlockedLevel == 0 {
            maxUnlockedLevel = 1 // First level is always unlocked
        }
    }
    
    // MARK: - Actions
    @objc private func backTapped() {
        soundManager.playUISound()
        navigationController?.popViewController(animated: true)
    }
    
    private func selectLevel(_ level: Int) {
        soundManager.playUISound()
        let gameVC = GameViewController(gameMode: gameMode, difficulty: difficulty, level: level)
        navigationController?.pushViewController(gameVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension LevelSelectViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalLevels
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LevelCell", for: indexPath) as! LevelCell
        
        let level = indexPath.item + 1
        let isUnlocked = level <= maxUnlockedLevel
        let isCompleted = level < maxUnlockedLevel
        
        cell.configure(level: level, isUnlocked: isUnlocked, isCompleted: isCompleted)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension LevelSelectViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let level = indexPath.item + 1
        
        if level <= maxUnlockedLevel {
            selectLevel(level)
        } else {
            // Show locked level alert
            let alert = UIAlertController(title: "Level Locked", message: "Complete previous levels to unlock this one.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension LevelSelectViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 8
        let spacing: CGFloat = 10
        let totalSpacing = (itemsPerRow - 1) * spacing + 40 // 40 for section insets
        let availableWidth = collectionView.frame.width - totalSpacing
        let itemWidth = availableWidth / itemsPerRow
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
}

// MARK: - LevelCell
class LevelCell: UICollectionViewCell {
    private let levelLabel = UILabel()
    private let starImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        layer.cornerRadius = 10
        layer.borderWidth = 2
        
        // Level label
        levelLabel.textAlignment = .center
        levelLabel.font = UIFont.boldSystemFont(ofSize: 18)
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(levelLabel)
        
        // Star image
        starImageView.image = UIImage(systemName: "star.fill")
        starImageView.tintColor = .systemYellow
        starImageView.contentMode = .scaleAspectFit
        starImageView.translatesAutoresizingMaskIntoConstraints = false
        starImageView.isHidden = true
        contentView.addSubview(starImageView)
        
        NSLayoutConstraint.activate([
            levelLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            levelLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            starImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            starImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            starImageView.widthAnchor.constraint(equalToConstant: 15),
            starImageView.heightAnchor.constraint(equalToConstant: 15),
        ])
    }
    
    func configure(level: Int, isUnlocked: Bool, isCompleted: Bool) {
        levelLabel.text = "\(level)"
        
        if isUnlocked {
            backgroundColor = isCompleted ? UIColor.systemGreen : UIColor.systemBlue
            layer.borderColor = UIColor.systemGray2.cgColor
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 4
            layer.shadowOpacity = 0.25
            levelLabel.textColor = .white
            starImageView.isHidden = !isCompleted
        } else {
            backgroundColor = UIColor.systemGray3
            layer.borderColor = UIColor.systemGray.cgColor
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 1)
            layer.shadowRadius = 2
            layer.shadowOpacity = 0.15
            levelLabel.textColor = UIColor.systemGray
            starImageView.isHidden = true
        }
    }
}
