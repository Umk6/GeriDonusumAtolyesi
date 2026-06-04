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

    @Attribute(.transformable)
    var goals: [LevelGoal]

    var allowedCategories: [WasteCategory]
    var spawnRate: Double // Saniyede kaç atık
    var timeLimit: Int? // nil = sınırsız
    var maxMistakes: Int

    init(number: Int,
         goals: [LevelGoal],
         allowedCategories: [WasteCategory],
         spawnRate: Double = 1.0,
         timeLimit: Int? = nil,
         maxMistakes: Int = 5) {
        self.number = number
        self.isUnlocked = number == 1
        self.stars = 0
        self.bestScore = 0
        self.goals = goals
        self.allowedCategories = allowedCategories
        self.spawnRate = spawnRate
        self.timeLimit = timeLimit
        self.maxMistakes = maxMistakes
    }
}

class LevelManager {
    static func createLevel(_ number: Int) -> Level {
        switch number {
        case 1:
            return Level(
                number: 1,
                goals: [
                    LevelGoal(type: .produceItems, targetValue: 5, category: .plastic, wasteLevel: .level2)
                ],
                allowedCategories: [.plastic],
                spawnRate: 0.8,
                timeLimit: nil,
                maxMistakes: 3
            )

        case 2:
            return Level(
                number: 2,
                goals: [
                    LevelGoal(type: .produceItems, targetValue: 3, category: .plastic, wasteLevel: .level3)
                ],
                allowedCategories: [.plastic],
                spawnRate: 1.0,
                maxMistakes: 3
            )

        case 3:
            return Level(
                number: 3,
                goals: [
                    LevelGoal(type: .scorePoints, targetValue: 200, category: nil, wasteLevel: nil)
                ],
                allowedCategories: [.plastic],
                spawnRate: 1.2,
                maxMistakes: 3
            )

        case 4:
            return Level(
                number: 4,
                goals: [
                    LevelGoal(type: .produceItems, targetValue: 4, category: .plastic, wasteLevel: .level2),
                    LevelGoal(type: .produceItems, targetValue: 4, category: .paper, wasteLevel: .level2)
                ],
                allowedCategories: [.plastic, .paper],
                spawnRate: 1.0,
                maxMistakes: 5
            )

        case 5:
            return Level(
                number: 5,
                goals: [
                    LevelGoal(type: .scorePoints, targetValue: 300, category: nil, wasteLevel: nil)
                ],
                allowedCategories: [.plastic, .paper],
                spawnRate: 1.3,
                maxMistakes: 5
            )

        default:
            return Level(
                number: number,
                goals: [
                    LevelGoal(type: .scorePoints, targetValue: 100 * number, category: nil, wasteLevel: nil)
                ],
                allowedCategories: [.plastic, .paper, .metal, .glass],
                spawnRate: Double(number) * 0.3,
                maxMistakes: 5
            )
        }
    }

    static func generateLevels(count: Int = 30) -> [Level] {
        return (1...count).map { createLevel($0) }
    }
}
