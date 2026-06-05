//
//  GameView.swift
//  GeriDonusumAtolyesi
//
//  Oyun ekranı - SpriteKit sahnesini SwiftUI'a bağlar
//

import SwiftUI
import SpriteKit
import SwiftData

struct GameView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var playerData: [PlayerData]

    let level: Level
    @State private var scene: GameScene?
    @State private var showingResults = false
    @State private var gameScore = 0
    @State private var gameSuccess = false
    @State private var gameStars = 0
    @State private var delegateWrapper: GameSceneDelegateWrapper?
    @State private var showingTutorial = false

    var player: PlayerData {
        playerData.first ?? PlayerData()
    }

    var shouldShowTutorial: Bool {
        level.number == 1 && !UserDefaults.standard.bool(forKey: "tutorialShown")
    }

    var body: some View {
        ZStack {
            // Arka plan
            Color(red: 0.95, green: 0.95, blue: 0.9)
                .ignoresSafeArea()

            // Oyun sahnesi
            if let scene = scene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
            } else {
                // Loading indicator
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Yükleniyor...")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top)
                }
            }

            // Üst bar
            VStack {
                HStack {
                    // Geri butonu
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                    }
                    .padding()

                    Spacer()

                    // Seviye numarası
                    Text("Seviye \(level.number)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(20)
                        .shadow(radius: 5)

                    Spacer()

                    // Ayarlar (placeholder)
                    Button(action: {
                        // TODO: Pause menü
                    }) {
                        Image(systemName: "pause.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                    }
                    .padding()
                }
                .padding(.top, 10)

                Spacer()
            }

            // Sonuç ekranı
            if showingResults {
                GameResultView(
                    score: gameScore,
                    stars: gameStars,
                    success: gameSuccess,
                    level: level,
                    onReplay: {
                        restartGame()
                    },
                    onNext: {
                        // Bir sonraki seviye
                        dismiss()
                    },
                    onMenu: {
                        dismiss()
                    }
                )
            }

            // Tutorial overlay
            if showingTutorial {
                TutorialOverlay {
                    showingTutorial = false
                    UserDefaults.standard.set(true, forKey: "tutorialShown")
                }
            }
        }
        .onAppear {
            setupGame()

            // Tutorial'ı göster
            if shouldShowTutorial {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingTutorial = true
                }
            }
        }
    }

    private func setupGame() {
        print("🎮 Setting up game for level \(level.number)")

        // Ekran boyutunu al
        let screenSize = CGSize(width: 390, height: 844)
        print("📐 Screen size: \(screenSize)")

        // Scene oluştur
        let newScene = GameScene(size: screenSize)
        newScene.scaleMode = .aspectFill
        print("✅ Scene created")

        // Delegate'i state'te tut ki deallocate olmasın
        let wrapper = GameSceneDelegateWrapper { [self] score, success, stars in
            print("🎯 Game ended: score=\(score), success=\(success), stars=\(stars)")
            handleGameEnd(score: score, success: success, stars: stars)
        }
        delegateWrapper = wrapper
        newScene.gameDelegate = wrapper
        print("✅ Delegate set")

        // Seviyeyi başlat
        newScene.startLevel(level)
        print("✅ Level started: \(level.number)")

        // Scene'i state'e ata
        scene = newScene
        print("✅ Scene assigned to state")
    }

    private func restartGame() {
        showingResults = false
        setupGame()
    }

    func handleGameEnd(score: Int, success: Bool, stars: Int) {
        gameScore = score
        gameSuccess = success
        gameStars = stars

        // Seviye ilerlemesini kaydet
        if success {
            level.bestScore = max(level.bestScore, score)
            level.stars = max(level.stars, stars)

            // Yeşil puan kazan
            let earnedPoints = stars * 50 + (score / 10)
            player.earn(amount: earnedPoints)

            // Bir sonraki seviyeyi aç
            let nextLevelNumber = level.number + 1
            let descriptor = FetchDescriptor<Level>(
                predicate: #Predicate<Level> { level in
                    level.number == nextLevelNumber
                }
            )

            if let nextLevel = try? modelContext.fetch(descriptor).first {
                nextLevel.isUnlocked = true
            }
        }

        // Sonuç ekranını göster
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showingResults = true
        }
    }
}

// GameSceneDelegate'i SwiftUI'a bağlamak için wrapper
class GameSceneDelegateWrapper: GameSceneDelegate {
    private let onGameEnd: (Int, Bool, Int) -> Void

    init(onGameEnd: @escaping (Int, Bool, Int) -> Void) {
        self.onGameEnd = onGameEnd
    }

    func gameDidEnd(score: Int, success: Bool, stars: Int) {
        onGameEnd(score, success, stars)
    }
}

// MARK: - Sonuç Ekranı

struct GameResultView: View {
    let score: Int
    let stars: Int
    let success: Bool
    let level: Level
    let onReplay: () -> Void
    let onNext: () -> Void
    let onMenu: () -> Void

    var earnedPoints: Int {
        stars * 50 + (score / 10)
    }

    var body: some View {
        ZStack {
            // Yarı saydam arka plan
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // Başarı/Başarısız
                Text(success ? "🎉 Tebrikler!" : "😔 Tekrar Dene")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)

                // Yıldızlar
                if success {
                    HStack(spacing: 15) {
                        ForEach(0..<3) { index in
                            Image(systemName: index < stars ? "star.fill" : "star")
                                .font(.system(size: 40))
                                .foregroundColor(index < stars ? .yellow : .gray)
                        }
                    }
                }

                // Skor ve kazanılanlar
                HStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Text("Puan")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))

                        Text("\(score)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)

                    if success {
                        VStack(spacing: 10) {
                            Text("Kazandın")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))

                            HStack(spacing: 4) {
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(.green)
                                Text("+\(earnedPoints)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                    }
                }

                // Butonlar
                VStack(spacing: 15) {
                    if success {
                        Button(action: onNext) {
                            HStack {
                                Text("Sonraki Seviye")
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(15)
                        }
                    }

                    Button(action: onReplay) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Tekrar Oyna")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                    }

                    Button(action: onMenu) {
                        HStack {
                            Image(systemName: "house")
                            Text("Ana Menü")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(15)
                    }
                }
                .padding(.horizontal, 40)
            }
            .padding(40)
        }
    }
}

#Preview {
    GameView(level: LevelManager.createLevel(1))
        .modelContainer(for: [PlayerData.self, Level.self])
}
