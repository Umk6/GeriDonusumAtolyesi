//
//  EndlessModeView.swift
//  GeriDonusumAtolyesi
//
//  Sonsuz mod oyun ekranı
//

import SwiftUI
import SpriteKit
import SwiftData

struct EndlessModeView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var endlessStats: [EndlessModeStats]

    @State private var scene: GameScene?
    @State private var endlessLevel = EndlessLevel()
    @State private var showingResults = false
    @State private var showingPause = false

    var stats: EndlessModeStats {
        if let existing = endlessStats.first {
            return existing
        } else {
            let newStats = EndlessModeStats()
            modelContext.insert(newStats)
            return newStats
        }
    }

    var body: some View {
        ZStack {
            // Arka plan
            LinearGradient(
                colors: [Color.purple.opacity(0.3), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Oyun sahnesi
            if let scene = scene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
            }

            // Üst bar
            VStack {
                HStack(alignment: .top) {
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

                    // Endless mode bilgileri
                    VStack(spacing: 8) {
                        HStack(spacing: 15) {
                            // Wave
                            VStack(spacing: 4) {
                                Text("DALGA")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.7))
                                Text("\(endlessLevel.wave)")
                                    .font(.title2.bold())
                                    .foregroundColor(.cyan)
                            }

                            Divider()
                                .frame(height: 40)
                                .background(Color.white.opacity(0.3))

                            // Skor
                            VStack(spacing: 4) {
                                Text("SKOR")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.7))
                                Text("\(endlessLevel.totalScore)")
                                    .font(.title2.bold())
                                    .foregroundColor(.yellow)
                            }

                            Divider()
                                .frame(height: 40)
                                .background(Color.white.opacity(0.3))

                            // Kontaminasyon
                            VStack(spacing: 4) {
                                Text("TEMİZLİK")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.7))
                                Text("\(Int(endlessLevel.contamination))%")
                                    .font(.title2.bold())
                                    .foregroundColor(contaminationColor)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(15)

                        // Wave progress
                        HStack(spacing: 8) {
                            Text(endlessLevel.waveDescription)
                                .font(.caption)
                                .foregroundColor(.white)
                            ProgressView(value: endlessLevel.nextWaveProgress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .cyan))
                                .frame(width: 100)
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                    }

                    Spacer()

                    // Pause butonu
                    Button(action: {
                        showingPause = true
                        scene?.isPaused = true
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
                EndlessResultView(
                    score: endlessLevel.totalScore,
                    wave: endlessLevel.wave,
                    wasteProcessed: endlessLevel.wasteProcessed,
                    bestCombo: endlessLevel.bestCombo,
                    highScore: stats.highScore,
                    onReplay: {
                        restartGame()
                    },
                    onMenu: {
                        dismiss()
                    }
                )
            }

            // Pause menü
            if showingPause {
                PauseMenuView(
                    onResume: {
                        showingPause = false
                        scene?.isPaused = false
                    },
                    onRestart: {
                        showingPause = false
                        restartGame()
                    },
                    onExit: {
                        dismiss()
                    }
                )
            }
        }
        .onAppear {
            setupGame()
        }
    }

    private var contaminationColor: Color {
        if endlessLevel.contamination > 70 {
            return .green
        } else if endlessLevel.contamination > 40 {
            return .orange
        } else {
            return .red
        }
    }

    private func setupGame() {
        endlessLevel = EndlessLevel()

        let screenSize = CGSize(width: 390, height: 844)
        let newScene = GameScene(size: screenSize)
        newScene.scaleMode = .aspectFill

        // Endless mod ile başlat
        // TODO: GameScene'e endless mode desteği ekle

        scene = newScene
    }

    private func restartGame() {
        showingResults = false
        setupGame()
    }

    private func handleGameEnd() {
        // İstatistikleri kaydet
        stats.updateStats(
            score: endlessLevel.totalScore,
            combo: endlessLevel.bestCombo,
            waste: endlessLevel.wasteProcessed,
            wave: endlessLevel.wave
        )

        showingResults = true
    }
}

// MARK: - Sonuç Ekranı

struct EndlessResultView: View {
    let score: Int
    let wave: Int
    let wasteProcessed: Int
    let bestCombo: Int
    let highScore: Int
    let onReplay: () -> Void
    let onMenu: () -> Void

    var isNewRecord: Bool {
        score > highScore
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 25) {
                // Başlık
                if isNewRecord {
                    Text("🏆 YENİ REKOR! 🏆")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.yellow)
                } else {
                    Text("Oyun Bitti")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }

                // İstatistikler
                VStack(spacing: 15) {
                    StatRow(label: "Final Skoru", value: "\(score)", color: .yellow)
                    StatRow(label: "Ulaşılan Dalga", value: "\(wave)", color: .cyan)
                    StatRow(label: "İşlenen Atık", value: "\(wasteProcessed)", color: .green)
                    StatRow(label: "En Yüksek Combo", value: "\(bestCombo)", color: .orange)

                    Divider()
                        .background(Color.white.opacity(0.3))

                    StatRow(label: "Rekor", value: "\(max(score, highScore))", color: .purple)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)

                // Butonlar
                VStack(spacing: 15) {
                    Button(action: onReplay) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Tekrar Oyna")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
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
            .padding(30)
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(value)
                .font(.title3.bold())
                .foregroundColor(color)
        }
    }
}

#Preview {
    EndlessModeView()
        .modelContainer(for: [EndlessModeStats.self])
}
