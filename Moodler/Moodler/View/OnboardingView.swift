//
//  OnboardingView.swift
//  Moodler
//
//  Created by Owen Herianto on 16/10/2025.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        TabView {
            OnboardingPage(
                image: "book.closed",
                title: "Welcome to Moodler",
                description: "Track your thoughts and feelings in a simple and meaningful way."
            )
            
            OnboardingPage(
                image: "brain.head.profile",
                title: "Understand Your Mood",
                description: "Use smart mood tracking to discover patterns and insights over time."
            )
            
            OnboardingPage(
                image: "bell.badge",
                title: "Stay Consistent",
                description: "Set daily reminders and write journal entries effortlessly."
            )
        }
        .tabViewStyle(PageTabViewStyle())
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            Button(action: {
                hasSeenOnboarding = true
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
            }
        }
    }
}

struct OnboardingPage: View {
    var image: String
    var title: String
    var description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding()
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}
