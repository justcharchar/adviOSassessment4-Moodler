//
//  ProfileViewModel.swift
//  Moodler
//
//  Created by Owen Herianto on 21/10/2025.
//

import Foundation
import CoreData
import SwiftUI

enum SignUpError: LocalizedError {
    case usernameTaken
    var errorDescription: String? {
        switch self {
        case .usernameTaken:
            return "This username is already taken. Please choose another one."
        }
    }
}

@MainActor
final class ProfileViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    @Published var profile: UserProfile?

    @AppStorage("currentUserID") private var currentUserIDString: String?

    private var currentUserID: UUID? {
        get {
            currentUserIDString.flatMap { UUID(uuidString: $0) }
        }
        set {
            currentUserIDString = newValue?.uuidString
        }
    }

    init(context: NSManagedObjectContext) {
        self.context = context
        loadExistingProfile()
    }


    // MARK: - Load (current session)
    private func loadExistingProfile() {
        if let id = currentUserID {
            let req: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
            req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            profile = try? context.fetch(req).first
        } else {
            let req: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
            req.sortDescriptors = [NSSortDescriptor(keyPath: \UserProfile.joinedDate, ascending: false)]
            req.fetchLimit = 1
            profile = try? context.fetch(req).first
        }
    }

    // MARK: - Sign Up
    func signUp(
        name: String,
        username: String,
        password: String,
        bio: String?,
        goal: String?,
        birthDate: Date?,
        imageData: Data?
    ) throws {

        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        request.predicate = NSPredicate(format: "username ==[c] %@", username)
        if let existing = try? context.fetch(request), !existing.isEmpty {
            throw SignUpError.usernameTaken
        }

        let user = UserProfile(context: context)
        user.id = UUID()
        user.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        user.username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        user.password = password
        user.bio = (bio?.isEmpty == true) ? nil : bio
        user.goal = (goal?.isEmpty == true) ? nil : goal
        user.birthDate = birthDate
        user.joinedDate = Date()
        user.profileImage = imageData

        try context.save()
        try? context.obtainPermanentIDs(for: [user])
        self.profile = user
        self.currentUserID = user.id
    }

    // MARK: - Login
    func login(username: String, password: String) -> Bool {
        let req: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        req.predicate = NSPredicate(format: "username ==[c] %@", username)
        req.fetchLimit = 1
        guard let user = try? context.fetch(req).first, user.password == password else {
            return false
        }

        try? context.obtainPermanentIDs(for: [user])
        self.profile = user
        self.currentUserID = user.id
        return true
    }

    // MARK: - Update
    func updateProfile(
        name: String,
        username: String,
        bio: String?,
        goal: String?,
        birthDate: Date?,
        imageData: Data?
    ) throws {
        guard let user = profile else { return }

        if let newUsername = Optional(username.trimmingCharacters(in: .whitespacesAndNewlines)),
           newUsername.caseInsensitiveCompare(user.username ?? "") != .orderedSame {
            let check: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
            check.predicate = NSPredicate(format: "username ==[c] %@", newUsername)
            if let _ = try? context.fetch(check).first {
                throw SignUpError.usernameTaken
            }
            user.username = newUsername
        }

        user.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        user.bio = (bio?.isEmpty == true) ? nil : bio
        user.goal = (goal?.isEmpty == true) ? nil : goal
        user.birthDate = birthDate
        if let data = imageData { user.profileImage = data }

        try context.save()
        self.currentUserID = user.id
        objectWillChange.send()
    }

    func logout() {
        self.profile = nil
        self.currentUserID = nil
    }
}
