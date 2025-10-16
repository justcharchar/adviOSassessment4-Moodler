//
//  JournalDetailView.swift
//  Moodler
//
//  Created by Chloe on 15/10/2025.
//

import SwiftUI
import CoreData

struct JournalDetailView: View {
    @EnvironmentObject var journalModel: JournalViewModel
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var journal: JournalEntry
    
    @State private var showImagePicker: Bool = false
    @State private var coverImageURL: String?
    @State var showDatePicker: Bool = false
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                ZStack(alignment: .bottomLeading) {
                    if let urlString = coverImageURL, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                //.scaledToFill()
                                //.clipped()
                                .frame(height: 150)
                            
                        } placeholder: {
                            Color.gray.opacity(0.2)
                                .frame(height: 150)
                        }
                        
                    } else {
                        Color.blue.opacity(0.2)
                            .frame(height: 150)
                            .border(Color.gray.opacity(0.3), width: 0.2)
                    }
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            TextField("Title", text: Binding (
                                get: { journal.title ?? ""},
                                set: { journal.title = $0 }))
                            .font(.title)
                            .bold()
                            
                            Spacer()
                            
                            // Favourite Button -> this will go to FavouriteJournalView
                            Button {
                                withAnimation(.bouncy) {
                                    journalModel.toggleFavourite(for: journal)
                                }
                            } label: {
                                Image(systemName: journalModel.isFavourite(journal: journal) ? "heart.fill" : "heart")
                                    .font(.title)
                                    .foregroundColor(.pink)
                            }
                        }
                        
                
                    }
                    .padding(.horizontal)
                    .background(.white.opacity(0.2))
                }
                VStack(alignment: .leading) {
                    HStack {
                        // Button that allows users to change the cover image of the journal
                        Button {
                            showImagePicker = true
                        } label: {
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                Text("Change Cover Image")
                            }
                            .font(.caption)
                            .padding(4)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        Spacer ()
                        
                        // Save journal button
                        Button {
                            journalModel.saveDraft()
                            dismiss()
                            
                        } label: {
                            Text("Save")
                                .font(.subheadline)
                                .frame(width: 70, height: 25)
                                .background(Color.blue.opacity(0.2))
                                
                                .cornerRadius(8)
                        }
                    
                    }
                    
                    HStack {
                        Button {
                            showDatePicker.toggle()
                        } label: {
                            Image(systemName: "calendar")
                            Text(DateFormatStyle(for: journal.date ?? Date()))
                            Image(systemName: "chevron.down")
                            
                        }
                    }
                    .font(.caption)
                    .padding(4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    Divider()
                    // Journal content
                    TextEditor(text: Binding (
                        get: { journal.content ?? ""},
                        set: { journal.content = $0 }
                    ))
                    .frame(height: 550)
                    
                    //.border(.gray.opacity(0.25))
                    
                }
                .padding(.horizontal)
                .sheet(isPresented: $showImagePicker) {
                    ImagePickerView(journalModel: journalModel) { photo in
                        journal.imageURL = photo.src.medium
                        coverImageURL = photo.src.medium
                        journalModel.saveContext()
                    }
                }
                
            }
        }
    }
    
    
}

private func DateFormatStyle(for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM d, yyyy"
    return formatter.string(from: date)
}


struct JournalDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sampleJournal = JournalEntry(context: context)
        let viewModel = JournalViewModel()
        viewModel.entries = [sampleJournal]
        
        return JournalDetailView(journal: sampleJournal)
            .environmentObject(viewModel)
        
    }
}
