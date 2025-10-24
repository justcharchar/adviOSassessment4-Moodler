//
//  MainTab.swift
//  Moodler
//
//  Created by Owen Herianto on 17/10/2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)

            JournalListView()
                .tabItem { Label("Journal", systemImage: "book.closed") }
                .tag(1)

            InsightsView()
                .tabItem { Label("Insights", systemImage: "chart.bar") }
                .tag(2)

            FavouriteJournalView()
                .tabItem { Label("Favourites", systemImage: "heart.fill") }
                .tag(3)
        }
    }
}
