//
//  WasteType.swift
//  GeriDonusumAtolyesi
//
//  Atık türlerini ve dönüşüm zincirlerini tanımlar
//

import Foundation
import SwiftUI

enum WasteCategory: String, Codable {
    case plastic
    case paper
    case metal
    case glass
    case battery
    case organic
    case electronic

    var color: Color {
        switch self {
        case .plastic: return Color.blue
        case .paper: return Color(red: 0.85, green: 0.75, blue: 0.6)
        case .metal: return Color.gray
        case .glass: return Color(red: 0.4, green: 0.8, blue: 0.7)
        case .battery: return Color.yellow
        case .organic: return Color.green
        case .electronic: return Color.purple
        }
    }

    var name: String {
        switch self {
        case .plastic: return "Plastik"
        case .paper: return "Kağıt"
        case .metal: return "Metal"
        case .glass: return "Cam"
        case .battery: return "Pil"
        case .organic: return "Organik"
        case .electronic: return "Elektronik"
        }
    }

    var icon: String {
        switch self {
        case .plastic: return "🧴"
        case .paper: return "📄"
        case .metal: return "🥫"
        case .glass: return "🍾"
        case .battery: return "🔋"
        case .organic: return "🍎"
        case .electronic: return "📱"
        }
    }

    // Özel yetenekler
    var specialAbility: String? {
        switch self {
        case .battery:
            return "Pilleri birleştirmek ekstra kontaminasyon puanı verir!"
        case .organic:
            return "Organik atıklar hızlı bozunur - 10 saniye içinde işle!"
        case .electronic:
            return "Elektronikler 2x puan verir ama temizlenmesi zor!"
        default:
            return nil
        }
    }

    var scoringMultiplier: Double {
        switch self {
        case .electronic: return 2.0
        case .battery: return 1.5
        case .glass: return 1.3
        default: return 1.0
        }
    }
}

enum WasteLevel: Int, Codable {
    case level1 = 1  // Ham atık
    case level2 = 2  // Ezilmiş/Sıkıştırılmış
    case level3 = 3  // Balya/Paket
    case level4 = 4  // Geri dönüştürülmüş materyal
    case level5 = 5  // Yeni ürün

    var pointMultiplier: Int {
        return rawValue
    }
}

struct WasteItem: Identifiable, Codable {
    let id: UUID
    let category: WasteCategory
    let level: WasteLevel
    var isDirty: Bool
    var position: CGPoint

    init(category: WasteCategory, level: WasteLevel = .level1, isDirty: Bool = false, position: CGPoint = .zero) {
        self.id = UUID()
        self.category = category
        self.level = level
        self.isDirty = isDirty
        self.position = position
    }

    var displayName: String {
        let prefix = isDirty ? "Kirli " : ""
        return prefix + category.name + " (\(level.rawValue))"
    }

    var pointValue: Int {
        return level.pointMultiplier * 10
    }

    var size: CGFloat {
        return 40 + CGFloat(level.rawValue) * 10
    }

    func canMerge(with other: WasteItem) -> Bool {
        return category == other.category &&
               level == other.level &&
               !isDirty && !other.isDirty &&
               level.rawValue < WasteLevel.level5.rawValue
    }

    func merged() -> WasteItem? {
        guard level.rawValue < WasteLevel.level5.rawValue else { return nil }
        guard let nextLevel = WasteLevel(rawValue: level.rawValue + 1) else { return nil }

        return WasteItem(category: category, level: nextLevel, isDirty: false, position: position)
    }
}
