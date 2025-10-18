//
//  EditProfileView.swift
//  Moodler
//
//  Created by Owen Herianto on 18/10/2025.
//

import SwiftUI

struct EditProfileView: View {
    @AppStorage("username") private var username = ""
    @AppStorage("bio") private var bio = ""
    @AppStorage("goal") private var goal = ""
    @AppStorage("age") private var age = ""
    @AppStorage("profileImageData") private var profileImageData: Data?

    @State private var showImagePicker = false
    @State private var tempImage: UIImage? = nil

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Picture")) {
                    Button(action: { showImagePicker = true }) {
                        if let imageData = profileImageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                    }
                }

                Section(header: Text("Information")) {
                    TextField("Username", text: $username)
                    TextField("Bio", text: $bio)
                    TextField("Goal", text: $goal)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(trailing: Button("Done") {
                if let tempImage = tempImage,
                   let data = tempImage.jpegData(compressionQuality: 0.8) {
                    profileImageData = data
                }
            })
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $tempImage)
            }
        }
    }
}
