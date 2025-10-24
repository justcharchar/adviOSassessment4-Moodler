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
    
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var journalVM: JournalViewModel
    
    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView()
            } else if !isLoggedIn {
                LoginSignupView()
            } else {
                MainTabView()
                    .onAppear {
                        if let user = profileVM.profile {
                            journalVM.setCurrentUser(user)
                            journalVM.fetchJournals()
                        }
                    }
            }
        }
    }
}
