//
//  InsightsView.swift
//  Moodler
//
//  Created by Owen on 21/10/2025.
//

import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject var journalModel: JournalViewModel
    @State private var currentDate = Date()
    @State private var viewMode: ViewMode = .day

    enum ViewMode: String, CaseIterable {
        case day = "Day"
        case week = "Week"
    }

    private let allMoods = ["Joy", "Sadness", "Fear", "Anger", "Surprise", "Love"]

    private let moodColors: [String: Color] = [
        "Joy": .green,
        "Sadness": .blue,
        "Fear": .purple,
        "Anger": .red,
        "Surprise": .orange,
        "Love": .pink
    ]
    
    private let brandBackground = Color(red: 0.976, green: 0.953, blue: 0.929)
    private let cardColor = Color(red: 0.957, green: 0.910, blue: 0.875)

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("📈 Mood Insights")
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                    Text("Visualise how your emotions change over time.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                Picker("View Mode", selection: $viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                HStack {
                    Button(action: { shiftDate(-1) }) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundColor(.purple)
                    }
                    Spacer()
                    Text(displayDateTitle)
                        .font(.headline)
                    Spacer()
                    Button(action: { shiftDate(1) }) {
                        Image(systemName: "chevron.right")
                            .font(.headline)
                            .foregroundColor(.purple)
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 16) {
                    Text("Mood Frequency")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if moodData.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "chart.bar.doc.horizontal")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            Text("No mood data available for this period.")
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 260)
                    } else {
                        Chart {
                            ForEach(moodData) { item in
                                BarMark(
                                    x: .value("Mood", item.mood),
                                    y: .value("Count", item.count)
                                )
                                .foregroundStyle(moodColors[item.mood, default: .gray])
                                .cornerRadius(6)
                                .annotation(position: .top) {
                                    if item.count > 0 {
                                        Text("\(item.count)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: allMoods) { mood in
                                if let moodStr = mood.as(String.self) {
                                    AxisValueLabel {
                                        Text(moodStr)
                                            .font(.caption2)
                                            .foregroundColor(moodColors[moodStr, default: .gray])
                                    }
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) {
                                AxisGridLine()
                                AxisValueLabel()
                            }
                        }
                        .chartYScale(domain: 0...max(5, moodData.map(\.count).max() ?? 1))
                        .frame(height: 340)
                        .padding(.top, 12)
                        .animation(.easeInOut, value: moodData)
                    }
                }
                .padding()
                .background(cardColor)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .onAppear {
            journalModel.fetchJournals()
        }
        .background(brandBackground.ignoresSafeArea())
    }

    private var moodData: [MoodDataPoint] {
        let filtered = journalModel.entries.filter { entry in
            guard let mood = entry.emotion?.capitalized, !mood.isEmpty else { return false }
            guard let date = entry.date else { return false }

            switch viewMode {
            case .day:
                return Calendar.current.isDate(date, inSameDayAs: currentDate)
            case .week:
                guard let interval = Calendar.current.dateInterval(of: .weekOfYear, for: currentDate) else { return false }
                return interval.contains(date)
            }
        }

        let grouped = Dictionary(grouping: filtered) { ($0.emotion ?? "Unknown").capitalized }
        return allMoods.map { mood in
            MoodDataPoint(mood: mood, count: grouped[mood]?.count ?? 0)
        }
    }

    private var displayDateTitle: String {
        let formatter = DateFormatter()
        switch viewMode {
        case .day:
            formatter.dateStyle = .medium
            return formatter.string(from: currentDate)
        case .week:
            guard let interval = Calendar.current.dateInterval(of: .weekOfYear, for: currentDate) else { return "" }
            formatter.dateFormat = "MMM d"
            return "\(formatter.string(from: interval.start)) - \(formatter.string(from: interval.end))"
        }
    }

    private func shiftDate(_ amount: Int) {
        switch viewMode {
        case .day:
            currentDate = Calendar.current.date(byAdding: .day, value: amount, to: currentDate) ?? currentDate
        case .week:
            currentDate = Calendar.current.date(byAdding: .weekOfYear, value: amount, to: currentDate) ?? currentDate
        }
    }
}
