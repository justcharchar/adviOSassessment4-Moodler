//
//  MainTab.swift
//  Moodler
//
//  Created by Owen Herianto on 17/10/2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            JournalListView()
                .tabItem {
                    Label("Journal", systemImage: "book.closed")
                }
            
            Text("Insights")
                .tabItem {
                    Label("Insights", systemImage: "chart.bar")
                }
            
            Text("Favourites")
                .tabItem {
                    Label("Favourites", systemImage: "heart.fill")
                }

        }
    }
}
