//
//  JournalDisplayView.swift
//  Moodler
//
//  Created by Chloe on 15/10/2025.
//

// PLACEHOLDER. NEED TO WORK ON UI

import SwiftUI
import CoreData

struct JournalDisplayView: View {
    
    @ObservedObject var journal: JournalEntry
    @EnvironmentObject var journalModel: JournalViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading, spacing: 8) {
                
                HStack {
                    // Displaying Journal title
                    Text((journal.title?.isEmpty == false ? journal.title! : "Untitled"))
                        .font(.title3)
                        .bold()
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Favourite button to allow users to favourite journals out of detailed view
                    Button(action: {
                        journalModel.toggleFavourite(for: journal)
                    }) {
                        Image(systemName: journalModel.isFavourite(journal: journal) ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundColor(.pink)
                    }
                    
                    // Delete button
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .font(.title3)
                            .foregroundColor(.red)
                    }
                    .padding(.top, 4)
                    // Making users confirm their decision in case they have accidentally clicked delete
                    .alert(isPresented: $showDeleteAlert) {
                        Alert(
                            title: Text("Delete Journal"),
                            message: Text("Are you sure you want to delete this journal? This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete")) {
                                journalModel.deleteJournal(journal)
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                
                HStack {
                    // Displaying journal date
                    if let date = journal.date {
                        Text(date, style: .date)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    Divider()
                    
//                    // Displaying journal location
//                    Label {
//                        Text((journal.placeName?.isEmpty == false ? journal.placeName! : "Location not set"))
//                            .font(.caption)
//                            .foregroundColor(.blue)
//                    } icon: {
//                        Image(systemName: "mappin.and.ellipse")
//                    }
                    
                }
               
                // Preview of the content (only displays 3 lines)
                Text(journal.content ?? "No content available.")
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(3)
            }
            .padding()
            .background(.white)
            .cornerRadius(16)
            .shadow(radius: 8)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}





