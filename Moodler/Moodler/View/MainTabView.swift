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
            Text("Home")
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            Text("Journal")
                .tabItem {
                    Label("Journal", systemImage: "book.closed")
                }
            
            Text("Insights")
                .tabItem {
                    Label("Insights", systemImage: "chart.bar")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }

        }
    }
}
