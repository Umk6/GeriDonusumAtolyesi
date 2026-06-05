//
//  FactoryUpgradeView.swift
//  GeriDonusumAtolyesi
//
//  Fabrika geliştirme ekranı
//

import SwiftUI
import SwiftData

struct FactoryUpgradeView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var playerData: [PlayerData]

    var player: PlayerData {
        playerData.first ?? PlayerData()
    }

    var body: some View {
        ZStack {
            // Arka plan
            LinearGradient(
                colors: [Color(red: 0.3, green: 0.7, blue: 0.5), Color(red: 0.2, green: 0.5, blue: 0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    VStack {
                        Text("Fabrika Geliştir")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        HStack {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.green)
                            Text("\(player.greenPoints)")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(15)
                    }

                    Spacer()

                    Color.clear
                        .frame(width: 44)
                }
                .padding()

                // Upgrades List
                ScrollView {
                    VStack(spacing: 20) {
                        UpgradeCard(
                            type: .conveyorSpeed,
                            currentLevel: player.conveyorSpeedLevel,
                            player: player,
                            modelContext: modelContext
                        )

                        UpgradeCard(
                            type: .sortingArea,
                            currentLevel: player.sortingAreaLevel,
                            player: player,
                            modelContext: modelContext
                        )

                        UpgradeCard(
                            type: .press,
                            currentLevel: player.pressLevel,
                            player: player,
                            modelContext: modelContext
                        )

                        UpgradeCard(
                            type: .autoSorter,
                            currentLevel: player.autoSorterLevel,
                            player: player,
                            modelContext: modelContext
                        )
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - Upgrade Card

struct UpgradeCard: View {
    let type: FactoryUpgradeType
    let currentLevel: Int
    let player: PlayerData
    let modelContext: ModelContext

    @State private var showingUpgrade = false

    var maxLevel: Int {
        type.maxLevel()
    }

    var isMaxLevel: Bool {
        currentLevel >= maxLevel
    }

    var cost: Int {
        type.cost(forLevel: currentLevel + 1)
    }

    var canAfford: Bool {
        player.canAfford(cost: cost)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                // Icon
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 60, height: 60)

                    Image(systemName: type.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(type.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(type.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                }

                Spacer()

                // Level badge
                VStack(spacing: 2) {
                    Text("Seviye")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))

                    Text("\(currentLevel)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)

                    Text("/ \(maxLevel)")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.3))
                .cornerRadius(10)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 5)
                        .fill(LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * CGFloat(currentLevel) / CGFloat(maxLevel), height: 8)
                }
            }
            .frame(height: 8)

            // Upgrade button
            if isMaxLevel {
                HStack {
                    Spacer()
                    Text("🏆 Max Seviye")
                        .font(.headline)
                        .foregroundColor(.yellow)
                    Spacer()
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(15)
            } else {
                Button(action: {
                    if canAfford {
                        upgradeFactory()
                    }
                }) {
                    HStack {
                        Spacer()

                        if canAfford {
                            Image(systemName: "arrow.up.circle.fill")
                            Text("Yükselt")
                        } else {
                            Image(systemName: "lock.fill")
                            Text("Yetersiz Puan")
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.green)
                            Text("\(cost)")
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(10)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(canAfford ? Color.green : Color.gray)
                    .cornerRadius(15)
                }
                .disabled(!canAfford)
                .scaleEffect(showingUpgrade ? 1.05 : 1.0)
                .animation(.spring(response: 0.3), value: showingUpgrade)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }

    private func upgradeFactory() {
        guard player.spend(amount: cost) else { return }

        // Upgrade'i uygula
        switch type {
        case .conveyorSpeed:
            player.conveyorSpeedLevel += 1
        case .sortingArea:
            player.sortingAreaLevel += 1
        case .press:
            player.pressLevel += 1
        case .autoSorter:
            player.autoSorterLevel += 1
        }

        // Animasyon
        AudioManager.shared.playLevelUpSound()
        AudioManager.shared.playHapticSuccess()

        withAnimation(.spring()) {
            showingUpgrade = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                showingUpgrade = false
            }
        }
    }
}

#Preview {
    FactoryUpgradeView()
        .modelContainer(for: [PlayerData.self, Level.self])
}
