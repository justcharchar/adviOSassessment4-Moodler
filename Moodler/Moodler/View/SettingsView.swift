//
//  SettingsView.swift
//  Moodler
//
//  Created by Ceri Tahimic on 18/10/2025.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section(header: Text("Profile")) {
                NavigationLink("Edit Profile", destination: EditProfileView())
                NavigationLink("Journaling Goals", destination: Text("Goals View"))
            }
            
            Section(header: Text("Notifications")) {
                NavigationLink("Manage Reminders", destination: Text("Notifications View"))
            }
            
            Section(header: Text("Integrations")) {
                NavigationLink("Siri Shortcuts", destination: Text("Siri Shortcuts View"))
            }
            
            Section(header: Text("Data")) {
                NavigationLink("Export Entries", destination: Text("Export View"))
                NavigationLink("Share Entries", destination: Text("Share View"))
            }
            
            Section(header: Text("Privacy & Security")) {
                NavigationLink("Face ID / Passcode", destination: Text("Privacy View"))
                NavigationLink("App Lock", destination: Text("App Lock View"))
            }
        }
        .navigationTitle("Settings")
    }
}
