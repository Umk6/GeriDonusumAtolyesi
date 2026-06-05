//
//  Level.swift
//  GeriDonusumAtolyesi
//
//  Seviye yapısı ve hedefler
//

import Foundation
import SwiftData
import SwiftUI

enum LevelGoalType: String, Codable {
    case produceItems        // X adet Y türü üret
    case maintainCleanliness // Temizliği %X'in üzerinde tut
    case scorePoints         // X puan kazan
    case timeChallenge       // X saniye içinde Y yap
    case noContamination     // Hatasız bitir
}

struct LevelGoal: Codable {
    let type: LevelGoalType
    let targetValue: Int
    let category: WasteCategory?
    let wasteLevel: WasteLevel?

    var description: String {
        switch type {
        case .produceItems:
            if let category = category, let level = wasteLevel {
                return "\(targetValue) adet \(category.name) Seviye \(level.rawValue) üret"
            }
            return "\(targetValue) ürün üret"

        case .maintainCleanliness:
            return "Temizliği %\(targetValue) üzerinde tut"

        case .scorePoints:
            return "\(targetValue) puan kazan"

        case .timeChallenge:
            return "\(targetValue) saniye içinde tamamla"

        case .noContamination:
            return "\(targetValue) hata yap"
        }
    }
}

@Model
class Level {
    var number: Int
    var isUnlocked: Bool
    var stars: Int
    var bestScore: Int
    var spawnRate: Double
    var timeLimit: Int
    var maxMistakes: Int

    // Basitleştirilmiş hedef sistemi - sadece puan hedefi
    var targetScore: Int

    init(number: Int,
         targetScore: Int,
         spawnRate: Double = 1.0,
         timeLimit: Int = 0,
         maxMistakes: Int = 5) {
        self.number = number
        self.isUnlocked = number == 1
        self.stars = 0
        self.bestScore = 0
        self.targetScore = targetScore
        self.spawnRate = spawnRate
        self.timeLimit = timeLimit
        self.maxMistakes = maxMistakes
    }

    // Transient - hesaplanan hedefler
    var goals: [LevelGoal] {
        return [
            LevelGoal(type: .scorePoints, targetValue: targetScore, category: nil, wasteLevel: nil)
        ]
    }

    // Transient - izin verilen kategoriler
    var allowedCategories: [WasteCategory] {
        switch number {
        case 1...3:
            return [.plastic]
        case 4...10:
            return [.plastic, .paper]
        case 11...20:
            return [.plastic, .paper, .metal]
        default:
            return [.plastic, .paper, .metal, .glass]
        }
    }
}

class LevelManager {
    static func createLevel(_ number: Int) -> Level {
        let baseScore = number * 100
        let spawnRate = 0.5 + Double(number) * 0.1

        return Level(
            number: number,
            targetScore: baseScore,
            spawnRate: min(spawnRate, 2.0),
            timeLimit: 0, // 0 = sınırsız
            maxMistakes: 5
        )
    }

    static func generateLevels(count: Int = 30) -> [Level] {
        return (1...count).map { createLevel($0) }
    }
}
