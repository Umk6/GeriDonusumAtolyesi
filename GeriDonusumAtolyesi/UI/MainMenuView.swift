//
//  MainMenuView.swift
//  GeriDonusumAtolyesi
//
//  Ana menü ekranı
//

import SwiftUI
import SwiftData

struct MainMenuView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var playerData: [PlayerData]

    var player: PlayerData {
        if let existing = playerData.first {
            return existing
        } else {
            let newPlayer = PlayerData()
            modelContext.insert(newPlayer)
            return newPlayer
        }
    }

    var body: some View {
        ZStack {
            // Arka plan
            LinearGradient(
                colors: [Color(red: 0.4, green: 0.8, blue: 0.6), Color(red: 0.2, green: 0.6, blue: 0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                // Logo ve başlık
                VStack(spacing: 10) {
                    Text("♻️")
                        .font(.system(size: 80))

                    Text("Geri Dönüşüm")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)

                    Text("Fabrikası")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                // Menü butonları
                VStack(spacing: 15) {
                    MenuButton(
                        title: "OYNA",
                        icon: "play.fill",
                        color: .green
                    ) {
                        // Level seçim ekranına git
                    }

                    MenuButton(
                        title: "Sonsuz Mod",
                        icon: "infinity",
                        color: .blue
                    ) {
                        // Sonsuz moda git
                    }

                    MenuButton(
                        title: "Fabrika",
                        icon: "gear",
                        color: .orange
                    ) {
                        // Fabrika geliştirme
                    }

                    MenuButton(
                        title: "Koleksiyon",
                        icon: "square.grid.2x2",
                        color: .purple
                    ) {
                        // Koleksiyon ekranı
                    }
                }
                .padding(.horizontal, 40)

                Spacer()

                // Yeşil puan göstergesi
                HStack {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(.green)
                    Text("\(player.greenPoints)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(20)

                Spacer()
            }
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(15)
            .shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 5)
        }
    }
}

#Preview {
    MainMenuView()
        .modelContainer(for: [PlayerData.self, Level.self])
}
