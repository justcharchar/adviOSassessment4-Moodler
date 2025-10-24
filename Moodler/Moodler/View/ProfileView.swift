//
//  ProfileView.swift
//  Moodler
//
//  Created by Owen Herianto on 18/10/2025.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var profileVM: ProfileViewModel

    @State private var isEditing = false
    @State private var tempName = ""
    @State private var tempUsername = ""
    @State private var tempBio = ""
    @State private var tempBirthDate = Date()
    @State private var showImagePicker = false
    @State private var tempImage: UIImage? = nil

    private let titleHeight: CGFloat = 44
    private let bioHeight: CGFloat = 120
    private let trailingValueWidth: CGFloat = 200
    
    private let brandBackground = Color(red: 0.976, green: 0.953, blue: 0.929)
    private let cardColor = Color(red: 0.957, green: 0.910, blue: 0.875)

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                profileImageSection
                nameAndUsernameSection
                bioSection
                dateInfoSection
            }
            .padding(.bottom, 50)
            .animation(.easeInOut(duration: 0.15), value: isEditing)
        }
        .background(brandBackground.ignoresSafeArea())
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
        .onAppear { seedTempValues() }
    }

    private var profileImageSection: some View {
        ZStack {
            Circle()
                .fill(cardColor)
                .frame(width: 160, height: 160)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)

            Button { if isEditing { showImagePicker = true } } label: {
                if let data = profileVM.profile?.profileImage,
                   let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.accentColor, lineWidth: 4))
                        .shadow(radius: 6)
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
        }
    }

    private var nameAndUsernameSection: some View {
        VStack(spacing: 12) {
            // MARK: Name Field
            ZStack {
                if isEditing {
                    TextField("Your Name", text: $tempName)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                        .multilineTextAlignment(.center)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                        )
                        .padding(.horizontal, 60)
                } else {
                    Text(profileVM.profile?.name ?? "No name set")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                }
            }

            // MARK: Username
            Text("@\(profileVM.profile?.username ?? "No username set")")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }



    private var bioSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bio")
                .font(.headline)
                .padding(.horizontal)

            ZStack(alignment: .topLeading) {
                Text(profileVM.profile?.bio ?? "(your bio here)")
                    .foregroundColor((profileVM.profile?.bio?.isEmpty ?? true) ? .secondary : .primary)
                    .opacity(isEditing ? 0 : 1)
                    .padding()

                TextEditor(text: $tempBio)
                    .opacity(isEditing ? 1 : 0)
                    .padding(8)
                    .background(Color.clear)
            }
            .frame(maxWidth: .infinity, minHeight: bioHeight, maxHeight: bioHeight)
            .background(cardColor)
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }

    private var dateInfoSection: some View {
        VStack(spacing: 16) {
            birthDateRow
            ageRow
            joinedDateRow
        }
        .padding()
        .background(cardColor)
        .cornerRadius(16)
        .padding(.horizontal)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private var birthDateRow: some View {
        HStack {
            Text("Birthdate:")
                .font(.headline)
            Spacer()

            ZStack(alignment: .trailing) {
                DatePicker("", selection: $tempBirthDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .opacity(isEditing ? 1 : 0)

                Text(formattedDate(profileVM.profile?.birthDate))
                    .foregroundColor(profileVM.profile?.birthDate == nil ? .secondary : .primary)
                    .opacity(isEditing ? 0 : 1)
            }
            .frame(width: trailingValueWidth, alignment: .trailing)
        }
        .padding(.horizontal)
    }

    private var ageRow: some View {
        HStack {
            Text("Age:")
                .font(.headline)
            Spacer()
            Text(calculateAge(from: profileVM.profile?.birthDate))
                .foregroundColor(.primary)
                .frame(width: trailingValueWidth, alignment: .trailing)
        }
        .padding(.horizontal)
    }

    private var joinedDateRow: some View {
        HStack {
            Text("Joined:")
                .font(.headline)
            Spacer()
            Text(formattedDate(profileVM.profile?.joinedDate))
                .foregroundColor(profileVM.profile?.joinedDate == nil ? .secondary : .primary)
                .frame(width: trailingValueWidth, alignment: .trailing)
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }

    private func toggleEditMode() {
        if isEditing {
            let imgData = tempImage?.jpegData(compressionQuality: 0.8)
            try? profileVM.updateProfile(
                name: tempName,
                username: tempUsername,
                bio: tempBio,
                goal: nil,
                birthDate: tempBirthDate,
                imageData: imgData
            )
        }
        withAnimation { isEditing.toggle() }
    }

    private func seedTempValues() {
        tempName = profileVM.profile?.name ?? ""
        tempUsername = profileVM.profile?.username ?? ""
        tempBio = profileVM.profile?.bio ?? ""
        tempBirthDate = profileVM.profile?.birthDate ?? Date()
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date else { return "Not set" }
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }

    private func calculateAge(from birthDate: Date?) -> String {
        guard let birthDate else { return "Not set" }
        let calendar = Calendar.current
        let now = Date()
        let comps = calendar.dateComponents([.year], from: birthDate, to: now)
        return "\(comps.year ?? 0)"
    }
}
