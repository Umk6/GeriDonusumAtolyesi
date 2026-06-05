//
//  TutorialOverlay.swift
//  GeriDonusumAtolyesi
//
//  İlk seviye tutorial overlay
//

import SwiftUI

struct TutorialOverlay: View {
    let onDismiss: () -> Void

    @State private var currentStep = 0

    let steps: [(icon: String, title: String, description: String)] = [
        ("hand.point.up.left.fill", "Sürükle & Bırak", "Atıkları sürükleyip taşı"),
        ("arrow.triangle.merge", "Birleştir", "Aynı renk ve seviyedeki atıkları birleştir"),
        ("star.fill", "Puan Kazan", "Hedef puanı topla ve seviyeyi geç!"),
    ]

    var body: some View {
        ZStack {
            // Yarı saydam arka plan
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    nextStep()
                }

            VStack(spacing: 40) {
                Spacer()

                // Icon
                Image(systemName: steps[currentStep].icon)
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .shadow(radius: 10)

                VStack(spacing: 15) {
                    // Title
                    Text(steps[currentStep].title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // Description
                    Text(steps[currentStep].description)
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Progress dots
                HStack(spacing: 12) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentStep ? Color.yellow : Color.white.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }

                // Continue button
                Button(action: nextStep) {
                    HStack {
                        Text(currentStep < steps.count - 1 ? "Devam" : "Başla!")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(Color.yellow)
                    .cornerRadius(25)
                    .shadow(color: .yellow.opacity(0.5), radius: 10)
                }

                Spacer()
            }
        }
        .transition(.opacity)
    }

    private func nextStep() {
        if currentStep < steps.count - 1 {
            withAnimation {
                currentStep += 1
            }
        } else {
            onDismiss()
        }
    }
}

#Preview {
    TutorialOverlay(onDismiss: {})
}
