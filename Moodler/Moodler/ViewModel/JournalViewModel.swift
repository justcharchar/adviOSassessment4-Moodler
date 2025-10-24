//
//  JournalViewModel.swift
//  Moodler
//
//  Created by Chloe on 16/10/2025.
//

import Foundation
import CoreData
import SwiftUI
import CoreML

@MainActor
class JournalViewModel: ObservableObject {
    private let context: NSManagedObjectContext

    @Published var entries: [JournalEntry] = []
    @Published var draftJournal: JournalEntry?
    @Published var currentUser: UserProfile?

    private var moodModel: MoodClassifier?

    init(context: NSManagedObjectContext) {
        self.context = context
        self.moodModel = try? MoodClassifier(configuration: MLModelConfiguration())
    }
    
    // MARK: - Set Current User
    func setCurrentUser(_ user: UserProfile) {
        if user.objectID.isTemporaryID {
            try? context.obtainPermanentIDs(for: [user])
            try? context.save()
        }
        self.currentUser = user
        fetchJournals()
    }
    
    // MARK: - Save Context
    func saveContext() {
        guard context.hasChanges else { return }
        try? context.save()
        fetchJournals()
    }
    
    // MARK: - Fetch Journals
    func fetchJournals() {
        guard let currentUser else {
            entries = []
            return
        }

        let request: NSFetchRequest<JournalEntry> = JournalEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \JournalEntry.date, ascending: false)]

        request.predicate = NSPredicate(format: "owner == %@", currentUser)

        do {
            entries = try context.fetch(request)
            print("📒 fetched \(entries.count) journals for user \(currentUser.username ?? "?")")
        } catch {
            print("❌ Fetch error:", error.localizedDescription)
            entries = []
        }
    }
    
    // MARK: - Add Journal
    @discardableResult
    func addJournal() -> JournalEntry? {
        guard let currentUser else { return nil }
        
        if currentUser.objectID.isTemporaryID {
            try? context.obtainPermanentIDs(for: [currentUser])
            try? context.save()
        }

        let newJournal = JournalEntry(context: context)
        newJournal.id = UUID()
        newJournal.title = ""
        newJournal.content = ""
        newJournal.date = Date()
        newJournal.isFavourite = false
        newJournal.owner = currentUser  

        try? context.save()
        fetchJournals()
        return newJournal
    }

    // MARK: - Save Entry
    func saveEntry(_ journal: JournalEntry) {
        if journal.id == nil { journal.id = UUID() }
        if journal.date == nil { journal.date = Date() }
        if journal.owner == nil { journal.owner = currentUser }
        
        try? context.save()
        fetchJournals()
    }
    
    // MARK: - Save Draft
    func saveDraft(_ journal: JournalEntry) {
        if journal.id == nil { journal.id = UUID() }
        if journal.date == nil { journal.date = Date() }
        if journal.owner == nil { journal.owner = currentUser }
        
        try? context.save()
        fetchJournals()
    }
    
    // MARK: - Delete Journal
    func deleteJournal(_ journal: JournalEntry) {
        context.delete(journal)
        saveContext()
    }
    
    // MARK: - Favourites
    func isFavourite(journal: JournalEntry) -> Bool {
        return journal.isFavourite
    }
    
    func toggleFavourite(for journal: JournalEntry) {
        journal.isFavourite.toggle()
        saveContext()
        objectWillChange.send()
    }
    
    // MARK: - Pexels Image Search
    func searchPexelsImages(query: String, completion: @escaping ([Photo]) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion([])
            return
        }
        
        let apiKey = "ah8DHRORUnGRKdYXgSb7AxvHHrnxIN9asXZvm2RsgxjOGUjSvr0PFzf0"
        let urlString = "https://api.pexels.com/v1/search?query=\(encodedQuery)&per_page=20"
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                completion([])
                return
            }
            let decoded = try? JSONDecoder().decode(PexelsResponse.self, from: data)
            DispatchQueue.main.async {
                completion(decoded?.photos ?? [])
            }
        }.resume()
    }
    
    // MARK: - ML Mood Prediction
    func predictMood(for journal: JournalEntry) {
        guard let text = journal.content, !text.isEmpty else { return }
        
        if let model = try? MoodClassifier(configuration: MLModelConfiguration()) {
            if let prediction = try? model.prediction(text: text) {
                journal.emotion = prediction.label
                saveContext()
            }
        }
    }
}
