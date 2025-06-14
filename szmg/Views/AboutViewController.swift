//
//  AboutViewController.swift
//  badx T DM
//
//  Created by AI Assistant on 2025/1/10.
//

import UIKit

class AboutViewController: UIViewController {

    // MARK: - Properties
    private let soundManager = SoundManager.shared
    private let purchaseManager = InAppPurchaseManager.shared

    // MARK: - UI Elements
    private let backgroundImageView = UIImageView()
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let logoImageView = UIImageView()
    private let backButton = UIButton(type: .system)
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Hero Section
    private let heroView = UIView()
    private let heroTitleLabel = UILabel()
    private let heroSubtitleLabel = UILabel()
    private let heroDescriptionLabel = UILabel()

    // Features Grid
    private let featuresLabel = UILabel()
    private let featuresStackView = UIStackView()
    private let feature1Card = FeatureCardView()
    private let feature2Card = FeatureCardView()
    private let feature3Card = FeatureCardView()
    private let feature4Card = FeatureCardView()

    // Development Timeline
    private let timelineLabel = UILabel()
    private let timelineView = TimelineView()

    // Community Section
    private let communityLabel = UILabel()
    private let communityStackView = UIStackView()
    private let feedbackButton = UIButton(type: .system)
    private let tutorialButton = UIButton(type: .system)
    private let faqButton = UIButton(type: .system)

    // Developer Support
    private let supportLabel = UILabel()
    private let supportDescriptionLabel = UILabel()
    private let supportStackView = UIStackView()
    private let donate99Button = UIButton(type: .system)
    private let donate199Button = UIButton(type: .system)

    // Footer
    private let footerView = UIView()
    private let versionLabel = UILabel()
    private let copyrightLabel = UILabel()
    private let thanksLabel = UILabel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    // MARK: - UI Setup
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
        setupHeroSection()
        setupFeaturesSection()
        setupTimelineSection()
        setupCommunitySection()
        setupSupportSection()
        setupFooter()
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

        // Logo
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(logoImageView)

        // Title
        titleLabel.text = "ℹ️ About Ddui Cdl puzzles"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)

        // Back button
        backButton.setTitle("← Back", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        backButton.backgroundColor = UIColor.systemBlue
        backButton.layer.cornerRadius = 12
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        backButton.layer.shadowRadius = 4
        backButton.layer.shadowOpacity = 0.2
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        headerView.addSubview(backButton)
    }

    private func setupScrollView() {
        // Scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
    }

    private func setupHeroSection() {
        // Hero view
        heroView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        heroView.layer.cornerRadius = 20
        heroView.layer.borderWidth = 1
        heroView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        heroView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(heroView)

        // Hero title
        heroTitleLabel.text = "Ddui Cdl puzzles"
        heroTitleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        heroTitleLabel.textColor = .label
        heroTitleLabel.textAlignment = .center
        heroTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        heroView.addSubview(heroTitleLabel)

        // Hero subtitle
        heroSubtitleLabel.text = "Connect • Solve • Master"
        heroSubtitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        heroSubtitleLabel.textColor = .systemBlue
        heroSubtitleLabel.textAlignment = .center
        heroSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        heroView.addSubview(heroSubtitleLabel)

        // Hero description
        heroDescriptionLabel.text = "A challenging puzzle game that tests your logic and problem-solving skills. Connect numbered cells in sequence, navigate through obstacles, and master increasingly complex puzzles."
        heroDescriptionLabel.font = UIFont.systemFont(ofSize: 16)
        heroDescriptionLabel.textColor = .secondaryLabel
        heroDescriptionLabel.numberOfLines = 0
        heroDescriptionLabel.textAlignment = .center
        heroDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        heroView.addSubview(heroDescriptionLabel)
    }
    
    private func setupFeaturesSection() {
        // Features label
        featuresLabel.text = "🎮 Game Features"
        featuresLabel.font = UIFont.boldSystemFont(ofSize: 24)
        featuresLabel.textColor = .label
        featuresLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(featuresLabel)

        // Features stack view
        featuresStackView.axis = .vertical
        featuresStackView.spacing = 16
        featuresStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(featuresStackView)

        // Configure feature cards
        feature1Card.configure(
            icon: "🧩",
            title: "Challenging Puzzles",
            description: "Multiple difficulty levels with increasingly complex puzzles that test your logic and problem-solving skills."
        )

        feature2Card.configure(
            icon: "📊",
            title: "Progress Tracking",
            description: "Detailed statistics and achievements system to track your improvement and celebrate milestones."
        )

        feature3Card.configure(
            icon: "🎨",
            title: "Beautiful Design",
            description: "Minimalist and elegant interface with smooth animations and intuitive touch controls."
        )

        feature4Card.configure(
            icon: "🏆",
            title: "Competitive Play",
            description: "Daily challenges, leaderboards, and achievements to compete with players worldwide."
        )

        // Create horizontal stack views for 2x2 grid
        let topRow = UIStackView(arrangedSubviews: [feature1Card, feature2Card])
        topRow.axis = .horizontal
        topRow.distribution = .fillEqually
        topRow.spacing = 16

        let bottomRow = UIStackView(arrangedSubviews: [feature3Card, feature4Card])
        bottomRow.axis = .horizontal
        bottomRow.distribution = .fillEqually
        bottomRow.spacing = 16

        featuresStackView.addArrangedSubview(topRow)
        featuresStackView.addArrangedSubview(bottomRow)
    }
    
    private func setupTimelineSection() {
        // Timeline label
        timelineLabel.text = "📅 Development Journey"
        timelineLabel.font = UIFont.boldSystemFont(ofSize: 24)
        timelineLabel.textColor = .label
        timelineLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timelineLabel)

        // Timeline view
        timelineView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timelineView)

        // Configure timeline items
        let timelineItems = [
            TimelineItem(
                date: "January 2025",
                title: "Project Inception",
                description: "Started development with the vision of creating an engaging puzzle game that challenges players' logical thinking.",
                icon: "💡",
                color: .systemBlue
            ),
            TimelineItem(
                date: "February 2025",
                title: "Core Gameplay",
                description: "Implemented the fundamental game mechanics, including grid-based puzzles and number connection logic.",
                icon: "🎮",
                color: .systemGreen
            ),
            TimelineItem(
                date: "March 2025",
                title: "UI/UX Design",
                description: "Designed the beautiful and intuitive user interface with smooth animations and responsive controls.",
                icon: "🎨",
                color: .systemPurple
            ),
            TimelineItem(
                date: "April 2025",
                title: "Beta Testing",
                description: "Conducted extensive testing with beta users to refine gameplay balance and fix bugs.",
                icon: "🧪",
                color: .systemOrange
            ),
            TimelineItem(
                date: "May 2025",
                title: "Launch Ready",
                description: "Final polishing, App Store submission, and preparing for the official launch to puzzle enthusiasts worldwide.",
                icon: "🚀",
                color: .systemRed
            )
        ]

        timelineView.configure(items: timelineItems)
    }

    private func setupCommunitySection() {
        // Community label
        communityLabel.text = "👥 Community & Support"
        communityLabel.font = UIFont.boldSystemFont(ofSize: 24)
        communityLabel.textColor = .label
        communityLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(communityLabel)

        // Community stack view
        communityStackView.axis = .horizontal
        communityStackView.distribution = .fillEqually
        communityStackView.spacing = 12
        communityStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(communityStackView)

        // Feedback button
        feedbackButton.setTitle("💬 Send Feedback", for: .normal)
        feedbackButton.setTitleColor(.white, for: .normal)
        feedbackButton.backgroundColor = .systemBlue
        feedbackButton.layer.cornerRadius = 12
        feedbackButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        feedbackButton.addTarget(self, action: #selector(feedbackTapped), for: .touchUpInside)

        // Tutorial button
        tutorialButton.setTitle("📚 Tutorial", for: .normal)
        tutorialButton.setTitleColor(.white, for: .normal)
        tutorialButton.backgroundColor = .systemGreen
        tutorialButton.layer.cornerRadius = 12
        tutorialButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        tutorialButton.addTarget(self, action: #selector(tutorialTapped), for: .touchUpInside)

        // FAQ button
        faqButton.setTitle("❓ FAQ", for: .normal)
        faqButton.setTitleColor(.white, for: .normal)
        faqButton.backgroundColor = .systemPurple
        faqButton.layer.cornerRadius = 12
        faqButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        faqButton.addTarget(self, action: #selector(faqTapped), for: .touchUpInside)

        communityStackView.addArrangedSubview(feedbackButton)
        communityStackView.addArrangedSubview(tutorialButton)
        communityStackView.addArrangedSubview(faqButton)
    }

    private func setupSupportSection() {
        // Support label
        supportLabel.text = "💝 Support the Developer"
        supportLabel.font = UIFont.boldSystemFont(ofSize: 24)
        supportLabel.textColor = .label
        supportLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(supportLabel)

        // Support description
        supportDescriptionLabel.text = "If you enjoy playing badx T DM, consider supporting the developer with a small donation. Your support helps us create more amazing games!"
        supportDescriptionLabel.font = UIFont.systemFont(ofSize: 16)
        supportDescriptionLabel.textColor = .secondaryLabel
        supportDescriptionLabel.numberOfLines = 0
        supportDescriptionLabel.textAlignment = .center
        supportDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(supportDescriptionLabel)

        // Support stack view
        supportStackView.axis = .horizontal
        supportStackView.distribution = .fillEqually
        supportStackView.spacing = 20
        supportStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(supportStackView)

        // Donation buttons
        setupDonationButton(donate99Button, title: "☕ Buy me a coffee\n$0.99", productId: "com.donagrt.099")
        setupDonationButton(donate199Button, title: "🍕 Buy me lunch\n$1.99", productId: "com.donagrt.199")

        supportStackView.addArrangedSubview(donate99Button)
        supportStackView.addArrangedSubview(donate199Button)
    }
    
    private func setupFooter() {
        // Footer view
        footerView.backgroundColor = UIColor.systemGray6
        footerView.layer.cornerRadius = 16
        footerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(footerView)

        // Version label
        versionLabel.text = "Version 1.0.0"
        versionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        versionLabel.textColor = .label
        versionLabel.textAlignment = .center
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(versionLabel)

        // Copyright label
        copyrightLabel.text = "© 2025 badx T DM. All rights reserved."
        copyrightLabel.font = UIFont.systemFont(ofSize: 14)
        copyrightLabel.textColor = .secondaryLabel
        copyrightLabel.textAlignment = .center
        copyrightLabel.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(copyrightLabel)

        // Thanks label
        thanksLabel.text = "Thank you for playing! 🎮❤️"
        thanksLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        thanksLabel.textColor = .systemBlue
        thanksLabel.textAlignment = .center
        thanksLabel.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(thanksLabel)
    }

    private func setupDonationButton(_ button: UIButton, title: String, productId: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = UIColor.systemGreen
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false

        button.addTarget(self, action: #selector(donationButtonTapped(_:)), for: .touchUpInside)
        button.accessibilityIdentifier = productId
    }
    

    
    // MARK: - Constraints
    private func setupConstraints() {
        let margin: CGFloat = 20
        let spacing: CGFloat = 30

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
            headerView.heightAnchor.constraint(equalToConstant: 100),

            logoImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 100),
            logoImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 60),
            logoImageView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: margin),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 80),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            // Scroll view
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Hero section
            heroView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin),
            heroView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            heroView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),

            heroTitleLabel.topAnchor.constraint(equalTo: heroView.topAnchor, constant: 30),
            heroTitleLabel.leadingAnchor.constraint(equalTo: heroView.leadingAnchor, constant: margin),
            heroTitleLabel.trailingAnchor.constraint(equalTo: heroView.trailingAnchor, constant: -margin),

            heroSubtitleLabel.topAnchor.constraint(equalTo: heroTitleLabel.bottomAnchor, constant: 8),
            heroSubtitleLabel.leadingAnchor.constraint(equalTo: heroView.leadingAnchor, constant: margin),
            heroSubtitleLabel.trailingAnchor.constraint(equalTo: heroView.trailingAnchor, constant: -margin),

            heroDescriptionLabel.topAnchor.constraint(equalTo: heroSubtitleLabel.bottomAnchor, constant: 16),
            heroDescriptionLabel.leadingAnchor.constraint(equalTo: heroView.leadingAnchor, constant: margin),
            heroDescriptionLabel.trailingAnchor.constraint(equalTo: heroView.trailingAnchor, constant: -margin),
            heroDescriptionLabel.bottomAnchor.constraint(equalTo: heroView.bottomAnchor, constant: -30),
        ])

        setupContentConstraints()
    }

    private func setupContentConstraints() {
        let margin: CGFloat = 20
        let spacing: CGFloat = 30

        NSLayoutConstraint.activate([
            // Features section
            featuresLabel.topAnchor.constraint(equalTo: heroView.bottomAnchor, constant: spacing),
            featuresLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            featuresLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),

            featuresStackView.topAnchor.constraint(equalTo: featuresLabel.bottomAnchor, constant: 16),
            featuresStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            featuresStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),

            // Timeline section
            timelineLabel.topAnchor.constraint(equalTo: featuresStackView.bottomAnchor, constant: spacing),
            timelineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            timelineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),

            timelineView.topAnchor.constraint(equalTo: timelineLabel.bottomAnchor, constant: 16),
            timelineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            timelineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),

            // Community section
            communityLabel.topAnchor.constraint(equalTo: timelineView.bottomAnchor, constant: spacing),
            communityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            communityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),

            communityStackView.topAnchor.constraint(equalTo: communityLabel.bottomAnchor, constant: 16),
            communityStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            communityStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            communityStackView.heightAnchor.constraint(equalToConstant: 50),

            // Support section
            supportLabel.topAnchor.constraint(equalTo: communityStackView.bottomAnchor, constant: spacing),
            supportLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            supportLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),

            supportDescriptionLabel.topAnchor.constraint(equalTo: supportLabel.bottomAnchor, constant: 16),
            supportDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            supportDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),

            supportStackView.topAnchor.constraint(equalTo: supportDescriptionLabel.bottomAnchor, constant: 20),
            supportStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            supportStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            supportStackView.heightAnchor.constraint(equalToConstant: 60),

            // Footer
            footerView.topAnchor.constraint(equalTo: supportStackView.bottomAnchor, constant: spacing),
            footerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            footerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            footerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margin),

            versionLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 20),
            versionLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: margin),
            versionLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -margin),

            copyrightLabel.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 8),
            copyrightLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: margin),
            copyrightLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -margin),

            thanksLabel.topAnchor.constraint(equalTo: copyrightLabel.bottomAnchor, constant: 8),
            thanksLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: margin),
            thanksLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -margin),
            thanksLabel.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -20),
        ])
    }

    // MARK: - Actions
    @objc private func backTapped() {
        soundManager.playUISound()
        navigationController?.popViewController(animated: true)
    }

    @objc private func feedbackTapped() {
        soundManager.playUISound()
        let alert = UIAlertController(title: "Send Feedback", message: "We'd love to hear from you! Please send your feedback to: feedback@example.com", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func tutorialTapped() {
        soundManager.playUISound()
        let alert = UIAlertController(title: "Tutorial", message: "Tutorial videos and guides are available on our website. Visit: tutorial.example.com", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func faqTapped() {
        soundManager.playUISound()
        let alert = UIAlertController(title: "FAQ", message: "Frequently Asked Questions:\n\n• How to play? Connect numbers in sequence\n• Stuck on a level? Use hints wisely\n• Lost progress? Check cloud sync in settings", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func donationButtonTapped(_ sender: UIButton) {
        soundManager.playUISound()

        guard let productId = sender.accessibilityIdentifier else { return }

        // Show loading indicator
        sender.isEnabled = false
        sender.setTitle("Processing...", for: .normal)

        // Attempt purchase
        purchaseManager.purchase(productIdentifier: productId, success: { [weak self] purchasedProductId in
            DispatchQueue.main.async {
                sender.isEnabled = true

                // Restore original title
                if productId == "com.donagrt.099" {
                    sender.setTitle("☕ Buy me a coffee - $0.99", for: .normal)
                } else {
                    sender.setTitle("🍕 Buy me lunch - $1.99", for: .normal)
                }

                // Show success message
                self?.showDonationAlert(title: "Thank You! 🙏", message: "Your support means the world to us! Thank you for helping us create more amazing games.")
            }
        }, failure: { [weak self] error in
            DispatchQueue.main.async {
                sender.isEnabled = true

                // Restore original title
                if productId == "com.donagrt.099" {
                    sender.setTitle("☕ Buy me a coffee - $0.99", for: .normal)
                } else {
                    sender.setTitle("🍕 Buy me lunch - $1.99", for: .normal)
                }

                // Show error message
                let errorMessage = error?.localizedDescription ?? "Unable to complete purchase. Please try again later."
                self?.showDonationAlert(title: "Purchase Failed", message: errorMessage)
            }
        })
    }

    private func showDonationAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
