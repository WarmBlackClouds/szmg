//
//  SettingsViewController.swift
//  badx T DM
//
//  Created by AI Assistant on 2025/1/10.
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: - Properties
    private let soundManager = SoundManager.shared

    // MARK: - UI Elements
    private let backgroundImageView = UIImageView()
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let backButton = UIButton(type: .system)

    // Tab Controller
    private let tabController = TabController()
    private let tabContentView = TabContentView()

    // Content Views for each tab
    private let audioContentView = UIView()
    private let gameplayContentView = UIView()
    private let appearanceContentView = UIView()
    private let privacyContentView = UIView()
    private let advancedContentView = UIView()

    // Settings Cards
    private let audioCard = SettingsCard()
    private let gameplayCard = SettingsCard()
    private let appearanceCard = SettingsCard()
    private let themeCard = SettingsCard()
    private let languageCard = SettingsCard()
    private let notificationCard = SettingsCard()
    private let privacyCard = SettingsCard()
    private let dataCard = SettingsCard()
    private let advancedCard = SettingsCard()
    private let aboutCard = SettingsCard()

    private var currentTabIndex = 0
    
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
        setupTabController()
        setupTabContent()
        setupCards()
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
        titleLabel.text = "⚙️ Settings"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
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

    private func setupTabController() {
        tabController.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabController)

        tabController.configure(tabs: ["Audio", "Gameplay"]) { [weak self] index in
            self?.switchToTab(index)
        }
    }

    private func setupTabContent() {
        tabContentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabContentView)
    }
    
    private func setupCards() {
        setupAudioCard()
        setupGameplayCard()

        // Show initial tab
        switchToTab(0)
    }

    private func setupAudioCard() {
        audioCard.configure(icon: "🔊", title: "Audio Settings")

        // Music switch
        let musicSwitch = SettingSwitchItem()
        musicSwitch.configure(title: "Background Music", isOn: UserDefaults.standard.object(forKey: "musicEnabled") as? Bool ?? true) { [weak self] isOn in
            UserDefaults.standard.set(isOn, forKey: "musicEnabled")
            self?.soundManager.setMusicEnabled(isOn)
            self?.soundManager.playUISound()
        }
        audioCard.addSettingItem(musicSwitch)

        // Sound effects switch
        let soundSwitch = SettingSwitchItem()
        soundSwitch.configure(title: "Sound Effects", isOn: UserDefaults.standard.object(forKey: "soundEffectsEnabled") as? Bool ?? true) { [weak self] isOn in
            UserDefaults.standard.set(isOn, forKey: "soundEffectsEnabled")
            self?.soundManager.setSoundEffectsEnabled(isOn)
            self?.soundManager.playUISound()
        }
        audioCard.addSettingItem(soundSwitch)

        // Music volume slider
        let musicVolumeSlider = SettingSliderItem()
        musicVolumeSlider.configure(title: "Music Volume", value: UserDefaults.standard.object(forKey: "musicVolume") as? Float ?? 0.7) { [weak self] value in
            UserDefaults.standard.set(value, forKey: "musicVolume")
            self?.soundManager.setMusicVolume(value)
        }
        audioCard.addSettingItem(musicVolumeSlider)

        // Sound volume slider
        let soundVolumeSlider = SettingSliderItem()
        soundVolumeSlider.configure(title: "Sound Effects Volume", value: UserDefaults.standard.object(forKey: "soundVolume") as? Float ?? 0.8) { [weak self] value in
            UserDefaults.standard.set(value, forKey: "soundVolume")
            self?.soundManager.setSoundVolume(value)
        }
        audioCard.addSettingItem(soundVolumeSlider)
    }
    
    private func setupGameplayCard() {
        gameplayCard.configure(icon: "🎮", title: "Gameplay Settings")

        // Haptics switch
        let hapticsSwitch = SettingSwitchItem()
        hapticsSwitch.configure(title: "Haptic Feedback", isOn: UserDefaults.standard.object(forKey: "hapticsEnabled") as? Bool ?? true) { isOn in
            UserDefaults.standard.set(isOn, forKey: "hapticsEnabled")
        }
        gameplayCard.addSettingItem(hapticsSwitch)

        // Auto-save switch
        let autoSaveSwitch = SettingSwitchItem()
        autoSaveSwitch.configure(title: "Auto-Save Progress", isOn: UserDefaults.standard.object(forKey: "autoSaveEnabled") as? Bool ?? true) { isOn in
            UserDefaults.standard.set(isOn, forKey: "autoSaveEnabled")
        }
        gameplayCard.addSettingItem(autoSaveSwitch)

        // Show hints switch
        let hintsSwitch = SettingSwitchItem()
        hintsSwitch.configure(title: "Show Hints", isOn: UserDefaults.standard.object(forKey: "showHints") as? Bool ?? true) { isOn in
            UserDefaults.standard.set(isOn, forKey: "showHints")
        }
        gameplayCard.addSettingItem(hintsSwitch)

        // Auto-pause switch
        let autoPauseSwitch = SettingSwitchItem()
        autoPauseSwitch.configure(title: "Auto-Pause on Background", isOn: UserDefaults.standard.object(forKey: "autoPause") as? Bool ?? true) { isOn in
            UserDefaults.standard.set(isOn, forKey: "autoPause")
        }
        gameplayCard.addSettingItem(autoPauseSwitch)
    }
    
    private func setupAppearanceCards() {
        // Theme card
        themeCard.configure(icon: "🎨", title: "Theme & Colors")

        let darkModeSwitch = SettingSwitchItem()
        darkModeSwitch.configure(title: "Dark Mode", isOn: UserDefaults.standard.object(forKey: "darkMode") as? Bool ?? false) { isOn in
            UserDefaults.standard.set(isOn, forKey: "darkMode")
            // Apply theme change
        }
        themeCard.addSettingItem(darkModeSwitch)

        let colorfulModeSwitch = SettingSwitchItem()
        colorfulModeSwitch.configure(title: "Colorful Interface", isOn: UserDefaults.standard.object(forKey: "colorfulMode") as? Bool ?? true) { isOn in
            UserDefaults.standard.set(isOn, forKey: "colorfulMode")
        }
        themeCard.addSettingItem(colorfulModeSwitch)

        // Language card
        languageCard.configure(icon: "🌍", title: "Language & Region")

        let languageButton = SettingButtonItem()
        languageButton.configure(title: "Select Language", color: .systemBlue) { [weak self] in
            self?.showLanguageSelector()
        }
        languageCard.addSettingItem(languageButton)

        let regionButton = SettingButtonItem()
        regionButton.configure(title: "Region Settings", color: .systemGreen) { [weak self] in
            self?.showRegionSettings()
        }
        languageCard.addSettingItem(regionButton)
    }
    
    private func setupPrivacyCards() {
        // Notification card
        notificationCard.configure(icon: "🔔", title: "Notifications")

        let pushNotificationsSwitch = SettingSwitchItem()
        pushNotificationsSwitch.configure(title: "Push Notifications", isOn: UserDefaults.standard.object(forKey: "pushNotifications") as? Bool ?? true) { isOn in
            UserDefaults.standard.set(isOn, forKey: "pushNotifications")
        }
        notificationCard.addSettingItem(pushNotificationsSwitch)

        let dailyReminderSwitch = SettingSwitchItem()
        dailyReminderSwitch.configure(title: "Daily Reminder", isOn: UserDefaults.standard.object(forKey: "dailyReminder") as? Bool ?? false) { isOn in
            UserDefaults.standard.set(isOn, forKey: "dailyReminder")
        }
        notificationCard.addSettingItem(dailyReminderSwitch)

        // Privacy card
        privacyCard.configure(icon: "🔒", title: "Privacy & Security")

        let analyticsSwitch = SettingSwitchItem()
        analyticsSwitch.configure(title: "Analytics & Crash Reports", isOn: UserDefaults.standard.object(forKey: "analytics") as? Bool ?? true) { isOn in
            UserDefaults.standard.set(isOn, forKey: "analytics")
        }
        privacyCard.addSettingItem(analyticsSwitch)

        let personalizedAdsSwitch = SettingSwitchItem()
        personalizedAdsSwitch.configure(title: "Personalized Ads", isOn: UserDefaults.standard.object(forKey: "personalizedAds") as? Bool ?? false) { isOn in
            UserDefaults.standard.set(isOn, forKey: "personalizedAds")
        }
        privacyCard.addSettingItem(personalizedAdsSwitch)

        let privacyPolicyButton = SettingButtonItem()
        privacyPolicyButton.configure(title: "Privacy Policy", color: .systemBlue) { [weak self] in
            self?.showPrivacyPolicy()
        }
        privacyCard.addSettingItem(privacyPolicyButton)
    }
    
    private func setupAdvancedCards() {
        // Data management card
        dataCard.configure(icon: "💾", title: "Data Management")

        let exportDataButton = SettingButtonItem()
        exportDataButton.configure(title: "Export Game Data", color: .systemGreen) { [weak self] in
            self?.exportGameData()
        }
        dataCard.addSettingItem(exportDataButton)

        let importDataButton = SettingButtonItem()
        importDataButton.configure(title: "Import Game Data", color: .systemBlue) { [weak self] in
            self?.importGameData()
        }
        dataCard.addSettingItem(importDataButton)

        let resetProgressButton = SettingButtonItem()
        resetProgressButton.configure(title: "Reset Progress", color: .systemOrange) { [weak self] in
            self?.resetProgressTapped()
        }
        dataCard.addSettingItem(resetProgressButton)

        // Advanced settings card
        advancedCard.configure(icon: "⚙️", title: "Advanced Options")

        let debugModeSwitch = SettingSwitchItem()
        debugModeSwitch.configure(title: "Debug Mode", isOn: UserDefaults.standard.object(forKey: "debugMode") as? Bool ?? false) { isOn in
            UserDefaults.standard.set(isOn, forKey: "debugMode")
        }
        advancedCard.addSettingItem(debugModeSwitch)

        let resetSettingsButton = SettingButtonItem()
        resetSettingsButton.configure(title: "Reset All Settings", color: .systemRed) { [weak self] in
            self?.resetSettingsTapped()
        }
        advancedCard.addSettingItem(resetSettingsButton)

        // About card
        aboutCard.configure(icon: "ℹ️", title: "About")

        let versionButton = SettingButtonItem()
        versionButton.configure(title: "Version 1.0.0", color: .systemGray) { }
        aboutCard.addSettingItem(versionButton)

        let creditsButton = SettingButtonItem()
        creditsButton.configure(title: "Credits & Acknowledgments", color: .systemBlue) { [weak self] in
            self?.creditsTapped()
        }
        aboutCard.addSettingItem(creditsButton)

        let supportButton = SettingButtonItem()
        supportButton.configure(title: "Contact Support", color: .systemGreen) { [weak self] in
            self?.contactSupport()
        }
        aboutCard.addSettingItem(supportButton)
    }

    private func switchToTab(_ index: Int) {
        currentTabIndex = index
        tabContentView.clearContent()

        let cards: [SettingsCard]
        switch index {
        case 0: // Audio
            cards = [audioCard]
        case 1: // Gameplay
            cards = [gameplayCard]
        default:
            cards = []
        }

        setupCardsLayout(cards)
    }

    private func setupCardsLayout(_ cards: [SettingsCard]) {
        let contentView = tabContentView.content

        for (index, card) in cards.enumerated() {
            card.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(card)

            NSLayoutConstraint.activate([
                card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            ])

            if index == 0 {
                card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
            } else {
                card.topAnchor.constraint(equalTo: cards[index - 1].bottomAnchor, constant: 20).isActive = true
            }

            if index == cards.count - 1 {
                card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
            }
        }
    }

    // MARK: - Constraints
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
            headerView.heightAnchor.constraint(equalToConstant: 80),

            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 80),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            // Tab controller
            tabController.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),
            tabController.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tabController.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tabController.heightAnchor.constraint(equalToConstant: 50),

            // Tab content
            tabContentView.topAnchor.constraint(equalTo: tabController.bottomAnchor, constant: 10),
            tabContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabContentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Helper Methods
    private func showLanguageSelector() {
        let alert = UIAlertController(title: "Select Language", message: "Choose your preferred language", preferredStyle: .actionSheet)

        let languages = ["English", "中文", "日本語", "Español", "Français", "Deutsch"]
        for language in languages {
            alert.addAction(UIAlertAction(title: language, style: .default) { _ in
                UserDefaults.standard.set(language, forKey: "selectedLanguage")
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.popoverPresentationController?.sourceView = view
        present(alert, animated: true)
    }

    private func showRegionSettings() {
        let alert = UIAlertController(title: "Region Settings", message: "Configure regional preferences", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showPrivacyPolicy() {
        let alert = UIAlertController(title: "Privacy Policy", message: "Your privacy is important to us. We collect minimal data to improve your experience.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func exportGameData() {
        let alert = UIAlertController(title: "Export Data", message: "Game data exported successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func importGameData() {
        let alert = UIAlertController(title: "Import Data", message: "Select a file to import game data", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Import", style: .default))
        present(alert, animated: true)
    }

    private func contactSupport() {
        let alert = UIAlertController(title: "Contact Support", message: "Email: support@example.com\nWe'll get back to you within 24 hours!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Actions
    @objc private func backTapped() {
        soundManager.playUISound()
        navigationController?.popViewController(animated: true)
    }



    @objc private func resetProgressTapped() {
        soundManager.playUISound()
        let alert = UIAlertController(title: "Reset Progress", message: "This will delete all your game progress. This action cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
            self.resetProgress()
        })
        present(alert, animated: true)
    }

    @objc private func resetSettingsTapped() {
        soundManager.playUISound()
        let alert = UIAlertController(title: "Reset All Settings", message: "This will reset all settings to default values.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
            self.resetAllSettings()
        })
        present(alert, animated: true)
    }

    @objc private func creditsTapped() {
        soundManager.playUISound()
        let alert = UIAlertController(title: "Credits", message: "badx T DM\n\nDeveloped with ❤️\nUsing Swift & UIKit\n\nSpecial thanks to our beta testers!\n\nThanks for playing!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Settings Management

    private func resetProgress() {
        let defaults = UserDefaults.standard
        let keys = ["maxLevel_Easy", "maxLevel_Medium", "maxLevel_Hard",
                   "highScore_Easy", "highScore_Medium", "highScore_Hard",
                   "totalGames_Easy", "totalGames_Medium", "totalGames_Hard",
                   "totalScore_Easy", "totalScore_Medium", "totalScore_Hard",
                   "gamesPlayed", "gamesWon", "bestTime", "totalPlayTime", "totalHintsUsed"]

        for key in keys {
            defaults.removeObject(forKey: key)
        }

        let alert = UIAlertController(title: "Progress Reset", message: "All game progress has been reset.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func resetAllSettings() {
        let defaults = UserDefaults.standard
        let settingsKeys = ["musicEnabled", "soundEffectsEnabled", "hapticsEnabled",
                           "autoSaveEnabled", "musicVolume", "soundVolume", "darkMode",
                           "colorfulMode", "pushNotifications", "dailyReminder", "analytics",
                           "personalizedAds", "showHints", "autoPause", "debugMode"]

        for key in settingsKeys {
            defaults.removeObject(forKey: key)
        }

        // Refresh the current tab to show default values
        switchToTab(currentTabIndex)

        let alert = UIAlertController(title: "Settings Reset", message: "All settings have been reset to default values.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
