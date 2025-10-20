//
//  SettingsView.swift
//  Moodler
//
//  Created by Owen Herianto on 18/10/2025.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    @AppStorage("username") private var username = ""
    @AppStorage("bio") private var bio = ""
    @AppStorage("goal") private var goal = ""
    @AppStorage("age") private var age = ""
    @AppStorage("profileImageData") private var profileImageData: Data?
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("dailyReminderTime") private var dailyReminderTime = Date()

    @State private var showExportAlert = false

    var body: some View {
        NavigationView {
            Form {
                
                // PROFILE
                Section(header: Text("Profile")) {
                    NavigationLink {
                        ProfileView()
                    } label: {
                        HStack {
                            if let data = profileImageData, let img = UIImage(data: data) {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.gray)
                            }
                            VStack(alignment: .leading) {
                                Text(username.isEmpty ? "No username" : username)
                                    .font(.headline)
                                if !bio.isEmpty {
                                    Text(bio)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                        .contentShape(Rectangle())
                    }

                    // Goal
                    NavigationLink {
                        GoalView()
                    } label: {
                        HStack {
                            Text("Your Goal")
                            Spacer()
                            Text(goal.isEmpty ? "Not set" : goal)
                                .foregroundColor(goal.isEmpty ? .secondary : .primary)
                                .lineLimit(1)
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                    }
                }

                // NOTIFICATIONS
                Section(header: Text("Notifications")) {
                    Toggle("Daily Reminder", isOn: $dailyReminderEnabled)
                        .onChange(of: dailyReminderEnabled) { enabled in
                            if enabled {
                                requestNotificationPermission()
                                scheduleDailyNotification()
                            } else {
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            }
                        }

                    if dailyReminderEnabled {
                        DatePicker("Reminder Time",
                                   selection: $dailyReminderTime,
                                   displayedComponents: .hourAndMinute)
                        .onChange(of: dailyReminderTime) { _ in
                            scheduleDailyNotification()
                        }
                    }
                }

                // DATA
                Section(header: Text("Data")) {
                    Button("Export Journal Entries") {
                        showExportAlert = true
                    }
                    .alert("Havent done this", isPresented: $showExportAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Dont forget.")
                    }
                }

                // ACCOUNT
                Section(header: Text("Account")) {
                    Button(role: .destructive) {
                        isLoggedIn = false
                    } label: {
                        Text("Log Out")
                    }
                }

                // ABOUT
                Section(header: Text("About")) {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("-").foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, err in
            if let err = err { print("Notification permission error: \(err.localizedDescription)") }
        }
    }

    private func scheduleDailyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time to journal"
        content.body = "Take a moment to reflect and write down your thoughts today."
        content.sound = .default

        var comps = Calendar.current.dateComponents([.hour, .minute], from: dailyReminderTime)
        comps.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let req = UNNotificationRequest(identifier: "dailyJournalReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(req)
    }
}
