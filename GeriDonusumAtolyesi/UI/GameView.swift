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

    let level: Level
    @State private var scene: GameScene?
    @State private var showingResults = false
    @State private var gameScore = 0
    @State private var gameSuccess = false
    @State private var gameStars = 0

    var body: some View {
        ZStack {
            // Oyun sahnesi
            if let scene = scene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
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
        }
        .onAppear {
            setupGame()
        }
    }

    private func setupGame() {
        let newScene = GameScene(size: UIScreen.main.bounds.size)
        newScene.gameDelegate = GameSceneDelegateWrapper(parent: self)
        newScene.startLevel(level)
        scene = newScene
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

            // Bir sonraki seviyeyi aç
            if let nextLevel = try? modelContext.fetch(
                FetchDescriptor<Level>(predicate: #Predicate { $0.number == level.number + 1 })
            ).first {
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
    weak var parent: GameView?

    init(parent: GameView) {
        self.parent = parent
    }

    func gameDidEnd(score: Int, success: Bool, stars: Int) {
        parent?.handleGameEnd(score: score, success: success, stars: stars)
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

                // Skor
                VStack(spacing: 10) {
                    Text("Puan")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))

                    Text("\(score)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)

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
