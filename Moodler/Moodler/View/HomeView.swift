//
//  HomeView.swift
//  Moodler
//
//  Created by Owen Herianto on 17/10/2025.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to Moodler")
                    .font(.largeTitle)
                    .bold()
                Text("This is your home screen ✨")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Home")
        }
    }
}
