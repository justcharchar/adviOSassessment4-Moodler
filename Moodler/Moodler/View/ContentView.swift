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

    var body: some View {
        if !hasSeenOnboarding {
            OnboardingView()
        } else if !isLoggedIn {
            LoginSignupView()
        } else {
            MainTabView()
        }
    }
}

#Preview {
    ContentView()
}

