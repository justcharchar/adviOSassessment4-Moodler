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

    private let brandBackground = Color(red: 0.976, green: 0.953, blue: 0.929)
    private let cardColor = Color(red: 0.957, green: 0.910, blue: 0.875)

    var body: some View {
        NavigationView {
            ZStack {
                brandBackground.ignoresSafeArea()
                
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
                    .listRowBackground(cardColor)

                    Section(header: Text("Information")) {
                        // Username with @ prefix
                        HStack {
                            Text("@")
                                .foregroundColor(.gray)
                            TextField("Username", text: $username)
                                .textInputAutocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding(8)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)
                                .onChange(of: username) { newValue in
                                    if newValue.hasPrefix("@") {
                                        username = String(newValue.dropFirst())
                                    }
                                }
                        }

                        // Name Field Box
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Name")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("Your name", text: $goal)
                                .padding(8)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)
                        }

                        // Bio
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Bio")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("Add a short bio", text: $bio)
                                .padding(8)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)
                        }

                        // Goal
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Goal")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("Your goal", text: $goal)
                                .padding(8)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)
                        }

                        // Age
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Age")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("Your age", text: $age)
                                .keyboardType(.numberPad)
                                .padding(8)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)
                        }
                    }
                    .listRowBackground(cardColor)
                }
                .formStyle(.grouped)
                .scrollContentBackground(.hidden)
                .background(brandBackground)
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
}
