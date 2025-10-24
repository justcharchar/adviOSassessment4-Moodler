//
//  HomeView.swift
//  Moodler
//
//  Created by Ceri Tahimic on 18/10/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var journalModel: JournalViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @Binding var selectedTab: Int
    @State private var showJournalEntry = false

    let dailyQuote = "The journey of a thousand miles begins with a single step."

    private let allMoods = ["Joy", "Sadness", "Fear", "Anger", "Surprise", "Love"]

    private let moodPolarity: [String: Int] = [
        "Joy": 1,
        "Love": 1,
        "Surprise": 1,
        "Sadness": -1,
        "Anger": -1,
        "Fear": -1
    ]

    private let brandBackground = Color(red: 0.976, green: 0.953, blue: 0.929)
    private let cardColor = Color(red: 0.957, green: 0.910, blue: 0.875)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // MARK: - Greeting
                    VStack(alignment: .leading, spacing: 6) {
                        Text(todaysDateString)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("Hello, \(profileVM.profile?.name ?? "there")!")
                            .font(.largeTitle.bold())
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    // MARK: - Mood Card
                    moodSummaryCard

                    // MARK: - Quick Journal Button
                    quickJournalButton

                    // MARK: - Daily Quote
                    dailyQuoteSection

                    // MARK: - Weekly Mood Graph
                    weeklyMoodSection
                }
                .padding(.vertical)
            }
            .navigationTitle("My Journal")
            .navigationBarItems(trailing: settingsButton)
            .background(brandBackground.ignoresSafeArea())
            .fullScreenCover(isPresented: $showJournalEntry) {
                if let draft = journalModel.draftJournal {
                    JournalDetailView(journal: draft)
                        .environmentObject(journalModel)
                }
            }
            .onAppear {
                journalModel.fetchJournals()
                _ = todayMoodResult
            }
        }
    }

    // MARK: - Mood Summary
    private var moodSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: moodIcon)
                    .font(.title2)
                    .foregroundColor(moodColor)
                Text("Today's Mood")
                    .font(.headline)
                Spacer()
                Text(todayMoodResult)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(moodColor)
            }
            Text(todayMoodDescription)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(cardColor)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
        .padding(.horizontal)
    }

    private var todayMoodResult: String {
        let today = Date()
        let todaysJournals = journalModel.entries.filter { entry in
            guard let date = entry.date else { return false }
            return Calendar.current.isDate(date, inSameDayAs: today)
        }

        let score = todaysJournals.reduce(0) { total, entry in
            let mood = entry.emotion?.capitalized.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return total + (moodPolarity[mood] ?? 0)
        }

        if score > 0 { return "Positive" }
        if score < 0 { return "Negative" }
        return "Neutral"
    }

    private var todayMoodDescription: String {
        switch todayMoodResult {
        case "Positive":
            return "Based on today's journals, you're feeling more positive overall."
        case "Negative":
            return "Today's entries lean towards negative emotions."
        default:
            return "Today's mood is balanced between positive and negative feelings."
        }
    }

    private var moodIcon: String {
        switch todayMoodResult {
        case "Positive": return "sun.max.fill"
        case "Negative": return "cloud.rain.fill"
        default: return "cloud.fill"
        }
    }

    private var moodColor: Color {
        switch todayMoodResult {
        case "Positive": return .green
        case "Negative": return .red
        default: return .orange
        }
    }

    // MARK: - Quick Journal Button
    private var quickJournalButton: some View {
        Button(action: {
            let newJournal = journalModel.addJournal()
            journalModel.draftJournal = newJournal
            showJournalEntry = true
        }) {
            HStack {
                Image(systemName: "pencil")
                    .font(.title2)
                Text("Write Today's Journal")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .foregroundColor(.white)
            .padding()
            .background(LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
            .cornerRadius(18)
            .shadow(color: .purple.opacity(0.2), radius: 5, x: 0, y: 3)
        }
        .padding(.horizontal)
    }

    // MARK: - Daily Quote
    private var dailyQuoteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "quote.bubble")
                    .font(.headline)
                    .foregroundColor(.orange)
                Text("Daily Reflection")
                    .font(.headline)
                Spacer()
            }
            Text(dailyQuote)
                .font(.body)
                .italic()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(cardColor)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Weekly Mood Section
    private var weeklyMoodSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weekly Mood Overview")
                    .font(.title2.bold())
                Spacer()
                Button {
                    selectedTab = 2
                } label: {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
            }
            MoodGraphView(moodData: weeklyMoodDataPoints)
        }
        .padding(.horizontal)
    }

    private var weeklyMoodDataPoints: [MoodDataPoint] {
        let startOfWeek = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let endOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: startOfWeek) ?? Date()

        let journals = journalModel.entries.filter { entry in
            guard let mood = entry.emotion?.capitalized, !mood.isEmpty, let date = entry.date else { return false }
            return date >= startOfWeek && date <= endOfWeek
        }

        let grouped = Dictionary(grouping: journals) { ($0.emotion ?? "").capitalized }
        return allMoods.map { mood in
            MoodDataPoint(mood: mood, count: grouped[mood]?.count ?? 0)
        }
    }

    // MARK: - Settings
    private var settingsButton: some View {
        NavigationLink(destination: SettingsView()) {
            Image(systemName: "gearshape.fill")
                .font(.headline)
                .foregroundColor(.black)
        }
    }

    // MARK: - Helpers
    private var todaysDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }
}
