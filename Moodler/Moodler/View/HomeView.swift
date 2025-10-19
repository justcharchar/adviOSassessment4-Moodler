//
//  HomeView.swift
//  Moodler
//
//  Created by Ceri Tahimic on 18/10/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var journalModel: JournalViewModel
    @State private var showJournalEntry = false
    @State private var userName = "Alex"
    @State private var currentMood = "Positive"
    @State private var weeklyMoodData: [MoodData] = []
    @State private var newJournal: JournalEntry?
    
    
    let dailyQuote = "The journey of a thousand miles begins with a single step."
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with date and greeting
                    headerSection
                    
                    // Mood summary card
                    moodSummaryCard
                    
                    // Quick journal button
                    quickJournalButton
                    
                    // Daily quote section
                    dailyQuoteSection
                    
                    // Weekly mood graph preview
                    weeklyMoodGraph
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("My Journal")
            .navigationBarItems(trailing: settingsButton)
            .background(Color(.systemGroupedBackground))
            .fullScreenCover(isPresented: $showJournalEntry) {
                if let draft = journalModel.draftJournal {
                    JournalDetailView(journal: draft)
                        .environmentObject(journalModel)
                }
            }
            .onAppear {
                loadSampleData()
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(todaysDateString)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Hello, \(userName)!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Mood Summary Card
    private var moodSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: moodIcon)
                    .font(.title2)
                    .foregroundColor(moodColor)
                
                Text("Today's Mood")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(currentMood)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(moodColor)
            }
            
            Text("Feeling \(currentMood.lowercased()) today. Ready to reflect on your day?")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Quick Journal Button
    private var quickJournalButton: some View {
        Button(action: {
            journalModel.addJournal()
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
                    .foregroundColor(.secondary)
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Daily Quote Section
    private var dailyQuoteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "quote.bubble")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Text("Daily Reflection")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text(dailyQuote)
                .font(.body)
                .italic()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Weekly Mood Graph
    private var weeklyMoodGraph: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weekly Mood")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                NavigationLink("See All", destination: MoodHistoryView())
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            if weeklyMoodData.isEmpty {
                Text("No mood data yet. Start journaling to track your mood!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
            } else {
                MoodGraphView(moodData: weeklyMoodData)
                    .frame(height: 100)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Settings Button
    private var settingsButton: some View {
        NavigationLink(destination: SettingsView()) {
            Image(systemName: "gearshape")
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - Computed Properties
    private var todaysDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }
    
    private var moodIcon: String {
        switch currentMood {
        case "Positive": return "sun.max"
        case "Neutral": return "cloud"
        case "Negative": return "cloud.rain"
        default: return "face.smiling"
        }
    }
    
    private var moodColor: Color {
        switch currentMood {
        case "Positive": return .green
        case "Neutral": return .orange
        case "Negative": return .red
        default: return .blue
        }
    }
    
    // MARK: - Helper Methods
    private func loadSampleData() {
        // Sample mood data for the week
        weeklyMoodData = [
            MoodData(day: "Mon", mood: "Positive"),
            MoodData(day: "Tue", mood: "Neutral"),
            MoodData(day: "Wed", mood: "Positive"),
            MoodData(day: "Thu", mood: "Negative"),
            MoodData(day: "Fri", mood: "Positive"),
            MoodData(day: "Sat", mood: "Positive"),
            MoodData(day: "Sun", mood: "Neutral")
        ]
    }
}


