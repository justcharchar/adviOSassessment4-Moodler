//
//  MoodlerWidget.swift
//  MoodlerWidgetExtension
//
//  Created by Owen Herianto on 25/10/2025.
//

import WidgetKit
import SwiftUI

// MARK: - Entry
struct MoodlerEntry: TimelineEntry {
    let date: Date
    let title: String
    let subtitle: String
}

// MARK: - Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> MoodlerEntry {
        MoodlerEntry(
            date: .now,
            title: "Your latest journal ✍️",
            subtitle: "Reflect, reset, and keep writing."
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MoodlerEntry) -> Void) {
        let entry = MoodlerEntry(
            date: .now,
            title: "Gratitude Journal 🌅",
            subtitle: "Remember today’s highlight."
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MoodlerEntry>) -> Void) {
        let currentDate = Date()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let entry = MoodlerEntry(
            date: currentDate,
            title: "Keep journaling today 💭",
            subtitle: "A fresh mind starts with reflection."
        )

        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - View
struct MoodlerWidgetEntryView: View {
    var entry: MoodlerEntry

    var body: some View {
        ZStack(alignment: .leading) {
            Color(.secondarySystemBackground)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Text(entry.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                Spacer()

                HStack {
                    Spacer()
                    Text(entry.date, style: .time)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
    }
}

// MARK: - Widget Declaration
struct MoodlerWidget: Widget {
    let kind: String = "MoodlerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MoodlerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Moodler Journal")
        .description("Stay mindful — view your latest journal insights right on your Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    MoodlerWidget()
} timeline: {
    MoodlerEntry(date: .now, title: "Preview Journal 🪶", subtitle: "Tap to open Moodler.")
}
