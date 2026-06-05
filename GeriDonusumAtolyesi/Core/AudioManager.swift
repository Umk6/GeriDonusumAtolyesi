//
//  AudioManager.swift
//  GeriDonusumAtolyesi
//
//  Ses yönetimi - efektler ve müzik
//

import AVFoundation
import SpriteKit

class AudioManager {
    static let shared = AudioManager()

    private var isSoundEnabled = true
    private var isMusicEnabled = true
    private var backgroundMusicPlayer: AVAudioPlayer?

    // Ses seviyeleri
    private var soundVolume: Float = 0.7
    private var musicVolume: Float = 0.3

    private init() {
        loadSettings()
    }

    // MARK: - Settings

    func setSoundEnabled(_ enabled: Bool) {
        isSoundEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "soundEnabled")
    }

    func setMusicEnabled(_ enabled: Bool) {
        isMusicEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "musicEnabled")

        if enabled {
            playBackgroundMusic()
        } else {
            stopBackgroundMusic()
        }
    }

    private func loadSettings() {
        if UserDefaults.standard.object(forKey: "soundEnabled") != nil {
            isSoundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        }
        if UserDefaults.standard.object(forKey: "musicEnabled") != nil {
            isMusicEnabled = UserDefaults.standard.bool(forKey: "musicEnabled")
        }
    }

    // MARK: - Sound Effects (SpriteKit kullanarak)

    func playMergeSound() {
        guard isSoundEnabled else { return }
        // Yumuşak "pop" sesi
        playSoundEffect(named: "pop", pitch: 1.0)
    }

    func playDropSound() {
        guard isSoundEnabled else { return }
        // Hafif "thud" sesi
        playSoundEffect(named: "drop", pitch: 0.9)
    }

    func playErrorSound() {
        guard isSoundEnabled else { return }
        // Uyarı sesi
        playSoundEffect(named: "error", pitch: 0.8)
    }

    func playSuccessSound() {
        guard isSoundEnabled else { return }
        // Başarı jingle'ı
        playSoundEffect(named: "success", pitch: 1.2)
    }

    func playLevelUpSound() {
        guard isSoundEnabled else { return }
        playSoundEffect(named: "levelup", pitch: 1.1)
    }

    func playCleanSound() {
        guard isSoundEnabled else { return }
        // Su sesi
        playSoundEffect(named: "clean", pitch: 1.0)
    }

    func playClickSound() {
        guard isSoundEnabled else { return }
        playSoundEffect(named: "click", pitch: 1.0)
    }

    // Ses efekti çalma (SpriteKit action kullanarak)
    private func playSoundEffect(named: String, pitch: CGFloat) {
        // Şimdilik programatik sesler kullanıyoruz
        // Gerçek ses dosyaları eklendiğinde bu fonksiyon güncellenecek

        // Placeholder: AVFoundation ile basit ton
        generateTone(frequency: frequencyFor(sound: named), duration: 0.1, pitch: pitch)
    }

    private func frequencyFor(sound: String) -> Double {
        switch sound {
        case "pop": return 800.0
        case "drop": return 400.0
        case "error": return 200.0
        case "success": return 1000.0
        case "levelup": return 1200.0
        case "clean": return 600.0
        case "click": return 500.0
        default: return 440.0
        }
    }

    // Basit ton oluşturma (gerçek ses dosyası olmadan)
    private func generateTone(frequency: Double, duration: Double, pitch: CGFloat) {
        DispatchQueue.global(qos: .userInitiated).async {
            let sampleRate = 44100.0
            let samples = Int(sampleRate * duration)
            var audioData = [Float](repeating: 0, count: samples)

            let adjustedFreq = frequency * Double(pitch)

            for i in 0..<samples {
                let time = Double(i) / sampleRate
                let amplitude = Float(0.3 * sin(2.0 * .pi * adjustedFreq * time))
                // Envelope (fade out)
                let envelope = Float(1.0 - Double(i) / Double(samples))
                audioData[i] = amplitude * envelope
            }

            self.playAudioData(audioData, sampleRate: Float(sampleRate))
        }
    }

    private func playAudioData(_ data: [Float], sampleRate: Float) {
        let audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                       sampleRate: Double(sampleRate),
                                       channels: 1,
                                       interleaved: false)!

        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat,
                                           frameCapacity: AVAudioFrameCount(data.count)) else { return }

        buffer.frameLength = buffer.frameCapacity

        if let channelData = buffer.floatChannelData {
            for i in 0..<data.count {
                channelData[0][i] = data[i] * soundVolume
            }
        }

        let engine = AVAudioEngine()
        let playerNode = AVAudioPlayerNode()

        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: audioFormat)

        do {
            try engine.start()
            playerNode.scheduleBuffer(buffer) {
                engine.stop()
            }
            playerNode.play()
        } catch {
            print("Audio engine error: \(error)")
        }
    }

    // MARK: - Background Music

    func playBackgroundMusic() {
        guard isMusicEnabled else { return }

        // Şimdilik arka plan müziği yok
        // Gerçek müzik dosyası eklendiğinde burası güncellenecek
    }

    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }

    // MARK: - Convenience

    func playHapticFeedback() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }

    func playHapticSuccess() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }

    func playHapticError() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }
}

// MARK: - Sound Namen Extensions (kolay erişim için)

extension SKAction {
    static func playSoundEffect(_ soundName: String) -> SKAction {
        return SKAction.run {
            switch soundName {
            case "merge":
                AudioManager.shared.playMergeSound()
            case "drop":
                AudioManager.shared.playDropSound()
            case "error":
                AudioManager.shared.playErrorSound()
            case "success":
                AudioManager.shared.playSuccessSound()
            case "levelup":
                AudioManager.shared.playLevelUpSound()
            case "clean":
                AudioManager.shared.playCleanSound()
            case "click":
                AudioManager.shared.playClickSound()
            default:
                break
            }
        }
    }
}
