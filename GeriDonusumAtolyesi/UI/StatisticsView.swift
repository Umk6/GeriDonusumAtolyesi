//
//  StatisticsView.swift
//  GeriDonusumAtolyesi
//
//  İstatistik ekranı
//

import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var statistics: [GameStatistics]

    var stats: GameStatistics {
        if let existing = statistics.first {
            return existing
        } else {
            let newStats = GameStatistics()
            modelContext.insert(newStats)
            return newStats
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Arka plan
                LinearGradient(
                    colors: [Color(red: 0.2, green: 0.5, blue: 0.7), Color(red: 0.1, green: 0.3, blue: 0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 25) {
                        // Genel İstatistikler
                        StatSection(title: "📊 Genel") {
                            StatGrid(stats: [
                                ("🎮", "Oyun", "\(stats.totalGamesPlayed)"),
                                ("⭐", "Toplam Puan", "\(stats.totalScore)"),
                                ("🏆", "Perfect", "\(stats.perfectLevels)"),
                                ("⏱️", "Süre", stats.formattedPlayTime)
                            ])
                        }

                        // Geri Dönüşüm İstatistikleri
                        StatSection(title: "♻️ Geri Dönüşüm") {
                            VStack(spacing: 15) {
                                RecyclingBar(
                                    icon: "🧴",
                                    label: "Plastik",
                                    count: stats.plasticRecycled,
                                    total: stats.totalWasteRecycled,
                                    color: .blue
                                )

                                RecyclingBar(
                                    icon: "📄",
                                    label: "Kağıt",
                                    count: stats.paperRecycled,
                                    total: stats.totalWasteRecycled,
                                    color: .brown
                                )

                                RecyclingBar(
                                    icon: "🥫",
                                    label: "Metal",
                                    count: stats.metalRecycled,
                                    total: stats.totalWasteRecycled,
                                    color: .gray
                                )

                                RecyclingBar(
                                    icon: "🍾",
                                    label: "Cam",
                                    count: stats.glassRecycled,
                                    total: stats.totalWasteRecycled,
                                    color: .cyan
                                )
                            }
                        }

                        // Rekorlar
                        StatSection(title: "🏅 Rekorlar") {
                            VStack(spacing: 12) {
                                RecordRow(
                                    icon: "🔥",
                                    label: "En Yüksek Combo",
                                    value: "x\(stats.bestCombo)"
                                )

                                RecordRow(
                                    icon: "📈",
                                    label: "Ortalama Puan",
                                    value: "\(stats.averageScore)"
                                )

                                RecordRow(
                                    icon: "♻️",
                                    label: "Toplam Geri Dönüşüm",
                                    value: "\(stats.totalWasteRecycled)"
                                )
                            }
                        }

                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("İstatistikler")
                        .font(.headline)
                        .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct StatSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            content
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
        }
    }
}

struct StatGrid: View {
    let stats: [(icon: String, label: String, value: String)]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            ForEach(stats.indices, id: \.self) { index in
                let stat = stats[index]
                VStack(spacing: 8) {
                    Text(stat.icon)
                        .font(.largeTitle)

                    Text(stat.value)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(stat.label)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
}

struct RecyclingBar: View {
    let icon: String
    let label: String
    let count: Int
    let total: Int
    let color: Color

    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(icon)
                    .font(.title3)

                Text(label)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(count)")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 5)
                        .fill(color)
                        .frame(width: geometry.size.width * percentage, height: 10)
                }
            }
            .frame(height: 10)
        }
    }
}

struct RecordRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(icon)
                .font(.title2)

            Text(label)
                .foregroundColor(.white)

            Spacer()

            Text(value)
                .foregroundColor(.yellow)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: [GameStatistics.self])
}
