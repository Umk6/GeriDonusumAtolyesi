//
//  Player.swift
//  GeriDonusumAtolyesi
//
//  Oyuncu ilerlemesi ve fabrika
//

import Foundation
import SwiftData

@Model
class PlayerData {
    var greenPoints: Int // Fabrika geliştirmek için
    var currentLevel: Int
    var totalStars: Int
    var unlockedLevels: [Int]

    // Fabrika yükseltmeleri
    var conveyorSpeedLevel: Int
    var sortingAreaLevel: Int
    var pressLevel: Int
    var autoSorterLevel: Int

    // Koleksiyon
    var unlockedProducts: [String]

    // Günlük görevler
    var lastDailyResetDate: Date
    var dailyTasksCompleted: [String]

    init() {
        self.greenPoints = 0
        self.currentLevel = 1
        self.totalStars = 0
        self.unlockedLevels = [1]
        self.conveyorSpeedLevel = 1
        self.sortingAreaLevel = 1
        self.pressLevel = 1
        self.autoSorterLevel = 0
        self.unlockedProducts = []
        self.lastDailyResetDate = Date()
        self.dailyTasksCompleted = []
    }

    func canAfford(cost: Int) -> Bool {
        return greenPoints >= cost
    }

    func spend(amount: Int) -> Bool {
        guard canAfford(cost: amount) else { return false }
        greenPoints -= amount
        return true
    }

    func earn(amount: Int) {
        greenPoints += amount
    }

    func unlockLevel(_ levelNumber: Int) {
        if !unlockedLevels.contains(levelNumber) {
            unlockedLevels.append(levelNumber)
        }
    }

    func addStars(_ count: Int) {
        totalStars += count
    }
}

enum FactoryUpgradeType {
    case conveyorSpeed
    case sortingArea
    case press
    case autoSorter

    var name: String {
        switch self {
        case .conveyorSpeed: return "Bant Hızı"
        case .sortingArea: return "Ayırma Alanı"
        case .press: return "Pres Gücü"
        case .autoSorter: return "Otomatik Ayırıcı"
        }
    }

    var description: String {
        switch self {
        case .conveyorSpeed: return "Atıklar daha hızlı gelir"
        case .sortingArea: return "Daha fazla atık tutabilirsin"
        case .press: return "Birleştirme daha hızlı olur"
        case .autoSorter: return "Atıkları otomatik ayırır"
        }
    }

    var icon: String {
        switch self {
        case .conveyorSpeed: return "forward.fill"
        case .sortingArea: return "square.grid.2x2"
        case .press: return "arrow.down.square"
        case .autoSorter: return "wand.and.stars"
        }
    }

    func cost(forLevel level: Int) -> Int {
        switch self {
        case .conveyorSpeed: return level * 100
        case .sortingArea: return level * 150
        case .press: return level * 120
        case .autoSorter: return level * 200
        }
    }

    func maxLevel() -> Int {
        switch self {
        case .conveyorSpeed: return 5
        case .sortingArea: return 5
        case .press: return 5
        case .autoSorter: return 3
        }
    }
}
