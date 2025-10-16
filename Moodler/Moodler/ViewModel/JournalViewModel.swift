//
//  JournalViewModel.swift
//  Moodler
//
//  Created by Chloe on 16/10/2025.
//

import Foundation
import CoreData
import SwiftUI

class JournalViewModel: ObservableObject {
    let context = PersistenceController.shared.container.viewContext
    
    @Published var entries: [JournalEntry] = [] // Entries from core data
    @Published var draftJournal: JournalEntry? // Draft of journal before saving
    
    init() {
        fetchJournals()
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
    
    // MARK: Adding and Saving Journals
    
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
    func saveDraft() {
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
    
    
    
}
