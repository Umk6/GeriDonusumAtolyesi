//
//  GeriDonusumAtolyesiApp.swift
//  GeriDonusumAtolyesi
//
//  Created by Umut Mert Kırmızıtaş on 5.06.2026.
//

import SwiftUI
import SwiftData

@main
struct GeriDonusumAtolyesiApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PlayerData.self,
            Level.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }
        .modelContainer(sharedModelContainer)
    }
}
