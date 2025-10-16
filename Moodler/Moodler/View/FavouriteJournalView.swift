//
//  FavouriteJournalView.swift
//  Moodler
//
//  Created by Chloe on 17/10/2025.
//

import SwiftUI
import CoreData

struct FavouriteJournalView: View {
    @EnvironmentObject var journalModel: JournalViewModel
    
    var favouriteJournals: [JournalEntry] {
        journalModel.entries.filter { $0.isFavourite }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    
                    // If there are no favourited journals they will be informed
                    if favouriteJournals.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "heart.slash")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("You currently have no favourited journals")
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 50)
                    } else {
                        
                        // Displaying the favourited journals
                        ForEach(favouriteJournals, id: \.objectID) { journal in
                            JournalDisplayView(journal: journal)
                                .environmentObject(journalModel)
                        }
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Favourite Journals")
        }
    }
}










