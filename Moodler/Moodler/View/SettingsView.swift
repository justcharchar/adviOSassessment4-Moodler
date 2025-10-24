//
//  SettingsView.swift
//  Moodler
//
//  Created by Owen Herianto on 18/10/2025.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("dailyReminderTime") private var dailyReminderTime = Date()

    @State private var showExportAlert = false
    
    private let brandBackground = Color(red: 0.976, green: 0.953, blue: 0.929)
    private let cardColor = Color(red: 0.957, green: 0.910, blue: 0.875)

    var body: some View {
        NavigationView {
            ZStack {
                brandBackground.ignoresSafeArea()

                VStack(alignment: .leading) {
                    Form {
                        // MARK: - Profile
                        Section(header: Text("Profile")) {
                            NavigationLink {
                                ProfileView()
                            } label: {
                                HStack(spacing: 16) {
                                    if let data = profileVM.profile?.profileImage,
                                       let img = UIImage(data: data) {
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                            .shadow(radius: 3)
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)
                                            .foregroundColor(.gray.opacity(0.6))
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(profileVM.profile?.name ?? "No name")
                                            .font(.headline)
                                            .foregroundColor(.primary)

                                        Text("@\(profileVM.profile?.username ?? "unknown")")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)

                                        if let bio = profileVM.profile?.bio, !bio.isEmpty {
                                            Text(bio)
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                                .lineLimit(2)
                                        } else {
                                            Text("(no bio yet)")
                                                .font(.footnote)
                                                .foregroundColor(.gray.opacity(0.6))
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(cardColor)

                            NavigationLink {
                                GoalView()
                            } label: {
                                HStack {
                                    Text("Your Goal")
                                    Spacer()
                                    Text(profileVM.profile?.goal?.isEmpty == false
                                         ? profileVM.profile!.goal!
                                         : "Not set")
                                        .foregroundColor(profileVM.profile?.goal?.isEmpty == false ? .primary : .secondary)
                                        .lineLimit(1)
                                }
                            }
                            .listRowBackground(cardColor)
                        }

                        // MARK: - Notifications
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
                                .listRowBackground(cardColor)

                            if dailyReminderEnabled {
                                DatePicker("Reminder Time",
                                           selection: $dailyReminderTime,
                                           displayedComponents: .hourAndMinute)
                                .onChange(of: dailyReminderTime) { _ in
                                    scheduleDailyNotification()
                                }
                                .listRowBackground(cardColor)
                            }
                        }

                        // MARK: - Account
                        Section(header: Text("Account")) {
                            Button(role: .destructive) {
                                isLoggedIn = false
                            } label: {
                                Text("Log Out")
                            }
                            .listRowBackground(cardColor)
                        }

                        // MARK: - About
                        Section(header: Text("About")) {
                            HStack {
                                Text("App Version")
                                Spacer()
                                Text("1.0.0").foregroundColor(.secondary)
                            }
                            .listRowBackground(cardColor)

                            HStack {
                                Text("Developer")
                                Spacer()
                                Text("-").foregroundColor(.secondary)
                            }
                            .listRowBackground(cardColor)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(brandBackground)
                    .navigationTitle("Settings")
                }
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
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
