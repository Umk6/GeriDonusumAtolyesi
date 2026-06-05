//
//  SettingsView.swift
//  GeriDonusumAtolyesi
//
//  Ayarlar ekranı
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("musicEnabled") private var musicEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    @AppStorage("tutorialShown") private var tutorialShown = false
    @State private var showStatistics = false

    var body: some View {
        NavigationView {
            ZStack {
                // Arka plan
                LinearGradient(
                    colors: [Color(red: 0.3, green: 0.6, blue: 0.8), Color(red: 0.2, green: 0.4, blue: 0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 25) {
                        // Ses Ayarları
                        SettingsSection(title: "🔊 Ses Ayarları") {
                            SettingsToggle(
                                title: "Ses Efektleri",
                                isOn: $soundEnabled,
                                icon: "speaker.wave.3.fill"
                            )

                            SettingsToggle(
                                title: "Müzik",
                                isOn: $musicEnabled,
                                icon: "music.note"
                            )

                            SettingsToggle(
                                title: "Titreşim (Haptic)",
                                isOn: $hapticEnabled,
                                icon: "waveform"
                            )
                        }

                        // Oyun Ayarları
                        SettingsSection(title: "🎮 Oyun") {
                            Button(action: {
                                tutorialShown = false
                            }) {
                                HStack {
                                    Image(systemName: "book.fill")
                                        .foregroundColor(.blue)
                                        .frame(width: 30)

                                    Text("Tutorial'ı Tekrar Göster")
                                        .foregroundColor(.white)

                                    Spacer()

                                    Image(systemName: "arrow.clockwise")
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }

                        // Veri
                        SettingsSection(title: "💾 Veri") {
                            Button(action: {
                                showStatistics = true
                            }) {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                        .foregroundColor(.green)
                                        .frame(width: 30)

                                    Text("İstatistikler")
                                        .foregroundColor(.white)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }

                        // Hakkında
                        SettingsSection(title: "ℹ️ Hakkında") {
                            VStack(alignment: .leading, spacing: 10) {
                                InfoRow(label: "Versiyon", value: "1.0.0")
                                InfoRow(label: "Geliştirici", value: "UMK Games")
                                InfoRow(label: "Platform", value: "iOS")
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }

                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Ayarlar")
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
        .onChange(of: soundEnabled) { _, newValue in
            AudioManager.shared.setSoundEnabled(newValue)
        }
        .onChange(of: musicEnabled) { _, newValue in
            AudioManager.shared.setMusicEnabled(newValue)
        }
        .sheet(isPresented: $showStatistics) {
            StatisticsView()
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.leading, 5)

            content
        }
    }
}

struct SettingsToggle: View {
    let title: String
    @Binding var isOn: Bool
    let icon: String

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 30)

                Text(title)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .tint(.green)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    SettingsView()
}
