//
//  LoginSignupView.swift
//  Moodler
//
//  Created by Owen Herianto on 17/10/2025.
//

import SwiftUI
import UIKit

struct LoginSignupView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var journalVM: JournalViewModel

    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("isSignedUp") private var isSignedUp = false

    @State private var isSignup = false
    @State private var inputName = ""
    @State private var inputUsername = ""
    @State private var inputBio = ""
    @State private var inputGoal = ""
    @State private var password = ""
    @State private var tempBirthdate = Date()
    @State private var tempImage: UIImage? = nil
    @State private var showImagePicker = false

    @State private var showAlert = false
    @State private var alertMessage = "Incorrect username or password"

    private let brandBackground = Color(red: 0.976, green: 0.953, blue: 0.929)
    private let cardColor = Color(red: 0.957, green: 0.910, blue: 0.875)

    var body: some View {
        NavigationView {
            ZStack {
                brandBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        
                        // MARK: - Logo (Login only)
                        if !isSignup {
                            VStack(spacing: 8) {
                                Image("MoodlerLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 300, height: 300)
                                    .padding(.top, 20)
                                    .padding(.bottom, -60)

                                // MARK: - Title
                                Text("Welcome Back to Moodler")
                                    .font(.title2.bold())
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.black.opacity(0.85))
                            }
                            .padding(.bottom, 20)
                        } else {
                            // MARK: - Title (Sign Up)
                            Text("Create Account")
                                .font(.title2.bold())
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black.opacity(0.85))
                                .padding(.top, 40)
                                .padding(.bottom, 10)
                        }

                        VStack(spacing: 16) {
                            if isSignup {
                                // MARK: - Avatar Picker
                                Button { showImagePicker = true } label: {
                                    if let img = tempImage {
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 1))
                                            .shadow(radius: 3)
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .foregroundColor(.gray.opacity(0.6))
                                    }
                                }
                                .padding(.top, 10)
                                .sheet(isPresented: $showImagePicker) {
                                    ImagePicker(image: $tempImage)
                                }

                                // MARK: - Sign Up Fields
                                Group {
                                    textField("Name", text: $inputName)
                                    textField("Username", text: $inputUsername)
                                    textField("Bio (optional)", text: $inputBio)
                                    textField("Goal", text: $inputGoal)
                                }

                                DatePicker("Birthdate", selection: $tempBirthdate, displayedComponents: .date)
                                    .padding()
                                    .background(cardColor)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                                    .padding(.horizontal)
                            } else {
                                // MARK: - Login Fields
                                textField("Username", text: $inputUsername)
                            }

                            SecureField("Password", text: $password)
                                .padding()
                                .background(cardColor)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                                .padding(.horizontal)
                        }

                        // MARK: - Button
                        Button(action: handleAction) {
                            Text(isSignup ? "Sign Up" : "Log In")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(colors: [.purple, .blue],
                                                   startPoint: .leading,
                                                   endPoint: .trailing)
                                )
                                .cornerRadius(14)
                                .shadow(color: .purple.opacity(0.2), radius: 5, x: 0, y: 3)
                                .padding(.horizontal)
                        }
                        .alert(alertMessage, isPresented: $showAlert) {
                            Button("OK", role: .cancel) { }
                        }

                        // MARK: - Switch
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isSignup.toggle()
                                clearForm()
                            }
                        } label: {
                            Text(isSignup ? "Already have an account? Log In" : "Don’t have an account? Sign Up")
                                .font(.subheadline)
                                .foregroundColor(.purple)
                                .padding(.top, 10)
                        }

                        Spacer(minLength: 30)
                    }
                }
            }
        }
    }

    // MARK: - Custom TextField Style
    private func textField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .padding()
            .background(cardColor)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
            .padding(.horizontal)
    }

    // MARK: - Handle Sign Up or Login
    private func handleAction() {
        if isSignup {
            guard !inputUsername.trimmingCharacters(in: .whitespaces).isEmpty,
                  !password.isEmpty else {
                alertMessage = "Please fill in all required fields."
                showAlert = true
                return
            }

            do {
                let imgData = tempImage?.jpegData(compressionQuality: 0.8)
                try profileVM.signUp(
                    name: inputName,
                    username: inputUsername,
                    password: password,
                    bio: inputBio,
                    goal: inputGoal,
                    birthDate: tempBirthdate,
                    imageData: imgData
                )
                isSignedUp = true
                isLoggedIn = true
                if profileVM.profile == nil {
                    profileVM.logout()
                    _ = profileVM.login(username: inputUsername, password: password)
                }
                if let user = profileVM.profile {
                    journalVM.setCurrentUser(user)
                    journalVM.fetchJournals()
                }

            } catch SignUpError.usernameTaken {
                alertMessage = "This username is already taken. Please choose another one."
                showAlert = true
            } catch {
                alertMessage = "Sign up failed. Please try again."
                showAlert = true
            }

        } else {
            if profileVM.login(username: inputUsername, password: password) {
                isLoggedIn = true
                if profileVM.profile == nil {
                    _ = profileVM.login(username: inputUsername, password: password)
                }
                if let user = profileVM.profile {
                    journalVM.setCurrentUser(user)
                    journalVM.fetchJournals()
                }
            } else {
                alertMessage = "Incorrect username or password"
                showAlert = true
            }
        }
    }

    // MARK: - Clear Form
    private func clearForm() {
        inputName = ""
        inputUsername = ""
        inputBio = ""
        inputGoal = ""
        password = ""
        tempBirthdate = Date()
        tempImage = nil
    }
}
