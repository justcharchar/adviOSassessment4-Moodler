//
//  OnboardingView.swift
//  Moodler
//
//  Created by Owen Herianto on 22/10/2025.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0

    private let brandBackground = Color(red: 0.976, green: 0.953, blue: 0.929)
    private let cardColor = Color(red: 0.957, green: 0.910, blue: 0.875)

    let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "onboarding_1",
            title: "Write & Reflect",
            description: "Capture your thoughts, moods, and moments in your personal journal. Moodler helps you express yourself and track how you feel over time."
        ),
        OnboardingPage(
            imageName: "onboarding_2",
            title: "Understand Your Emotions",
            description: "See patterns in your emotions through mood analysis powered by Machine Learning. Discover what makes you feel your best and what brings you down."
        ),
        OnboardingPage(
            imageName: "onboarding_3",
            title: "Let's Get Started!",
            description: "Begin your journaling journey with Moodler. Your space to write, reflect, and grow every day."
        )
    ]

    var body: some View {
        ZStack {
            brandBackground.ignoresSafeArea()

            VStack {
                Spacer()

                // MARK: - Image Card
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(cardColor)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .frame(maxWidth: 320, maxHeight: 320)

                    Image(pages[currentPage].imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 260, maxHeight: 260)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                        .animation(.easeInOut, value: currentPage)
                }
                .padding(.bottom, 40)

                // MARK: - Title
                Text(pages[currentPage].title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black.opacity(0.85))
                    .padding(.horizontal, 40)
                    .padding(.bottom, 8)

                // MARK: - Description
                Text(pages[currentPage].description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
                    .padding(.bottom, 30)

                Spacer()

                // MARK: - Page Indicator
                HStack(spacing: 10) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.purple : Color.gray.opacity(0.3))
                            .frame(width: index == currentPage ? 12 : 10, height: index == currentPage ? 12 : 10)
                            .scaleEffect(index == currentPage ? 1.2 : 1)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 24)

                // MARK: - Next / Get Started Button
                Button(action: nextPage) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [.purple, .blue],
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .cornerRadius(14)
                        .shadow(color: .purple.opacity(0.2), radius: 5, x: 0, y: 3)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 60)
            }
            .animation(.easeInOut, value: currentPage)
        }
    }

    private func nextPage() {
        if currentPage < pages.count - 1 {
            currentPage += 1
        } else {
            hasSeenOnboarding = true
        }
    }
}

// MARK: - Model
struct OnboardingPage {
    let imageName: String
    let title: String
    let description: String
}
