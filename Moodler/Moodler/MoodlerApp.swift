//
//  MoodlerApp.swift
//  Moodler
//
//  Created by Chloe on 15/10/2025.
//

import SwiftUI

@main
struct MoodlerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
