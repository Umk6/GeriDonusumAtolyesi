//
//  Statistics.swift
//  GeriDonusumAtolyesi
//
//  Oyun istatistikleri
//

import Foundation
import SwiftData

@Model
class GameStatistics {
    var totalGamesPlayed: Int
    var totalWasteRecycled: Int
    var totalScore: Int
    var bestCombo: Int
    var perfectLevels: Int
    var totalPlayTime: TimeInterval

    // Kategori bazlı geri dönüşüm
    var plasticRecycled: Int
    var paperRecycled: Int
    var metalRecycled: Int
    var glassRecycled: Int

    init() {
        self.totalGamesPlayed = 0
        self.totalWasteRecycled = 0
        self.totalScore = 0
        self.bestCombo = 0
        self.perfectLevels = 0
        self.totalPlayTime = 0
        self.plasticRecycled = 0
        self.paperRecycled = 0
        self.metalRecycled = 0
        self.glassRecycled = 0
    }

    func recordGame(score: Int, wasteCount: Int, maxCombo: Int, isPerfect: Bool, playTime: TimeInterval) {
        totalGamesPlayed += 1
        totalScore += score
        totalWasteRecycled += wasteCount
        bestCombo = max(bestCombo, maxCombo)
        totalPlayTime += playTime

        if isPerfect {
            perfectLevels += 1
        }
    }

    func recordWasteRecycled(category: WasteCategory) {
        switch category {
        case .plastic:
            plasticRecycled += 1
        case .paper:
            paperRecycled += 1
        case .metal:
            metalRecycled += 1
        case .glass:
            glassRecycled += 1
        default:
            break
        }
    }

    var averageScore: Int {
        guard totalGamesPlayed > 0 else { return 0 }
        return totalScore / totalGamesPlayed
    }

    var formattedPlayTime: String {
        let hours = Int(totalPlayTime) / 3600
        let minutes = Int(totalPlayTime) / 60 % 60
        return "\(hours)sa \(minutes)dk"
    }
}
