//
//  MoodGraphView.swift
//  Moodler
//
//  Created by Ceri Tahimic on 18/10/2025.
//

import SwiftUI

struct MoodGraphView: View {
    let moodData: [MoodData]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(moodData) { data in
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(moodColor(for: data.mood))
                        .frame(height: CGFloat(moodHeight(for: data.mood)))
                        .cornerRadius(4)
                    
                    Text(data.day)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
    
    private func moodHeight(for mood: String) -> Double {
        switch mood {
        case "Positive": return 80
        case "Neutral": return 50
        case "Negative": return 30
        default: return 40
        }
    }
    
    private func moodColor(for mood: String) -> Color {
        switch mood {
        case "Positive": return .green
        case "Neutral": return .orange
        case "Negative": return .red
        default: return .gray
        }
    }
}


