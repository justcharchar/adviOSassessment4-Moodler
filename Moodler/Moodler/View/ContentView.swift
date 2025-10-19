//
//  ContentView.swift
//  Moodler
//
//  Created by Chloe on 15/10/2025.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("isSignedUp") private var isSignedUp = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    @StateObject private var journalModel = JournalViewModel()

    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView()
            } else if !isLoggedIn {
                LoginSignupView()
            } else {
                MainTabView()
                    .environmentObject(journalModel)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
