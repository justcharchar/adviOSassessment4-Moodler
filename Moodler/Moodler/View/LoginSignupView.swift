//
//  LoginSignupView.swift
//  Moodler
//
//  Created by Owen Herianto on 17/10/2025.
//

import SwiftUI
import UIKit // NEW: for haptics

struct LoginSignupView: View {
    @AppStorage("isSignedUp") private var isSignedUp = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    @AppStorage("username") private var username = ""
    @AppStorage("bio") private var bio = ""
    @AppStorage("goal") private var goal = ""
    @AppStorage("birthdate") private var birthdate = Date.distantPast
    @AppStorage("joinedDate") private var joinedDate = ""
    @AppStorage("profileImageData") private var profileImageData: Data?
    @AppStorage("password") private var savedPassword = ""
    
    @State private var isSignup = false
    @State private var inputUsername = ""
    @State private var password = ""
    @State private var tempImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var tempBirthdate = Date()
    @State private var showLoginError = false

    @State private var birthdateSelected = false
    @State private var showBirthdateError = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - Profile Picture
                    if isSignup {
                        Button(action: { showImagePicker = true }) {
                            if let imageData = profileImageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.accentColor, lineWidth: 3))
                                    .padding(.top, 30)
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.gray)
                                    .padding(.top, 30)
                            }
                        }
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker(image: $tempImage)
                                .onDisappear {
                                    if let tempImage = tempImage,
                                       let data = tempImage.jpegData(compressionQuality: 0.8) {
                                        profileImageData = data
                                    }
                                }
                        }
                    }

                    Text(isSignup ? "Create Account" : "Welcome Back")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, isSignup ? 0 : 80)
                    
                    // MARK: - Signup
                    if isSignup {
                        TextField("Username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        TextField("Bio (optional)", text: $bio)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        TextField("Goal (optional)", text: $goal)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 6) {
                            DatePicker("Birthdate", selection: $tempBirthdate, displayedComponents: .date)
                                .datePickerStyle(.wheel)
                                .padding(.horizontal)
                                .onChange(of: tempBirthdate) { _ in
                                    birthdateSelected = true
                                    showBirthdateError = false
                                }

                            if showBirthdateError || (!birthdateSelected) {
                                Text("Birthdate is required")
                                    .foregroundColor(.red)
                                    .font(.footnote)
                                    .padding(.horizontal)
                            }
                        }
                    } else {
                        TextField("Username", text: $inputUsername)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    // MARK: - Pop up incorrect
                    Button(action: handleAction) {
                        Text(isSignup ? "Sign Up" : "Log In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .padding(.top, 10)
                    .alert("Incorrect username or password", isPresented: $showLoginError) {
                        Button("OK", role: .cancel) { }
                    }
                    
                    // MARK: - Switch Button
                    Button(action: {
                        withAnimation {
                            isSignup.toggle()
                            clearForm()
                        }
                    }) {
                        Text(isSignup ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .padding(.bottom, 30)
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Handle Login / Signup
    private func handleAction() {
        if isSignup {
            if !birthdateSelected {
                let h = UINotificationFeedbackGenerator()
                h.notificationOccurred(.error)
                showBirthdateError = true
                return
            }
            if !username.isEmpty && !password.isEmpty {
                savedPassword = password
                birthdate = tempBirthdate
                joinedDate = formattedDate(Date())
                isSignedUp = true
                isLoggedIn = true
                let h = UINotificationFeedbackGenerator()
                h.notificationOccurred(.success)
            }
        } else {
            if inputUsername == username && password == savedPassword {
                isLoggedIn = true
                let h = UINotificationFeedbackGenerator()
                h.notificationOccurred(.success)
            } else {
                showLoginError = true
                let h = UINotificationFeedbackGenerator()
                h.notificationOccurred(.error)
            }
        }
    }

    private func clearForm() {
        password = ""
        showBirthdateError = false 
        birthdateSelected = false
        if isSignup {
            username = ""
            bio = ""
            goal = ""
            tempBirthdate = Date()
        } else {
            inputUsername = ""
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
