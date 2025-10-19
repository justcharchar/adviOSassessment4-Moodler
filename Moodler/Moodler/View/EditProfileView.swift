//
//  EditProfileView.swift
//  Moodler
//
//  Created by Ceri Tahimic on 18/10/2025.
//

import SwiftUI

struct EditProfileView: View {
    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                TextField("Name", text: .constant("Alex"))
                Button("Change Photo") { }
            }
            
            Section(header: Text("Journaling Goals")) {
                TextField("Daily Goal", text: .constant("Write 200 words"))
                TextField("Weekly Goal", text: .constant("5 entries per week"))
            }
        }
        .navigationTitle("Edit Profile")
    }
}

