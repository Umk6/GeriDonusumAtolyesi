//
//  PauseMenuView.swift
//  GeriDonusumAtolyesi
//
//  Oyun duraklatma menüsü
//

import SwiftUI

struct PauseMenuView: View {
    let onResume: () -> Void
    let onRestart: () -> Void
    let onExit: () -> Void

    var body: some View {
        ZStack {
            // Blur arka plan
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // Başlık
                Text("⏸️")
                    .font(.system(size: 80))

                Text("Duraklatıldı")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Spacer()
                    .frame(height: 20)

                // Menü butonları
                VStack(spacing: 15) {
                    PauseMenuButton(
                        title: "Devam Et",
                        icon: "play.fill",
                        color: .green,
                        action: onResume
                    )

                    PauseMenuButton(
                        title: "Yeniden Başlat",
                        icon: "arrow.clockwise",
                        color: .orange,
                        action: onRestart
                    )

                    PauseMenuButton(
                        title: "Ana Menü",
                        icon: "house.fill",
                        color: .red,
                        action: onExit
                    )
                }
                .padding(.horizontal, 40)
            }
            .padding(40)
        }
    }
}

struct PauseMenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
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
    PauseMenuView(
        onResume: {},
        onRestart: {},
        onExit: {}
    )
}
