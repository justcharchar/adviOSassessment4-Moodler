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
    
    private let brandBackground = Color(red: 0.976, green: 0.953, blue: 0.929)
    private let cardColor = Color(red: 0.957, green: 0.910, blue: 0.875)
    
    var body: some View {
        HStack(spacing: 16) {
                    
            // MARK: - Image Display
            if let data = journal.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .cornerRadius(15)
                    .clipped()
                
            } else if let urlString = journal.imageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(12)
                        .clipped()
                } placeholder: {
                    ZStack {
                        Rectangle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 100, height: 100)
                            .cornerRadius(12)
                        ProgressView()
                    }
                }
            } else {
                // Default placeholder if no image exists
                ZStack {
                    Rectangle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .cornerRadius(12)
                    
                    Image(systemName: "photo")
                        .foregroundColor(.white)
                }
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
                        .foregroundColor(.secondary)
                }
                
                Text(journal.content ?? "No content available.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .padding(.top, 2)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                HStack {
                    // Favourite button
                    Button(action: {
                        withAnimation {
                            journalModel.toggleFavourite(for: journal)
                        }
                    }) {
                        Image(systemName: journalModel.isFavourite(journal: journal) ? "heart.fill" : "heart")
                            .foregroundColor(.pink)
                    }
                    
                    // Delete button
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
                    // Share button
                    if let title = journal.title, let content = journal.content {
                        let shareText = """
                        📝 \(title)
                        \(journal.date?.formatted(date: .abbreviated, time: .omitted) ?? "")
                        
                        \(content)
                        """

                        ShareLink(item: shareText, subject: Text("My Moodler Journal")) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                        }
                    }
                    
                }
                .font(.subheadline)
            }
            
            Spacer()
        }
        .padding()
        .background(cardColor)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
}
