//
//  BoosterBarView.swift
//  GeriDonusumAtolyesi
//
//  Oyun sırasında booster bar
//

import SwiftUI

struct BoosterBarView: View {
    let onBoosterUsed: (BoosterType) -> Void

    @State private var selectedBoosters: [BoosterType] = [.magnet, .cleanSpray, .superPress]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(selectedBoosters, id: \.self) { booster in
                BoosterButton(type: booster, onTap: {
                    onBoosterUsed(booster)
                })
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.3))
        .cornerRadius(20)
    }
}

struct BoosterButton: View {
    let type: BoosterType
    let onTap: () -> Void

    @State private var count = 0
    @State private var isAvailable = true

    var body: some View {
        Button(action: {
            if isAvailable && count > 0 {
                onTap()
                updateState()
            }
        }) {
            ZStack {
                Circle()
                    .fill(isAvailable && count > 0 ?
                          LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing) :
                          LinearGradient(colors: [.gray, .gray.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 50, height: 50)
                    .shadow(radius: 5)

                Text(type.icon)
                    .font(.title2)

                // Count badge
                if count > 0 {
                    Text("\(count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Circle().fill(Color.red))
                        .offset(x: 18, y: -18)
                }
            }
        }
        .disabled(!isAvailable || count == 0)
        .opacity(isAvailable && count > 0 ? 1.0 : 0.5)
        .onAppear {
            updateState()
        }
    }

    private func updateState() {
        count = BoosterManager.shared.getCount(for: type)
        isAvailable = BoosterManager.shared.canUse(type)
    }
}

#Preview {
    BoosterBarView(onBoosterUsed: { _ in })
}
