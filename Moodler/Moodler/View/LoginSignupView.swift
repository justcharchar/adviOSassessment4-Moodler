//
//  EntryView.swift
//  Moodler
//
//  Created by Owen Herianto on 17/10/2025.
//

import SwiftUI

struct LoginSignupView: View {
    @AppStorage("isSignedUp") private var isSignedUp = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    // Profile
    @AppStorage("username") private var username = ""
    @AppStorage("bio") private var bio = ""
    @AppStorage("goal") private var goal = ""
    @AppStorage("age") private var age = ""
    @AppStorage("profileImageData") private var profileImageData: Data?
    
    @State private var isSignup = false
    @State private var inputUsername = ""
    @State private var password = ""
    @State private var tempImage: UIImage? = nil
    @State private var showImagePicker = false
    
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
                    
                    // MARK: - Title
                    Text(isSignup ? "Create Account" : "Welcome Back")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, isSignup ? 0 : 80)
                    
                    // MARK: - Signup Fields
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
                        
                        TextField("Age (optional)", text: $age)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .padding(.horizontal)
                    } else {
                        TextField("Username", text: $inputUsername)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
                    
                    // MARK: - Password Field
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    // MARK: - Button
                    Button(action: {
                        if isSignup {
                            if !username.isEmpty && !password.isEmpty {
                                isSignedUp = true
                                isLoggedIn = true
                            }
                        } else {
                            if !inputUsername.isEmpty && !password.isEmpty {
                                isLoggedIn = true
                            }
                        }
                    }) {
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
    
    // MARK: - Reset Fields When Switching Modes
    func clearForm() {
        password = ""
        if isSignup {
            username = ""
            bio = ""
            goal = ""
            age = ""
        } else {
            inputUsername = ""
        }
    }
}
