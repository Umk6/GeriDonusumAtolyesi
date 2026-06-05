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
        // Seviye tasarım kuralları
        switch number {
        // Tutorial seviyeleri (1-5): Sadece plastik, düşük zorluk
        case 1:
            return Level(number: 1, targetScore: 100, spawnRate: 0.5, timeLimit: 0, maxMistakes: 5)
        case 2:
            return Level(number: 2, targetScore: 150, spawnRate: 0.6, timeLimit: 0, maxMistakes: 5)
        case 3:
            return Level(number: 3, targetScore: 200, spawnRate: 0.7, timeLimit: 0, maxMistakes: 4)

        // Kağıt eklenir (4-7)
        case 4:
            return Level(number: 4, targetScore: 250, spawnRate: 0.7, timeLimit: 0, maxMistakes: 5)
        case 5:
            return Level(number: 5, targetScore: 300, spawnRate: 0.8, timeLimit: 0, maxMistakes: 5)
        case 6:
            return Level(number: 6, targetScore: 350, spawnRate: 0.9, timeLimit: 0, maxMistakes: 4)
        case 7:
            return Level(number: 7, targetScore: 400, spawnRate: 1.0, timeLimit: 0, maxMistakes: 4)

        // Metal eklenir (8-12)
        case 8:
            return Level(number: 8, targetScore: 450, spawnRate: 1.0, timeLimit: 0, maxMistakes: 5)
        case 9:
            return Level(number: 9, targetScore: 500, spawnRate: 1.1, timeLimit: 0, maxMistakes: 5)
        case 10:
            return Level(number: 10, targetScore: 600, spawnRate: 1.2, timeLimit: 0, maxMistakes: 4)
        case 11:
            return Level(number: 11, targetScore: 700, spawnRate: 1.3, timeLimit: 0, maxMistakes: 4)
        case 12:
            return Level(number: 12, targetScore: 800, spawnRate: 1.4, timeLimit: 0, maxMistakes: 4)

        // Hız seviyeleri (13-15)
        case 13:
            return Level(number: 13, targetScore: 500, spawnRate: 2.0, timeLimit: 0, maxMistakes: 3)
        case 14:
            return Level(number: 14, targetScore: 600, spawnRate: 2.2, timeLimit: 0, maxMistakes: 3)
        case 15:
            return Level(number: 15, targetScore: 700, spawnRate: 2.5, timeLimit: 0, maxMistakes: 3)

        // Cam eklenir (16-20)
        case 16:
            return Level(number: 16, targetScore: 900, spawnRate: 1.2, timeLimit: 0, maxMistakes: 5)
        case 17:
            return Level(number: 17, targetScore: 1000, spawnRate: 1.3, timeLimit: 0, maxMistakes: 5)
        case 18:
            return Level(number: 18, targetScore: 1100, spawnRate: 1.4, timeLimit: 0, maxMistakes: 4)
        case 19:
            return Level(number: 19, targetScore: 1200, spawnRate: 1.5, timeLimit: 0, maxMistakes: 4)
        case 20:
            return Level(number: 20, targetScore: 1500, spawnRate: 1.6, timeLimit: 0, maxMistakes: 4)

        // Zorluk artıyor (21-25)
        case 21:
            return Level(number: 21, targetScore: 1600, spawnRate: 1.7, timeLimit: 0, maxMistakes: 4)
        case 22:
            return Level(number: 22, targetScore: 1700, spawnRate: 1.8, timeLimit: 0, maxMistakes: 3)
        case 23:
            return Level(number: 23, targetScore: 1800, spawnRate: 1.9, timeLimit: 0, maxMistakes: 3)
        case 24:
            return Level(number: 24, targetScore: 1900, spawnRate: 2.0, timeLimit: 0, maxMistakes: 3)
        case 25:
            return Level(number: 25, targetScore: 2000, spawnRate: 2.1, timeLimit: 0, maxMistakes: 3)

        // Expert seviyeleri (26-30)
        case 26:
            return Level(number: 26, targetScore: 2200, spawnRate: 2.2, timeLimit: 0, maxMistakes: 3)
        case 27:
            return Level(number: 27, targetScore: 2400, spawnRate: 2.4, timeLimit: 0, maxMistakes: 2)
        case 28:
            return Level(number: 28, targetScore: 2600, spawnRate: 2.6, timeLimit: 0, maxMistakes: 2)
        case 29:
            return Level(number: 29, targetScore: 2800, spawnRate: 2.8, timeLimit: 0, maxMistakes: 2)
        case 30:
            return Level(number: 30, targetScore: 3000, spawnRate: 3.0, timeLimit: 0, maxMistakes: 2)

        // Bonus seviyeleri
        default:
            let baseScore = number * 100
            let spawnRate = 0.5 + Double(number) * 0.1
            return Level(
                number: number,
                targetScore: baseScore,
                spawnRate: min(spawnRate, 3.0),
                timeLimit: 0,
                maxMistakes: 5
            )
        }
    }

    static func generateLevels(count: Int = 30) -> [Level] {
        return (1...count).map { createLevel($0) }
    }

    // Seviye açıklamaları
    static func getLevelDescription(_ number: Int) -> String {
        switch number {
        case 1: return "Hoş geldin! Basit başlıyoruz."
        case 3: return "İyi gidiyorsun!"
        case 4: return "Yeni atık türü: Kağıt!"
        case 7: return "Harika ilerliyorsun!"
        case 8: return "Metal atıklar geliyor!"
        case 10: return "10. seviye! 🎉"
        case 13: return "Hız zamanı! ⚡"
        case 16: return "Cam atıklar açıldı!"
        case 20: return "Yarı yol! 🌟"
        case 25: return "Expert moduna hoş geldin!"
        case 30: return "Final seviyesi! 🏆"
        default: return "Seviye \(number)"
        }
    }
}
