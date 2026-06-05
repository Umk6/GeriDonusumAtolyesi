//
//  Booster.swift
//  GeriDonusumAtolyesi
//
//  Booster/Power-up sistemi
//

import Foundation
import SwiftUI

enum BoosterType: String, Codable, CaseIterable {
    case magnet        // Tüm metal atıkları topla
    case cleanSpray    // Kirli atıkları temizle
    case superPress    // Tüm aynı türleri birleştir
    case timeSlow      // Zamanı yavaşlat
    case robotArm      // Yanlış atığı kurtar

    var name: String {
        switch self {
        case .magnet: return "Mıknatıs"
        case .cleanSpray: return "Temizlik Spreyi"
        case .superPress: return "Süper Pres"
        case .timeSlow: return "Zaman Yavaşlatıcı"
        case .robotArm: return "Robot Kol"
        }
    }

    var description: String {
        switch self {
        case .magnet: return "Tüm metal atıkları toplar"
        case .cleanSpray: return "Kirli atıkları temizler"
        case .superPress: return "Aynı türdeki atıkları birleştirir"
        case .timeSlow: return "Atıkları 5 saniye yavaşlatır"
        case .robotArm: return "Bir hatayı geri alır"
        }
    }

    var icon: String {
        switch self {
        case .magnet: return "🧲"
        case .cleanSpray: return "💧"
        case .superPress: return "⚡"
        case .timeSlow: return "⏰"
        case .robotArm: return "🤖"
        }
    }

    var systemIcon: String {
        switch self {
        case .magnet: return "magnet.fill"
        case .cleanSpray: return "drop.fill"
        case .superPress: return "bolt.fill"
        case .timeSlow: return "clock.fill"
        case .robotArm: return "robot.fill"
        }
    }

    var cooldown: TimeInterval {
        switch self {
        case .magnet: return 30
        case .cleanSpray: return 20
        case .superPress: return 45
        case .timeSlow: return 60
        case .robotArm: return 15
        }
    }
}

class BoosterManager {
    static let shared = BoosterManager()

    private var availableBoosters: [BoosterType: Int] = [:]
    private var lastUsedTime: [BoosterType: Date] = [:]

    private init() {
        // Başlangıç booster'ları
        availableBoosters = [
            .magnet: 3,
            .cleanSpray: 3,
            .superPress: 2,
            .timeSlow: 1,
            .robotArm: 5
        ]
    }

    func getCount(for type: BoosterType) -> Int {
        return availableBoosters[type] ?? 0
    }

    func canUse(_ type: BoosterType) -> Bool {
        guard getCount(for: type) > 0 else { return false }

        // Cooldown kontrolü
        if let lastUsed = lastUsedTime[type] {
            let elapsed = Date().timeIntervalSince(lastUsed)
            if elapsed < type.cooldown {
                return false
            }
        }

        return true
    }

    func use(_ type: BoosterType) -> Bool {
        guard canUse(type) else { return false }

        availableBoosters[type]? -= 1
        lastUsedTime[type] = Date()

        return true
    }

    func add(_ type: BoosterType, count: Int = 1) {
        let current = availableBoosters[type] ?? 0
        availableBoosters[type] = current + count
    }

    func getCooldownRemaining(for type: BoosterType) -> TimeInterval {
        guard let lastUsed = lastUsedTime[type] else { return 0 }

        let elapsed = Date().timeIntervalSince(lastUsed)
        let remaining = type.cooldown - elapsed

        return max(0, remaining)
    }
}
