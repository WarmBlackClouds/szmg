//
//  MainMenuViewController.swift
//  badx T DM
//
//  Created by AI Assistant on 2025/1/10.
//

import UIKit

class MainMenuViewController: UIViewController {

    // MARK: - Properties
    private let soundManager = SoundManager.shared
    private var selectedDifficulty: DifficultyLevel = .easy
    private var selectedGameMode: GameMode = .classic

    // MARK: - UI Elements
    private let backgroundImageView = UIImageView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Central Hub
    private let centralHubView = UIView()
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let userLevelLabel = UILabel()
    private let experienceProgressView = UIProgressView()

    // Weather Info
    private let weatherView = UIView()
    private let weatherIconLabel = UILabel()
    private let weatherLabel = UILabel()

    // Daily Tip
    private let dailyTipView = UIView()
    private let tipIconLabel = UILabel()
    private let dailyTipLabel = UILabel()

    // Recent Games Quick Access
    private let recentGamesView = UIView()
    private let recentGamesLabel = UILabel()
    private let recentGamesStackView = UIStackView()

    // Circular Menu Buttons (arranged in circle around center)
    private let circularMenuContainer = UIView()
    private let startGameButton = CircularMenuButton()
    private let quickPlayButton = CircularMenuButton()
    private let dailyChallengeButton = CircularMenuButton()
    private let settingsButton = CircularMenuButton()
    private let statisticsButton = CircularMenuButton()
    private let aboutButton = CircularMenuButton()

    // Difficulty & Mode Selection (floating panels)
    private let difficultyPanel = FloatingPanel()
    private let gameModePanel = FloatingPanel()

    // Social Share
    private let socialShareView = UIView()
    private let shareButton = UIButton(type: .system)
    private let inviteFriendsButton = UIButton(type: .system)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        updateUserLevel()
        updateWeatherInfo()
        updateDailyTip()
        soundManager.playMenuSounds()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUserLevel()
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

        setupScrollView()
        setupCentralHub()
        setupWeatherInfo()
        setupDailyTip()
        setupRecentGames()
        setupCircularMenu()
        setupFloatingPanels()
        setupSocialShare()
    }

    private func setupScrollView() {
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        // Setup content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 800), // Ensure enough height for circular layout
        ])
    }

    private func setupCentralHub() {
        // Central hub container
        centralHubView.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        centralHubView.layer.cornerRadius = 80
        centralHubView.layer.shadowColor = UIColor.black.cgColor
        centralHubView.layer.shadowOffset = CGSize(width: 0, height: 8)
        centralHubView.layer.shadowRadius = 16
        centralHubView.layer.shadowOpacity = 0.3
        centralHubView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(centralHubView)

        // Logo
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        centralHubView.addSubview(logoImageView)

        // Title
        titleLabel.text = "badx T DM"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        centralHubView.addSubview(titleLabel)

        // Subtitle
        subtitleLabel.text = "Connect & Solve"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = UIColor.darkGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        centralHubView.addSubview(subtitleLabel)

        // User level
        userLevelLabel.text = "Level 5 Puzzle Master"
        userLevelLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        userLevelLabel.textColor = .systemBlue
        userLevelLabel.textAlignment = .center
        userLevelLabel.translatesAutoresizingMaskIntoConstraints = false
        centralHubView.addSubview(userLevelLabel)

        // Experience progress
        experienceProgressView.progressTintColor = .systemBlue
        experienceProgressView.trackTintColor = .systemGray5
        experienceProgressView.progress = 0.65
        experienceProgressView.layer.cornerRadius = 2
        experienceProgressView.translatesAutoresizingMaskIntoConstraints = false
        centralHubView.addSubview(experienceProgressView)

        NSLayoutConstraint.activate([
            // Central hub constraints - positioned at top for mobile layout
            centralHubView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            centralHubView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 140),
            centralHubView.widthAnchor.constraint(equalToConstant: 160),
            centralHubView.heightAnchor.constraint(equalToConstant: 160),

            // Logo constraints
            logoImageView.topAnchor.constraint(equalTo: centralHubView.topAnchor, constant: 15),
            logoImageView.centerXAnchor.constraint(equalTo: centralHubView.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 50),
            logoImageView.widthAnchor.constraint(equalToConstant: 50),

            // Title constraints
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: centralHubView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: centralHubView.trailingAnchor, constant: -8),

            // Subtitle constraints
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: centralHubView.leadingAnchor, constant: 8),
            subtitleLabel.trailingAnchor.constraint(equalTo: centralHubView.trailingAnchor, constant: -8),

            // User level constraints
            userLevelLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            userLevelLabel.leadingAnchor.constraint(equalTo: centralHubView.leadingAnchor, constant: 8),
            userLevelLabel.trailingAnchor.constraint(equalTo: centralHubView.trailingAnchor, constant: -8),

            // Progress constraints
            experienceProgressView.topAnchor.constraint(equalTo: userLevelLabel.bottomAnchor, constant: 6),
            experienceProgressView.leadingAnchor.constraint(equalTo: centralHubView.leadingAnchor, constant: 20),
            experienceProgressView.trailingAnchor.constraint(equalTo: centralHubView.trailingAnchor, constant: -20),
            experienceProgressView.heightAnchor.constraint(equalToConstant: 4),
        ])
    }

    private func setupWeatherInfo() {
        // Weather view
        weatherView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.9)
        weatherView.layer.cornerRadius = 16
        weatherView.layer.shadowColor = UIColor.black.cgColor
        weatherView.layer.shadowOffset = CGSize(width: 0, height: 4)
        weatherView.layer.shadowRadius = 8
        weatherView.layer.shadowOpacity = 0.2
        weatherView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(weatherView)

        // Weather icon
        weatherIconLabel.text = "☀️"
        weatherIconLabel.font = UIFont.systemFont(ofSize: 24)
        weatherIconLabel.textAlignment = .center
        weatherIconLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherView.addSubview(weatherIconLabel)

        // Weather label
        weatherLabel.text = "Perfect puzzle weather!\n22°C Sunny"
        weatherLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        weatherLabel.textColor = .white
        weatherLabel.textAlignment = .center
        weatherLabel.numberOfLines = 2
        weatherLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherView.addSubview(weatherLabel)

        NSLayoutConstraint.activate([
            // Weather view constraints
            weatherView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            weatherView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            weatherView.widthAnchor.constraint(equalToConstant: 140),
            weatherView.heightAnchor.constraint(equalToConstant: 80),

            // Weather icon constraints
            weatherIconLabel.topAnchor.constraint(equalTo: weatherView.topAnchor, constant: 8),
            weatherIconLabel.centerXAnchor.constraint(equalTo: weatherView.centerXAnchor),

            // Weather label constraints
            weatherLabel.topAnchor.constraint(equalTo: weatherIconLabel.bottomAnchor, constant: 4),
            weatherLabel.leadingAnchor.constraint(equalTo: weatherView.leadingAnchor, constant: 8),
            weatherLabel.trailingAnchor.constraint(equalTo: weatherView.trailingAnchor, constant: -8),
            weatherLabel.bottomAnchor.constraint(equalTo: weatherView.bottomAnchor, constant: -8),
        ])
    }

    private func setupDailyTip() {
        // Daily tip view
        dailyTipView.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.9)
        dailyTipView.layer.cornerRadius = 16
        dailyTipView.layer.shadowColor = UIColor.black.cgColor
        dailyTipView.layer.shadowOffset = CGSize(width: 0, height: 4)
        dailyTipView.layer.shadowRadius = 8
        dailyTipView.layer.shadowOpacity = 0.2
        dailyTipView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dailyTipView)

        // Tip icon
        tipIconLabel.text = "💡"
        tipIconLabel.font = UIFont.systemFont(ofSize: 24)
        tipIconLabel.textAlignment = .center
        tipIconLabel.translatesAutoresizingMaskIntoConstraints = false
        dailyTipView.addSubview(tipIconLabel)

        // Daily tip label
        dailyTipLabel.text = "Daily Tip:\nStart from corners for\nbetter strategy!"
        dailyTipLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium) // Slightly smaller for better fit
        dailyTipLabel.textColor = .white
        dailyTipLabel.textAlignment = .center
        dailyTipLabel.numberOfLines = 4 // Allow more lines
        dailyTipLabel.adjustsFontSizeToFitWidth = true
        dailyTipLabel.minimumScaleFactor = 0.8
        dailyTipLabel.translatesAutoresizingMaskIntoConstraints = false
        dailyTipView.addSubview(dailyTipLabel)

        NSLayoutConstraint.activate([
            // Daily tip view constraints - increased size for better text display
            dailyTipView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            dailyTipView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dailyTipView.widthAnchor.constraint(equalToConstant: 160), // Increased width
            dailyTipView.heightAnchor.constraint(equalToConstant: 120), // Increased height

            // Tip icon constraints
            tipIconLabel.topAnchor.constraint(equalTo: dailyTipView.topAnchor, constant: 8),
            tipIconLabel.centerXAnchor.constraint(equalTo: dailyTipView.centerXAnchor),

            // Daily tip label constraints - more space for text
            dailyTipLabel.topAnchor.constraint(equalTo: tipIconLabel.bottomAnchor, constant: 6),
            dailyTipLabel.leadingAnchor.constraint(equalTo: dailyTipView.leadingAnchor, constant: 6),
            dailyTipLabel.trailingAnchor.constraint(equalTo: dailyTipView.trailingAnchor, constant: -6),
            dailyTipLabel.bottomAnchor.constraint(lessThanOrEqualTo: dailyTipView.bottomAnchor, constant: -8),
        ])
    }

    private func setupRecentGames() {
        // Recent games view
        recentGamesView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.9)
        recentGamesView.layer.cornerRadius = 16
        recentGamesView.layer.shadowColor = UIColor.black.cgColor
        recentGamesView.layer.shadowOffset = CGSize(width: 0, height: 4)
        recentGamesView.layer.shadowRadius = 8
        recentGamesView.layer.shadowOpacity = 0.2
        recentGamesView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(recentGamesView)

        // Recent games label
        recentGamesLabel.text = "🎮 Recent Games"
        recentGamesLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        recentGamesLabel.textColor = .white
        recentGamesLabel.textAlignment = .center
        recentGamesLabel.translatesAutoresizingMaskIntoConstraints = false
        recentGamesView.addSubview(recentGamesLabel)

        // Stack view for recent games
        recentGamesStackView.axis = .horizontal
        recentGamesStackView.distribution = .fillEqually
        recentGamesStackView.spacing = 8
        recentGamesStackView.translatesAutoresizingMaskIntoConstraints = false
        recentGamesView.addSubview(recentGamesStackView)

        // Add recent game buttons
        for i in 1...3 {
            let gameButton = UIButton(type: .system)
            gameButton.setTitle("L\(i)", for: .normal)
            gameButton.setTitleColor(.white, for: .normal)
            gameButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
            gameButton.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            gameButton.layer.cornerRadius = 8
            gameButton.tag = i
            gameButton.addTarget(self, action: #selector(recentGameTapped(_:)), for: .touchUpInside)
            recentGamesStackView.addArrangedSubview(gameButton)
        }

        NSLayoutConstraint.activate([
            // Recent games view constraints
            recentGamesView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            recentGamesView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recentGamesView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            recentGamesView.heightAnchor.constraint(equalToConstant: 80),

            // Recent games label constraints
            recentGamesLabel.topAnchor.constraint(equalTo: recentGamesView.topAnchor, constant: 8),
            recentGamesLabel.leadingAnchor.constraint(equalTo: recentGamesView.leadingAnchor, constant: 16),
            recentGamesLabel.trailingAnchor.constraint(equalTo: recentGamesView.trailingAnchor, constant: -16),

            // Stack view constraints
            recentGamesStackView.topAnchor.constraint(equalTo: recentGamesLabel.bottomAnchor, constant: 8),
            recentGamesStackView.leadingAnchor.constraint(equalTo: recentGamesView.leadingAnchor, constant: 16),
            recentGamesStackView.trailingAnchor.constraint(equalTo: recentGamesView.trailingAnchor, constant: -16),
            recentGamesStackView.bottomAnchor.constraint(equalTo: recentGamesView.bottomAnchor, constant: -8),
        ])
    }

    private func setupCircularMenu() {
        // Circular menu container
        circularMenuContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(circularMenuContainer)

        // Configure all buttons with larger size for better text display
        startGameButton.configure(icon: "▶️", title: "Start Game", color: .systemTeal) { [weak self] in
            self?.startGameTapped()
        }

        quickPlayButton.configure(icon: "⚡", title: "Quick Play", color: .systemOrange) { [weak self] in
            self?.quickPlayTapped()
        }

        dailyChallengeButton.configure(icon: "📅", title: "Daily Challenge", color: .systemPurple) { [weak self] in
            self?.dailyChallengeTapped()
        }

        settingsButton.configure(icon: "⚙️", title: "Settings", color: .systemBlue) { [weak self] in
            self?.settingsTapped()
        }

        statisticsButton.configure(icon: "📊", title: "Statistics", color: .systemIndigo) { [weak self] in
            self?.statisticsTapped()
        }

        aboutButton.configure(icon: "ℹ️", title: "About", color: .systemBrown) { [weak self] in
            self?.aboutTapped()
        }

        // Add all buttons to container
        [startGameButton, quickPlayButton, dailyChallengeButton, settingsButton, statisticsButton, aboutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            circularMenuContainer.addSubview($0)
        }

        setupCircularConstraints()
    }

    private func setupCircularConstraints() {
        let buttonSize: CGFloat = 100 // Larger size for better text display
        let radius: CGFloat = 140 // Distance from center

        NSLayoutConstraint.activate([
            // Container constraints
            circularMenuContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circularMenuContainer.centerYAnchor.constraint(equalTo: centralHubView.centerYAnchor),
            circularMenuContainer.widthAnchor.constraint(equalToConstant: radius * 2 + buttonSize),
            circularMenuContainer.heightAnchor.constraint(equalToConstant: radius * 2 + buttonSize),

            // Button size constraints
            startGameButton.widthAnchor.constraint(equalToConstant: buttonSize),
            startGameButton.heightAnchor.constraint(equalToConstant: buttonSize),
            quickPlayButton.widthAnchor.constraint(equalToConstant: buttonSize),
            quickPlayButton.heightAnchor.constraint(equalToConstant: buttonSize),
            dailyChallengeButton.widthAnchor.constraint(equalToConstant: buttonSize),
            dailyChallengeButton.heightAnchor.constraint(equalToConstant: buttonSize),
            settingsButton.widthAnchor.constraint(equalToConstant: buttonSize),
            settingsButton.heightAnchor.constraint(equalToConstant: buttonSize),
            statisticsButton.widthAnchor.constraint(equalToConstant: buttonSize),
            statisticsButton.heightAnchor.constraint(equalToConstant: buttonSize),
            aboutButton.widthAnchor.constraint(equalToConstant: buttonSize),
            aboutButton.heightAnchor.constraint(equalToConstant: buttonSize),
        ])

        // Position buttons in circle around center
        positionButtonsInCircle(radius: radius, buttonSize: buttonSize)
    }

    private func positionButtonsInCircle(radius: CGFloat, buttonSize: CGFloat) {
        let centerX = radius + buttonSize / 2
        let centerY = radius + buttonSize / 2

        // Calculate positions for 6 buttons around the circle
        let buttons = [startGameButton, quickPlayButton, dailyChallengeButton, settingsButton, statisticsButton, aboutButton]
        let angleStep = 2 * Double.pi / Double(buttons.count)

        for (index, button) in buttons.enumerated() {
            let angle = Double(index) * angleStep - Double.pi / 2 // Start from top
            let x = centerX + radius * cos(angle) - buttonSize / 2
            let y = centerY + radius * sin(angle) - buttonSize / 2

            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: circularMenuContainer.leadingAnchor, constant: x),
                button.topAnchor.constraint(equalTo: circularMenuContainer.topAnchor, constant: y)
            ])
        }
    }

    private func setupFloatingPanels() {
        // Difficulty panel
        difficultyPanel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(difficultyPanel)

        difficultyPanel.configure(
            title: "Difficulty",
            options: ["Easy 4×4", "Medium 6×6", "Hard 8×8"],
            selectedIndex: getDifficultyIndex(selectedDifficulty)
        ) { [weak self] index in
            self?.selectedDifficulty = DifficultyLevel.allCases[index]
            self?.soundManager.playUISound()
        }

        // Game mode panel
        gameModePanel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(gameModePanel)

        gameModePanel.configure(
            title: "Game Mode",
            options: ["Classic", "Challenge", "Daily"],
            selectedIndex: 0
        ) { [weak self] index in
            let modes: [GameMode] = [.classic, .challenge, .daily]
            self?.selectedGameMode = modes[index]
            self?.soundManager.playUISound()
        }

        NSLayoutConstraint.activate([
            // Difficulty panel constraints - positioned below circular menu with larger width
            difficultyPanel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            difficultyPanel.topAnchor.constraint(equalTo: circularMenuContainer.bottomAnchor, constant: 40),
            difficultyPanel.widthAnchor.constraint(equalToConstant: 280), // Increased width for better text display

            // Game mode panel constraints - positioned below circular menu with larger width
            gameModePanel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            gameModePanel.topAnchor.constraint(equalTo: circularMenuContainer.bottomAnchor, constant: 40),
            gameModePanel.widthAnchor.constraint(equalToConstant: 280), // Increased width for better text display
        ])
    }

    private func setupSocialShare() {
        // Social share view
        socialShareView.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.9)
        socialShareView.layer.cornerRadius = 16
        socialShareView.layer.shadowColor = UIColor.black.cgColor
        socialShareView.layer.shadowOffset = CGSize(width: 0, height: 4)
        socialShareView.layer.shadowRadius = 8
        socialShareView.layer.shadowOpacity = 0.2
        socialShareView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(socialShareView)

        // Share button
        shareButton.setTitle("📤 Share", for: .normal)
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        shareButton.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        shareButton.layer.cornerRadius = 8
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        socialShareView.addSubview(shareButton)

        // Invite friends button
        inviteFriendsButton.setTitle("👥 Invite", for: .normal)
        inviteFriendsButton.setTitleColor(.white, for: .normal)
        inviteFriendsButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        inviteFriendsButton.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        inviteFriendsButton.layer.cornerRadius = 8
        inviteFriendsButton.translatesAutoresizingMaskIntoConstraints = false
        inviteFriendsButton.addTarget(self, action: #selector(inviteFriendsTapped), for: .touchUpInside)
        socialShareView.addSubview(inviteFriendsButton)

        NSLayoutConstraint.activate([
            // Social share view constraints
            socialShareView.bottomAnchor.constraint(equalTo: recentGamesView.topAnchor, constant: -20),
            socialShareView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            socialShareView.widthAnchor.constraint(equalToConstant: 160),
            socialShareView.heightAnchor.constraint(equalToConstant: 60),

            // Share button constraints
            shareButton.leadingAnchor.constraint(equalTo: socialShareView.leadingAnchor, constant: 8),
            shareButton.centerYAnchor.constraint(equalTo: socialShareView.centerYAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 70),
            shareButton.heightAnchor.constraint(equalToConstant: 40),

            // Invite friends button constraints
            inviteFriendsButton.trailingAnchor.constraint(equalTo: socialShareView.trailingAnchor, constant: -8),
            inviteFriendsButton.centerYAnchor.constraint(equalTo: socialShareView.centerYAnchor),
            inviteFriendsButton.widthAnchor.constraint(equalToConstant: 70),
            inviteFriendsButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    // MARK: - Helper Methods
    private func getDifficultyIndex(_ difficulty: DifficultyLevel) -> Int {
        switch difficulty {
        case .easy: return 0
        case .medium: return 1
        case .hard: return 2
        }
    }

    private func updateUserLevel() {
        let gamesPlayed = UserDefaults.standard.integer(forKey: "gamesPlayed")
        let level = min(gamesPlayed / 10 + 1, 50) // Level up every 10 games, max level 50
        let progress = Float(gamesPlayed % 10) / 10.0

        let titles = ["Beginner", "Novice", "Puzzle Solver", "Expert", "Master", "Grandmaster"]
        let titleIndex = min(level / 10, titles.count - 1)

        userLevelLabel.text = "Level \(level) \(titles[titleIndex])"
        experienceProgressView.progress = progress
    }

    private func updateWeatherInfo() {
        let weatherConditions = [
            ("☀️", "Perfect puzzle weather!\n22°C Sunny"),
            ("⛅", "Great for puzzles!\n18°C Partly Cloudy"),
            ("🌧️", "Cozy puzzle time!\n15°C Rainy"),
            ("❄️", "Winter puzzling!\n5°C Snowy"),
            ("🌈", "Rainbow puzzle day!\n20°C Clear")
        ]

        let randomWeather = weatherConditions.randomElement()!
        weatherIconLabel.text = randomWeather.0
        weatherLabel.text = randomWeather.1
    }

    private func updateDailyTip() {
        let tips = [
            "Start from corners for\nbetter strategy!",
            "Look for number patterns\nto solve faster!",
            "Take breaks to keep\nyour mind fresh!",
            "Practice daily to\nimprove your skills!",
            "Use hints wisely to\nlearn new techniques!"
        ]

        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let tipIndex = dayOfYear % tips.count
        dailyTipLabel.text = "Daily Tip:\n\(tips[tipIndex])"
    }

    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }



    // MARK: - Button Actions
    @objc private func startGameTapped() {
        soundManager.playUISound()
        if selectedGameMode == .classic {
            let levelSelectVC = LevelSelectViewController(difficulty: selectedDifficulty, gameMode: selectedGameMode)
            navigationController?.pushViewController(levelSelectVC, animated: true)
        } else {
            let gameVC = GameViewController(gameMode: selectedGameMode, difficulty: selectedDifficulty)
            navigationController?.pushViewController(gameVC, animated: true)
        }
    }

    @objc private func quickPlayTapped() {
        soundManager.playUISound()
        selectedGameMode = .challenge
        let gameVC = GameViewController(gameMode: selectedGameMode, difficulty: selectedDifficulty)
        navigationController?.pushViewController(gameVC, animated: true)
    }

    @objc private func dailyChallengeTapped() {
        soundManager.playUISound()
        selectedGameMode = .daily
        let gameVC = GameViewController(gameMode: selectedGameMode, difficulty: selectedDifficulty)
        navigationController?.pushViewController(gameVC, animated: true)
    }


    @objc private func recentGameTapped(_ sender: UIButton) {
        soundManager.playUISound()
        // Load recent game based on sender.tag
        let gameVC = GameViewController(gameMode: .classic, difficulty: selectedDifficulty)
        navigationController?.pushViewController(gameVC, animated: true)
    }

    @objc private func shareTapped() {
        soundManager.playUISound()
        let shareText = "Check out this amazing puzzle game! 🧩"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = shareButton
        present(activityVC, animated: true)
    }

    @objc private func inviteFriendsTapped() {
        soundManager.playUISound()
        let inviteText = "Join me in solving puzzles! Download this amazing game: [App Store Link]"
        let activityVC = UIActivityViewController(activityItems: [inviteText], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = inviteFriendsButton
        present(activityVC, animated: true)
    }

    @objc private func settingsTapped() {
        soundManager.playUISound()
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }

    @objc private func statisticsTapped() {
        soundManager.playUISound()
        let statisticsVC = StatisticsViewController()
        navigationController?.pushViewController(statisticsVC, animated: true)
    }

    @objc private func aboutTapped() {
        soundManager.playUISound()
        let aboutVC = AboutViewController()
        navigationController?.pushViewController(aboutVC, animated: true)
    }



}
