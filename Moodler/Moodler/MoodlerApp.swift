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

    @StateObject private var profileVM = ProfileViewModel(
        context: PersistenceController.shared.container.viewContext
    )
    @StateObject private var journalVM = JournalViewModel(
        context: PersistenceController.shared.container.viewContext
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(profileVM)
                .environmentObject(journalVM)
        }
    }
}
