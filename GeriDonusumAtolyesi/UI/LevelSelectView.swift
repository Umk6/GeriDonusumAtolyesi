//
//  LevelSelectView.swift
//  GeriDonusumAtolyesi
//
//  Seviye seçim ekranı
//

import SwiftUI
import SwiftData

struct LevelSelectView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var levels: [Level]
    @Query private var playerData: [PlayerData]

    @State private var selectedLevel: Level?
    @State private var showingGame = false

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // Arka plan
                LinearGradient(
                    colors: [Color(red: 0.4, green: 0.8, blue: 0.6), Color(red: 0.2, green: 0.6, blue: 0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack {
                    // Başlık
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.white)
                        }

                        Spacer()

                        Text("Seviye Seç")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Spacer()

                        // Dengeli görünüm için boş alan
                        Color.clear
                            .frame(width: 44)
                    }
                    .padding()

                    // Seviye grid'i
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(sortedLevels) { level in
                                VStack(spacing: 5) {
                                    LevelButton(level: level) {
                                        selectedLevel = level
                                        showingGame = true
                                    }
                                    .disabled(!level.isUnlocked)

                                    // Seviye açıklaması (özel seviyelerde)
                                    if level.isUnlocked && shouldShowDescription(level.number) {
                                        Text(LevelManager.getLevelDescription(level.number))
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.8))
                                            .multilineTextAlignment(.center)
                                            .frame(width: 70)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showingGame) {
                if let level = selectedLevel {
                    GameView(level: level)
                }
            }
        }
        .onAppear {
            initializeLevelsIfNeeded()
        }
    }

    var sortedLevels: [Level] {
        levels.sorted { $0.number < $1.number }
    }

    func shouldShowDescription(_ number: Int) -> Bool {
        return [1, 4, 8, 10, 13, 16, 20, 25, 30].contains(number)
    }

    private func initializeLevelsIfNeeded() {
        // Eğer seviye yoksa oluştur
        if levels.isEmpty {
            let newLevels = LevelManager.generateLevels(count: 30)
            newLevels.forEach { modelContext.insert($0) }
        }

        // Eğer oyuncu verisi yoksa oluştur
        if playerData.isEmpty {
            let newPlayer = PlayerData()
            modelContext.insert(newPlayer)
        }
    }
}

// MARK: - Seviye Butonu

struct LevelButton: View {
    let level: Level
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                // Seviye numarası
                Text("\(level.number)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(level.isUnlocked ? .white : .gray)

                // Yıldızlar
                if level.stars > 0 {
                    HStack(spacing: 2) {
                        ForEach(0..<3) { index in
                            Image(systemName: index < level.stars ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundColor(index < level.stars ? .yellow : .gray)
                        }
                    }
                }

                // En iyi skor
                if level.bestScore > 0 {
                    Text("\(level.bestScore)")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(width: 70, height: 70)
            .background(
                level.isUnlocked ?
                    (level.stars > 0 ? Color.green : Color.blue) :
                    Color.gray
            )
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
            .opacity(level.isUnlocked ? 1.0 : 0.5)
        }
        .disabled(!level.isUnlocked)
    }
}

#Preview {
    LevelSelectView()
        .modelContainer(for: [PlayerData.self, Level.self])
}
