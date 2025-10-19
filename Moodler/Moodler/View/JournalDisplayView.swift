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
        HStack(spacing: 16) {
                    
            // MARK: - Image Display
            if let urlString = journal.imageURL,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(12)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .cornerRadius(12)
                }
            } else {
                // Default placeholder if no image exists
                Rectangle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
                    .cornerRadius(12)
            }
            
            // MARK: - Journal Info
            VStack(alignment: .leading, spacing: 6) {
                
                Text(journal.title?.isEmpty == false ? journal.title! : "Untitled")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if let date = journal.date {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Text(journal.content ?? "No content available.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .padding(.top, 2)
                
                Spacer()
                
                HStack {
                    Button(action: {
                        withAnimation {
                            journalModel.toggleFavourite(for: journal)
                        }
                    }) {
                        Image(systemName: journalModel.isFavourite(journal: journal) ? "heart.fill" : "heart")
                            .foregroundColor(.pink)
                    }

                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
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
                .font(.subheadline)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.2), radius: 6)
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
    
}






