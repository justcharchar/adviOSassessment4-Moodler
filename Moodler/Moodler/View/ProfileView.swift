//
//  ProfileView.swift
//  Moodler
//
//  Created by Owen Herianto on 18/10/2025.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("username") private var username = ""
    @AppStorage("bio") private var bio = ""
    @AppStorage("birthdate") private var birthdate = Date.distantPast
    @AppStorage("age") private var age = ""
    @AppStorage("joinedDate") private var joinedDate = ""
    @AppStorage("profileImageData") private var profileImageData: Data?

    @State private var isEditing = false
    @State private var tempUsername = ""
    @State private var tempBio = ""
    @State private var tempBirthdate = Date()
    @State private var showImagePicker = false
    @State private var tempImage: UIImage? = nil

    private let titleHeight: CGFloat = 44
    private let bioHeight: CGFloat = 120
    private let trailingValueWidth: CGFloat = 200

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {

                ZStack {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 160, height: 160)
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)

                    Button(action: { if isEditing { showImagePicker = true } }) {
                        if let data = profileImageData, !data.isEmpty,
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.accentColor, lineWidth: 4))
                                .shadow(radius: 6)
                                .colorMultiply(.white)
                                .opacity(1)
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .foregroundColor(.gray.opacity(0.5))
                        }
                    }
                    .buttonStyle(.borderless)
                    .disabled(!isEditing)
                }
                .padding(.top, 20)
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(image: $tempImage)
                        .onDisappear {
                            if let img = tempImage,
                               let data = img.jpegData(compressionQuality: 0.8) {
                                profileImageData = data
                            }
                        }
                }

                ZStack {
                    Text(username.isEmpty ? "No username set" : username)
                        .opacity(isEditing ? 0 : 1)

                    TextField("Username", text: $tempUsername)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                        .multilineTextAlignment(.center)
                        .opacity(isEditing ? 1 : 0)
                }
                .font(.system(size: 32, weight: .bold))
                .frame(height: titleHeight)
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Bio")
                        .font(.headline)
                        .padding(.horizontal)

                    ZStack(alignment: .topLeading) {
                        Text(bio.isEmpty ? "(your bio here)" : bio)
                            .foregroundColor(bio.isEmpty ? .secondary : .primary)
                            .opacity(isEditing ? 0 : 1)
                            .padding()

                        TextEditor(text: $tempBio)
                            .opacity(isEditing ? 1 : 0)
                            .padding(8)
                            .background(Color.clear)
                    }
                    .frame(maxWidth: .infinity, minHeight: bioHeight, maxHeight: bioHeight)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                VStack(spacing: 16) {
                    birthdateRow()
                    autoAgeRow()

                    HStack {
                        Text("Joined:")
                            .font(.headline)
                        Spacer()
                        Text(joinedDate.isEmpty ? "Not recorded" : joinedDate)
                            .foregroundColor(joinedDate.isEmpty ? .secondary : .primary)
                            .frame(width: trailingValueWidth, alignment: .trailing)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            }
            .padding(.bottom, 50)
            .animation(.easeInOut(duration: 0.15), value: isEditing)
        }
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: toggleEditMode) {
                    Text(isEditing ? "Save" : "Edit")
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            tempUsername = username
            tempBio = bio
            tempBirthdate = birthdate == Date.distantPast ? Date() : birthdate
        }
    }

    private func toggleEditMode() {
        if isEditing {
            if let img = tempImage,
               let data = img.jpegData(compressionQuality: 0.8) {
                profileImageData = data
            }
            username = tempUsername
            bio = tempBio
            birthdate = tempBirthdate
            age = calculateAge(from: birthdate)
        }
        withAnimation { isEditing.toggle() }
    }

    @ViewBuilder
    private func birthdateRow() -> some View {
        HStack {
            Text("Birthdate:")
                .font(.headline)
            Spacer()

            ZStack(alignment: .trailing) {
                DatePicker("", selection: $tempBirthdate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                    .labelsHidden()
                    .opacity(isEditing ? 1 : 0)

                Text(birthdate == Date.distantPast ? "Not set" : formattedDate(birthdate))
                    .foregroundColor(birthdate == Date.distantPast ? .secondary : .primary)
                    .opacity(isEditing ? 0 : 1)
            }
            .frame(width: trailingValueWidth, alignment: .trailing)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func autoAgeRow() -> some View {
        HStack {
            Text("Age:")
                .font(.headline)
            Spacer()
            Text(calculateAge(from: birthdate))
                .foregroundColor(.primary)
                .frame(width: trailingValueWidth, alignment: .trailing)
        }
        .padding(.horizontal)
    }

    private func calculateAge(from date: Date) -> String {
        guard date != Date.distantPast else { return "Not set" }
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year], from: date, to: now)
        return "\(components.year ?? 0)"
    }

    private func formattedDate(_ date: Date) -> String {
        guard date != Date.distantPast else { return "Not set" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
