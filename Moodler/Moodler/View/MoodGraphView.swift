//
//  MoodGraphView.swift
//  Moodler
//
//  Created by Ceri Tahimic on 18/10/2025.
//

import SwiftUI
import Charts

struct MoodGraphView: View {
    let moodData: [MoodDataPoint]
    
    private let allMoods = ["Joy", "Sadness", "Fear", "Anger", "Surprise", "Love"]
    
    private let moodColors: [String: Color] = [
        "Joy": .green,
        "Sadness": .blue,
        "Fear": .purple,
        "Anger": .red,
        "Surprise": .orange,
        "Love": .pink
    ]
    
    private let cardColor = Color(red: 0.957, green: 0.910, blue: 0.875)
    
    var body: some View {
        ZStack {
            cardColor.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 8) {
                if moodData.isEmpty {
                    VStack(spacing: 6) {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                        Text("No mood data yet")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                } else {
                    Chart {
                        ForEach(moodData) { item in
                            BarMark(
                                x: .value("Mood", item.mood),
                                y: .value("Count", item.count)
                            )
                            .foregroundStyle(moodColors[item.mood, default: .gray])
                            .cornerRadius(5)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: allMoods) { mood in
                            if let moodStr = mood.as(String.self) {
                                AxisValueLabel {
                                    Text(moodStr)
                                        .font(.caption2)
                                        .foregroundColor(moodColors[moodStr, default: .gray])
                                        .rotationEffect(.degrees(-20))
                                        .frame(width: 50)
                                }
                            }
                        }
                    }
                    .chartYAxis(.hidden)
                    .frame(height: 180)
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardColor)
            )
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
    }
}
