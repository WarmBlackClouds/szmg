import UIKit

class StatisticsViewController: UIViewController {

    // MARK: - UI Elements
    private let backgroundImageView = UIImageView()
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let backButton = UIButton(type: .system)
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Dashboard Components
    private let summaryStackView = UIStackView()
    private let gamesPlayedSummary = StatisticsSummaryCard()
    private let winRateSummary = StatisticsSummaryCard()
    private let bestTimeSummary = StatisticsSummaryCard()
    private let totalTimeSummary = StatisticsSummaryCard()

    // Circular Progress Views
    private let progressStackView = UIStackView()
    private let winRateProgress = CircularProgressView()
    private let completionProgress = CircularProgressView()
    private let streakProgress = CircularProgressView()

    // Trend Chart
    private let trendChart = TrendChartView()

    // Achievements Section
    private let achievementsLabel = UILabel()
    private let achievementsStackView = UIStackView()
    private let firstWinBadge = AchievementBadgeView()
    private let speedDemonBadge = AchievementBadgeView()
    private let marathonBadge = AchievementBadgeView()
    private let perfectBadge = AchievementBadgeView()

    // Action Buttons
    private let actionStackView = UIStackView()
    private let shareStatsButton = UIButton(type: .system)
    private let resetStatsButton = UIButton(type: .system)
    private let exportDataButton = UIButton(type: .system)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadStatistics()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var shouldAutorotate: Bool {
        return true
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Background
        backgroundImageView.image = UIImage(named: "bg")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.alpha = 0.3
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)

        setupHeader()
        setupScrollView()
        setupSummaryCards()
        setupProgressViews()
        setupTrendChart()
        setupAchievements()
        setupActionButtons()
    }

    private func setupHeader() {
        // Header view
        headerView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        headerView.layer.cornerRadius = 16
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        headerView.layer.shadowRadius = 8
        headerView.layer.shadowOpacity = 0.1
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        // Title
        titleLabel.text = "📊 Statistics Dashboard"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)

        // Back Button
        backButton.setTitle("← Back", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        backButton.backgroundColor = UIColor.systemBlue
        backButton.layer.cornerRadius = 12
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        backButton.layer.shadowRadius = 4
        backButton.layer.shadowOpacity = 0.2
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(backButton)
    }

    private func setupScrollView() {
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
    }
    
    private func setupSummaryCards() {
        // Summary stack view
        summaryStackView.axis = .horizontal
        summaryStackView.distribution = .fillEqually
        summaryStackView.spacing = 12
        summaryStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(summaryStackView)

        // Add summary cards
        summaryStackView.addArrangedSubview(gamesPlayedSummary)
        summaryStackView.addArrangedSubview(winRateSummary)
        summaryStackView.addArrangedSubview(bestTimeSummary)
        summaryStackView.addArrangedSubview(totalTimeSummary)
    }

    private func setupProgressViews() {
        // Progress stack view
        progressStackView.axis = .horizontal
        progressStackView.distribution = .fillEqually
        progressStackView.spacing = 20
        progressStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(progressStackView)

        // Add progress views
        progressStackView.addArrangedSubview(winRateProgress)
        progressStackView.addArrangedSubview(completionProgress)
        progressStackView.addArrangedSubview(streakProgress)
    }

    private func setupTrendChart() {
        trendChart.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(trendChart)
    }

    private func setupAchievements() {
        // Achievements label
        achievementsLabel.text = "🏆 Achievements"
        achievementsLabel.font = UIFont.boldSystemFont(ofSize: 20)
        achievementsLabel.textColor = .label
        achievementsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(achievementsLabel)

        // Achievements stack view
        achievementsStackView.axis = .vertical
        achievementsStackView.spacing = 12
        achievementsStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(achievementsStackView)

        // Add achievement badges
        achievementsStackView.addArrangedSubview(firstWinBadge)
        achievementsStackView.addArrangedSubview(speedDemonBadge)
        achievementsStackView.addArrangedSubview(marathonBadge)
        achievementsStackView.addArrangedSubview(perfectBadge)
    }

    private func setupActionButtons() {
        // Action stack view
        actionStackView.axis = .horizontal
        actionStackView.distribution = .fillEqually
        actionStackView.spacing = 12
        actionStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(actionStackView)

        // Share stats button
        shareStatsButton.setTitle("📤 Share Stats", for: .normal)
        shareStatsButton.setTitleColor(.white, for: .normal)
        shareStatsButton.backgroundColor = .systemBlue
        shareStatsButton.layer.cornerRadius = 12
        shareStatsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        shareStatsButton.addTarget(self, action: #selector(shareStatsTapped), for: .touchUpInside)

        // Reset stats button
        resetStatsButton.setTitle("🔄 Reset Stats", for: .normal)
        resetStatsButton.setTitleColor(.white, for: .normal)
        resetStatsButton.backgroundColor = .systemOrange
        resetStatsButton.layer.cornerRadius = 12
        resetStatsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        resetStatsButton.addTarget(self, action: #selector(resetStatsTapped), for: .touchUpInside)

        // Export data button
        exportDataButton.setTitle("💾 Export Data", for: .normal)
        exportDataButton.setTitleColor(.white, for: .normal)
        exportDataButton.backgroundColor = .systemGreen
        exportDataButton.layer.cornerRadius = 12
        exportDataButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        exportDataButton.addTarget(self, action: #selector(exportDataTapped), for: .touchUpInside)

        actionStackView.addArrangedSubview(shareStatsButton)
        actionStackView.addArrangedSubview(resetStatsButton)
        actionStackView.addArrangedSubview(exportDataButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 70),

            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 80),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            // Scroll View
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        setupContentConstraints()
    }
    
    private func setupContentConstraints() {
        let margin: CGFloat = 20
        let spacing: CGFloat = 20

        NSLayoutConstraint.activate([
            // Summary cards - increased height for better text display
            summaryStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin),
            summaryStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            summaryStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            summaryStackView.heightAnchor.constraint(equalToConstant: 140), // Increased height

            // Progress views
            progressStackView.topAnchor.constraint(equalTo: summaryStackView.bottomAnchor, constant: spacing),
            progressStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            progressStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            progressStackView.heightAnchor.constraint(equalToConstant: 140),

            // Trend chart
            trendChart.topAnchor.constraint(equalTo: progressStackView.bottomAnchor, constant: spacing),
            trendChart.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            trendChart.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            trendChart.heightAnchor.constraint(equalToConstant: 200),

            // Achievements label
            achievementsLabel.topAnchor.constraint(equalTo: trendChart.bottomAnchor, constant: spacing),
            achievementsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            achievementsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),

            // Achievements stack
            achievementsStackView.topAnchor.constraint(equalTo: achievementsLabel.bottomAnchor, constant: 12),
            achievementsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            achievementsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),

            // Action buttons
            actionStackView.topAnchor.constraint(equalTo: achievementsStackView.bottomAnchor, constant: spacing),
            actionStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            actionStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            actionStackView.heightAnchor.constraint(equalToConstant: 50),
            actionStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margin),
        ])
    }
    
    private func loadStatistics() {
        let defaults = UserDefaults.standard

        let gamesPlayed = defaults.integer(forKey: "gamesPlayed")
        let gamesWon = defaults.integer(forKey: "gamesWon")
        let bestTime = defaults.integer(forKey: "bestTime")
        let totalTime = defaults.integer(forKey: "totalPlayTime")
        let hintsUsed = defaults.integer(forKey: "totalHintsUsed")

        let winRate = gamesPlayed > 0 ? (Double(gamesWon) / Double(gamesPlayed) * 100) : 0

        // Update summary cards
        gamesPlayedSummary.configure(
            icon: "🎮",
            title: "Games Played",
            value: "\(gamesPlayed)",
            change: "+5 this week",
            isPositive: true
        )

        winRateSummary.configure(
            icon: "🏆",
            title: "Win Rate",
            value: String(format: "%.1f%%", winRate),
            change: "+2.3%",
            isPositive: true
        )

        let bestTimeString = bestTime > 0 ? String(format: "%02d:%02d", bestTime / 60, bestTime % 60) : "--:--"
        bestTimeSummary.configure(
            icon: "⏱️",
            title: "Best Time",
            value: bestTimeString,
            change: "-15s",
            isPositive: true
        )

        let hours = totalTime / 3600
        let minutes = (totalTime % 3600) / 60
        totalTimeSummary.configure(
            icon: "⏰",
            title: "Total Time",
            value: "\(hours)h \(minutes)m",
            change: "+2h this week",
            isPositive: true
        )

        // Update circular progress views
        winRateProgress.configure(
            title: "Win Rate",
            value: String(format: "%.0f%%", winRate),
            progress: Float(winRate / 100),
            color: .systemGreen
        )

        let completionRate = gamesPlayed > 0 ? Float(gamesWon) / Float(gamesPlayed) : 0
        completionProgress.configure(
            title: "Completion\nRate",
            value: String(format: "%.0f%%", completionRate * 100),
            progress: completionRate,
            color: .systemBlue
        )

        let currentStreak = defaults.integer(forKey: "currentStreak")
        let maxStreak = max(currentStreak, 10) // Assume max streak of 10 for demo
        streakProgress.configure(
            title: "Current\nStreak",
            value: "\(currentStreak)",
            progress: Float(currentStreak) / Float(maxStreak),
            color: .systemOrange
        )

        // Update trend chart with sample data
        let trendData: [CGFloat] = [20, 35, 45, 30, 55, 65, 50, 70, 80, 75]
        trendChart.configure(title: "Performance Trend (Last 10 Games)", dataPoints: trendData)

        // Update achievements
        updateAchievements(gamesPlayed: gamesPlayed, gamesWon: gamesWon, bestTime: bestTime, totalTime: totalTime)
    }

    private func updateAchievements(gamesPlayed: Int, gamesWon: Int, bestTime: Int, totalTime: Int) {
        // First Win achievement
        firstWinBadge.configure(
            icon: "🥇",
            title: "First Victory",
            description: "Win your first game",
            progress: gamesWon > 0 ? 1.0 : 0.0,
            isUnlocked: gamesWon > 0
        )

        // Speed Demon achievement
        let speedTarget = 300 // 5 minutes
        let speedProgress = bestTime > 0 && bestTime <= speedTarget ? 1.0 : (bestTime > 0 ? max(0, 1.0 - Float(bestTime - speedTarget) / Float(speedTarget)) : 0.0)
        speedDemonBadge.configure(
            icon: "⚡",
            title: "Speed Demon",
            description: "Complete a game in under 5 minutes",
            progress: speedProgress,
            isUnlocked: bestTime > 0 && bestTime <= speedTarget
        )

        // Marathon achievement
        let marathonTarget = 3600 // 1 hour
        marathonBadge.configure(
            icon: "🏃",
            title: "Marathon Player",
            description: "Play for over 1 hour total",
            progress: min(1.0, Float(totalTime) / Float(marathonTarget)),
            isUnlocked: totalTime >= marathonTarget
        )

        // Perfect achievement
        let perfectTarget = 10
        perfectBadge.configure(
            icon: "💎",
            title: "Perfect Player",
            description: "Win 10 games in a row",
            progress: min(1.0, Float(gamesWon) / Float(perfectTarget)),
            isUnlocked: gamesWon >= perfectTarget
        )
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func shareStatsTapped() {
        let defaults = UserDefaults.standard
        let gamesPlayed = defaults.integer(forKey: "gamesPlayed")
        let gamesWon = defaults.integer(forKey: "gamesWon")
        let winRate = gamesPlayed > 0 ? (Double(gamesWon) / Double(gamesPlayed) * 100) : 0

        let shareText = """
        🎮 My Game Statistics:

        Games Played: \(gamesPlayed)
        Games Won: \(gamesWon)
        Win Rate: \(String(format: "%.1f%%", winRate))

        Challenge me to beat these stats! 🏆
        """

        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = shareStatsButton
        present(activityVC, animated: true)
    }

    @objc private func resetStatsTapped() {
        let alert = UIAlertController(title: "Reset Statistics", message: "This will permanently delete all your game statistics. This action cannot be undone.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
            self.resetAllStatistics()
        })

        present(alert, animated: true)
    }

    @objc private func exportDataTapped() {
        let defaults = UserDefaults.standard
        let statisticsData = [
            "gamesPlayed": defaults.integer(forKey: "gamesPlayed"),
            "gamesWon": defaults.integer(forKey: "gamesWon"),
            "bestTime": defaults.integer(forKey: "bestTime"),
            "totalPlayTime": defaults.integer(forKey: "totalPlayTime"),
            "totalHintsUsed": defaults.integer(forKey: "totalHintsUsed"),
            "currentStreak": defaults.integer(forKey: "currentStreak")
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: statisticsData, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""

            let activityVC = UIActivityViewController(activityItems: [jsonString], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = exportDataButton
            present(activityVC, animated: true)
        } catch {
            let alert = UIAlertController(title: "Export Failed", message: "Failed to export statistics data.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    private func resetAllStatistics() {
        let defaults = UserDefaults.standard
        let statisticsKeys = ["gamesPlayed", "gamesWon", "bestTime", "totalPlayTime", "totalHintsUsed", "currentStreak"]

        for key in statisticsKeys {
            defaults.removeObject(forKey: key)
        }

        // Reload the statistics display
        loadStatistics()

        let alert = UIAlertController(title: "Statistics Reset", message: "All statistics have been reset successfully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
