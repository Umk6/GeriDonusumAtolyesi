//
//  EndlessMode.swift
//  GeriDonusumAtolyesi
//
//  Sonsuz oyun modu - zorluk sürekli artar
//

import Foundation
import SwiftData

@Model
class EndlessModeStats {
    var highScore: Int
    var longestCombo: Int
    var totalWasteProcessed: Int
    var bestWave: Int
    var totalGamesPlayed: Int

    init() {
        self.highScore = 0
        self.longestCombo = 0
        self.totalWasteProcessed = 0
        self.bestWave = 0
        self.totalGamesPlayed = 0
    }

    func updateStats(score: Int, combo: Int, waste: Int, wave: Int) {
        highScore = max(highScore, score)
        longestCombo = max(longestCombo, combo)
        totalWasteProcessed += waste
        bestWave = max(bestWave, wave)
        totalGamesPlayed += 1
    }
}

// Sonsuz mod ayarları
struct EndlessModeConfig {
    // Başlangıç ayarları
    static let initialSpawnRate: Double = 0.8
    static let initialMaxMistakes: Int = 10
    static let initialContamination: Double = 100.0

    // Dalga artışları
    static let waveInterval: Int = 10 // Her 10 atık = 1 dalga
    static let spawnRateIncrease: Double = 0.05 // Her dalgada %5 artış
    static let maxSpawnRate: Double = 3.0

    // Zorluk eğrisi
    static func spawnRate(for wave: Int) -> Double {
        let rate = initialSpawnRate + Double(wave) * spawnRateIncrease
        return min(rate, maxSpawnRate)
    }

    static func allowedCategories(for wave: Int) -> [WasteCategory] {
        switch wave {
        case 0...2:
            return [.plastic, .paper]
        case 3...5:
            return [.plastic, .paper, .metal]
        case 6...8:
            return [.plastic, .paper, .metal, .glass]
        case 9...11:
            return [.plastic, .paper, .metal, .glass, .battery]
        case 12...14:
            return [.plastic, .paper, .metal, .glass, .battery, .organic]
        default:
            // 15+ tüm türler + artı kirlilik
            return [.plastic, .paper, .metal, .glass, .battery, .organic, .electronic]
        }
    }

    static func dirtyChance(for wave: Int) -> Double {
        // İlk dalgalarda az kirli, sonra artar
        let baseChance = 0.2
        let increase = Double(wave) * 0.02
        return min(baseChance + increase, 0.7) // Max %70 kirli
    }

    static func scoreMultiplier(for wave: Int) -> Double {
        return 1.0 + Double(wave) * 0.1 // Her dalga +%10
    }
}

// Endless mode için Level wrapper
class EndlessLevel {
    var wave: Int
    var totalScore: Int
    var wasteProcessed: Int
    var mistakes: Int
    var maxMistakes: Int
    var contamination: Double
    var currentCombo: Int
    var bestCombo: Int

    init() {
        self.wave = 0
        self.totalScore = 0
        self.wasteProcessed = 0
        self.mistakes = 0
        self.maxMistakes = EndlessModeConfig.initialMaxMistakes
        self.contamination = EndlessModeConfig.initialContamination
        self.currentCombo = 0
        self.bestCombo = 0
    }

    func processWaste(points: Int) {
        totalScore += Int(Double(points) * EndlessModeConfig.scoreMultiplier(for: wave))
        wasteProcessed += 1

        // Dalga kontrolü
        if wasteProcessed % EndlessModeConfig.waveInterval == 0 {
            advanceWave()
        }
    }

    func advanceWave() {
        wave += 1
        // Her dalga bonus veriyoruz
        totalScore += wave * 50
    }

    func recordCombo(_ combo: Int) {
        currentCombo = combo
        bestCombo = max(bestCombo, combo)
    }

    func addMistake() {
        mistakes += 1
        contamination = max(0, contamination - 5)
    }

    func isGameOver() -> Bool {
        return mistakes >= maxMistakes || contamination <= 0
    }

    var spawnRate: Double {
        return EndlessModeConfig.spawnRate(for: wave)
    }

    var allowedCategories: [WasteCategory] {
        return EndlessModeConfig.allowedCategories(for: wave)
    }

    var dirtyChance: Double {
        return EndlessModeConfig.dirtyChance(for: wave)
    }

    // UI için wave açıklaması
    var waveDescription: String {
        switch wave {
        case 0...2:
            return "🌱 Başlangıç"
        case 3...5:
            return "⚙️ Isınma"
        case 6...8:
            return "🔥 Hızlanıyor"
        case 9...11:
            return "⚡ Zorlaşıyor"
        case 12...14:
            return "💥 Kaos"
        case 15...20:
            return "🌪️ Fırtına"
        default:
            return "👹 İmkansız"
        }
    }

    var nextWaveProgress: Double {
        let progressInWave = wasteProcessed % EndlessModeConfig.waveInterval
        return Double(progressInWave) / Double(EndlessModeConfig.waveInterval)
    }
}
