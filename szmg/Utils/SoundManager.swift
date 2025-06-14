//
//  SoundManager.swift
//  badx T DM
//
//  Created by AI Assistant on 2025/1/10.
//

import Foundation
import AVFoundation

// MARK: - Sound Types
enum SoundType: String, CaseIterable {
    case buttonTap = "button_tap"
    case correctMove = "correct_move"
    case wrongMove = "wrong_move"
    case levelComplete = "level_complete"
    case gameOver = "game_over"
    case hint = "hint"
    case undo = "undo"
    case backgroundMusic = "background_music"
    case menuMusic = "menu_music"
    case move = "move"
    case error = "error"
    
    var fileName: String {
        return self.rawValue
    }
    
    var fileExtension: String {
        return "wav"
    }
}

// MARK: - Sound Manager
class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    @Published var isSoundEnabled: Bool = true
    @Published var isMusicEnabled: Bool = true
    @Published var soundVolume: Float = 0.7
    @Published var musicVolume: Float = 0.5
    
    private var soundPlayers: [SoundType: AVAudioPlayer] = [:]
    private var musicPlayer: AVAudioPlayer?
    private var currentBackgroundMusic: SoundType?
    private var desiredBackgroundMusic: SoundType? // 记住用户想要的背景音乐类型
    
    private init() {
        loadSettings()
        setupAudioSession()
        preloadSounds()
    }
    
    // MARK: - Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func preloadSounds() {
        // Load sound effects from se.mp3
        if let url = Bundle.main.url(forResource: "se", withExtension: "mp3") {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                player.volume = soundVolume
                // Use the same sound effect for all sound types
                for soundType in SoundType.allCases {
                    if soundType != .backgroundMusic && soundType != .menuMusic {
                        soundPlayers[soundType] = player
                    }
                }
            } catch {
                print("Failed to load sound effects: \(error)")
            }
        }

        // 设置默认的期望背景音乐类型
        desiredBackgroundMusic = .backgroundMusic

        // Start background music automatically if enabled
        if isMusicEnabled {
            startBackgroundMusic()
        }
    }
    
    // MARK: - Sound Playback
    func playSound(_ soundType: SoundType) {
        guard isSoundEnabled else { return }
        
        // For music types, use different handling
        if soundType == .backgroundMusic || soundType == .menuMusic {
            playBackgroundMusic(soundType)
            return
        }
        
        // Play sound effect
        if let player = soundPlayers[soundType] {
            player.stop()
            player.currentTime = 0
            player.volume = soundVolume
            player.play()
        } else {
            // Fallback: generate programmatic sound
            generateProgrammaticSound(for: soundType)
        }
    }
    
    private func playBackgroundMusic(_ musicType: SoundType) {
        guard isMusicEnabled else {
            // 即使音乐被禁用，也要记住用户想要的音乐类型
            desiredBackgroundMusic = musicType
            return
        }

        // 记住用户想要的音乐类型
        desiredBackgroundMusic = musicType

        // Stop current music if different
        if currentBackgroundMusic != musicType {
            stopBackgroundMusic()
        }

        // Use bgm.mp3 for background music
        if let url = Bundle.main.url(forResource: "bgm", withExtension: "mp3") {
            do {
                musicPlayer = try AVAudioPlayer(contentsOf: url)
                musicPlayer?.numberOfLoops = -1 // Loop indefinitely
                musicPlayer?.volume = musicVolume
                musicPlayer?.play()
                currentBackgroundMusic = musicType
            } catch {
                print("Failed to play background music: \(error)")
            }
        }
    }

    func startBackgroundMusic() {
        playBackgroundMusic(.backgroundMusic)
    }
    
    func stopBackgroundMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
        currentBackgroundMusic = nil
        // 注意：不要清除 desiredBackgroundMusic，这样我们就能记住用户想要的音乐类型
    }
    
    func pauseBackgroundMusic() {
        musicPlayer?.pause()
    }
    
    func resumeBackgroundMusic() {
        guard isMusicEnabled else { return }
        musicPlayer?.play()
    }
    
    // MARK: - Programmatic Sound Generation
    private func generateProgrammaticSound(for soundType: SoundType) {
        // Generate simple system sounds as fallback
        switch soundType {
        case .buttonTap:
            AudioServicesPlaySystemSound(1104) // Keyboard tap
        case .correctMove:
            AudioServicesPlaySystemSound(1057) // SMS received
        case .wrongMove:
            AudioServicesPlaySystemSound(1053) // SMS received 4
        case .levelComplete:
            AudioServicesPlaySystemSound(1016) // SMS received 1
        case .gameOver:
            AudioServicesPlaySystemSound(1006) // SMS received 6
        case .hint:
            AudioServicesPlaySystemSound(1003) // SMS received 3
        case .undo:
            AudioServicesPlaySystemSound(1105) // Keyboard delete
        case .move:
            AudioServicesPlaySystemSound(1057) // SMS received
        case .error:
            AudioServicesPlaySystemSound(1053) // SMS received 4
        default:
            AudioServicesPlaySystemSound(1000) // New mail
        }
    }
    
    // MARK: - Volume Control
    func setSoundVolume(_ volume: Float) {
        soundVolume = max(0.0, min(1.0, volume))
        
        // Update all sound players
        for player in soundPlayers.values {
            player.volume = soundVolume
        }
        
        saveSettings()
    }
    
    func setMusicVolume(_ volume: Float) {
        musicVolume = max(0.0, min(1.0, volume))
        musicPlayer?.volume = musicVolume
        saveSettings()
    }
    
    // MARK: - Settings Management
    func toggleSound() {
        isSoundEnabled.toggle()
        saveSettings()
    }

    func toggleMusic() {
        isMusicEnabled.toggle()

        if isMusicEnabled {
            // Resume music - 优先使用用户想要的音乐类型，如果没有则使用默认背景音乐
            if let desiredMusic = desiredBackgroundMusic {
                playBackgroundMusic(desiredMusic)
            } else {
                startBackgroundMusic() // 使用默认背景音乐
            }
        } else {
            stopBackgroundMusic()
        }

        saveSettings()
    }

    func setMusicEnabled(_ enabled: Bool) {
        isMusicEnabled = enabled

        if isMusicEnabled {
            // Resume music - 优先使用用户想要的音乐类型，如果没有则使用默认背景音乐
            if let desiredMusic = desiredBackgroundMusic {
                playBackgroundMusic(desiredMusic)
            } else {
                startBackgroundMusic() // 使用默认背景音乐
            }
        } else {
            stopBackgroundMusic()
        }

        saveSettings()
    }

    func setSoundEffectsEnabled(_ enabled: Bool) {
        isSoundEnabled = enabled
        saveSettings()
    }
    
    private func loadSettings() {
        let userDefaults = UserDefaults.standard
        isSoundEnabled = userDefaults.object(forKey: "soundEffectsEnabled") as? Bool ?? true
        isMusicEnabled = userDefaults.object(forKey: "musicEnabled") as? Bool ?? true
        soundVolume = userDefaults.object(forKey: "soundVolume") as? Float ?? 0.7
        musicVolume = userDefaults.object(forKey: "musicVolume") as? Float ?? 0.5
    }

    private func saveSettings() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(isSoundEnabled, forKey: "soundEffectsEnabled")
        userDefaults.set(isMusicEnabled, forKey: "musicEnabled")
        userDefaults.set(soundVolume, forKey: "soundVolume")
        userDefaults.set(musicVolume, forKey: "musicVolume")
    }
    
    // MARK: - Game-Specific Sound Methods
    func playMenuSounds() {
        playSound(.menuMusic)
    }
    
    func playGameSounds() {
        playSound(.backgroundMusic)
    }
    
    func playMoveSound(isCorrect: Bool) {
        playSound(isCorrect ? .correctMove : .wrongMove)
    }
    
    func playUISound() {
        playSound(.buttonTap)
    }
    
    func playHintSound() {
        playSound(.hint)
    }
    
    func playUndoSound() {
        playSound(.undo)
    }
    
    func playVictorySound() {
        playSound(.levelComplete)
    }
    
    func playGameOverSound() {
        playSound(.gameOver)
    }
}

// MARK: - Audio Services Import
import AudioToolbox
