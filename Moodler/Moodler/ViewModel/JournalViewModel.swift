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

class JournalViewModel: ObservableObject {
    let context = PersistenceController.shared.container.viewContext
    
    @Published var entries: [JournalEntry] = [] // Entries from core data
    @Published var draftJournal: JournalEntry? // Draft of journal before saving
    
    private var moodModel: MoodClassifier?
    
    init() {
        fetchJournals()
        
        do {
            moodModel = try MoodClassifier(configuration: MLModelConfiguration())
        } catch {
            print("Failed to load model: \(error)")
        }
    }
    
    // MARK: Saving and Fetching Context
    
    // Saving Data
    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
           
        } catch {
            print("Error saving: \(error)")
        }
    }
    
    // Fetching Journals
    func fetchJournals() {
        let request: NSFetchRequest<JournalEntry> = JournalEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \JournalEntry.date, ascending: false)]
                
        do {
            entries = try context.fetch(request)
        } catch {
            print("Fetch Failed: \(error)")
            entries = []
        }
    }
    
    // MARK: Adding, Saving and Deleting Journals
    
    // Creating a journal draft before saving
    func addJournal() {
        draftJournal = JournalEntry(context: context)
        draftJournal?.id = UUID()
        draftJournal?.title = ""
        draftJournal?.content = ""
        draftJournal?.date = Date()
        draftJournal?.isFavourite = false
    }
    
    // Saving journal draft
    func saveDraft(for journal: JournalEntry? = nil) {
        guard let journal = draftJournal else { return }
        
        if !entries.contains(journal) {
            entries.insert(journal, at: 0)

        }
        do {
            try context.save()
        } catch {
            print("Error saving draft: \(error)")
        }
        draftJournal = nil
    }
    
    // Deleting a journal entry
    func deleteJournal(_ journal: JournalEntry) {
        context.delete(journal)
        saveContext()
        
        if let index = entries.firstIndex(of: journal) {
            entries.remove(at: index)
        }
    }
    
    // MARK: Setting Favourite Journals
    
    // See if the journal is favourited
    func isFavourite(journal: JournalEntry) -> Bool {
        return journal.isFavourite
    }
    
    // Toggling favourite journals
    func toggleFavourite(for journal: JournalEntry) {
        journal.isFavourite.toggle() // toggle isFavourite
        saveContext()
        objectWillChange.send()
         
    }
    
    // MARK: Pexels API - Search Function
    
    // Function to search for images
    func searchPexelsImages(query: String, completion: @escaping ([Photo]) -> Void) {
            guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                completion([])
                return
            }

            let apiKey = "ah8DHRORUnGRKdYXgSb7AxvHHrnxIN9asXZvm2RsgxjOGUjSvr0PFzf0"
            let urlString = "https://api.pexels.com/v1/search?query=\(encodedQuery)&per_page=20"
            guard let url = URL(string: urlString) else { completion([]); return }

            var request = URLRequest(url: url)
            request.setValue(apiKey, forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else { completion([]); return }
                do {
                    let decoded = try JSONDecoder().decode(PexelsResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(decoded.photos)
                    }
                } catch {
                    print("JSON parse error: \(error)")
                    DispatchQueue.main.async { completion([]) }
                }
            }.resume()
        }
    
    // MARK: MACHINE LEARNING MODEL
    
    func predictMood(for journal: JournalEntry) {
        guard let text = journal.content, !text.isEmpty else { return }
        
        do {
            let model = try MoodClassifier(configuration: MLModelConfiguration())
            let prediction = try model.prediction(text: text)
            
            journal.emotion = prediction.label
            saveContext()
            
        } catch {
            print("Error predicting mood: \(error)")
        }
    }

}
