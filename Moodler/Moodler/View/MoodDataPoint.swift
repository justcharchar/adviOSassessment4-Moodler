//
//  MoodDataPoint.swift
//  Moodler
//
//  Created by Owen Herianto on 21/10/2025.
//

import Foundation

struct MoodDataPoint: Identifiable, Equatable {
    let id = UUID()
    let mood: String
    let count: Int

    static func == (lhs: MoodDataPoint, rhs: MoodDataPoint) -> Bool {
        lhs.mood == rhs.mood && lhs.count == rhs.count
    }
}
