//
//  JournalDetailView.swift
//  Moodler
//
//  Created by Chloe on 18/10/2025.
//

import SwiftUI
import CoreData
import CoreML

struct JournalDetailView: View {
    
    @EnvironmentObject var journalModel: JournalViewModel
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var journal: JournalEntry
    
    @State private var showImageSearchPicker: Bool = false
    @State private var showUserLibraryPicker: Bool = false
    @State private var selectedUIImage: UIImage?
    @State private var coverImageURL: String?
    @State var showDeleteAlert: Bool = false
    
    private let brandBackground = Color(red: 0.976, green: 0.953, blue: 0.929)
    private let cardColor = Color(red: 0.957, green: 0.910, blue: 0.875)
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // MARK: - TOP MENU
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .padding()
                            .background(Circle().fill(cardColor))
                    }
                    
                    Spacer()
                    
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.title3)
                            .padding()
                            .foregroundColor(.black)
                            .background(Circle().fill(cardColor))
                    }
                    .alert(isPresented: $showDeleteAlert) {
                        Alert(
                            title: Text("Delete Journal"),
                            message: Text("Are you sure you want to delete this journal? This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete")) {
                                journalModel.deleteJournal(journal)
                                dismiss()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    
                    Button {
                        withAnimation(.bouncy) {
                            journalModel.toggleFavourite(for: journal)
                        }
                    } label: {
                        Image(systemName: journalModel.isFavourite(journal: journal) ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundColor(.pink)
                            .padding()
                            .background(Circle().fill(cardColor))
                    }
                    
                    if let title = journal.title, let content = journal.content {
                        ShareLink(
                            item: "\(title)\n\n\(content)",
                            subject: Text("Check out my journal entry!")
                        ) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3)
                                .padding()
                                .background(Circle().fill(cardColor))
                        }
                    } else {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .padding()
                            .background(Circle().fill(cardColor))
                    }
                }
                
                
                VStack(spacing: 16) {
                    Text(DateFormatStyle(for: journal.date ?? Date()))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    TextField("Title", text: Binding(
                        get: { journal.title ?? "" },
                        set: { journal.title = $0 }
                    ))
                    .multilineTextAlignment(.center)
                    .font(.title.bold())
                    .padding(.vertical, 6)
                    .background(cardColor.opacity(0.7))
                    .cornerRadius(10)
                    
                    Divider()
                    
                    HStack {
                        Button {
                            journalModel.predictMood(for: journal)
                        } label: {
                            if let mood = journal.emotion {
                                Text("Predicted Mood: \(mood)")
                                Image(systemName: "arrow.clockwise")
                            } else {
                                Text("Mood Analysis")
                                Image(systemName: "brain")
                            }
                        }
                        .disabled((journal.content ?? "").isEmpty)
                        .opacity((journal.content ?? "").isEmpty ? 0.5 : 1)
                        .font(.subheadline)
                        .foregroundColor(.purple)
                        .padding(8)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(15)
                        
                        Spacer()
                        
                        Button {
                            journalModel.saveDraft(journal)
                            dismiss()
                        } label: {
                            Text("Save Entry")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.green)
                        .padding(8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(15)
                    }
                    
                    // MARK: - IMAGE AREA
                    ZStack(alignment: .topTrailing) {
                        if let data = journal.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .cornerRadius(15)
                                .clipped()
                            
                            Button {
                                selectedUIImage = nil
                                journal.imageData = nil
                                journalModel.saveContext()
                            } label: {
                                Image(systemName: "xmark")
                                    .padding(7)
                                    .background(Circle().fill(cardColor.opacity(0.9)))
                                    .shadow(radius: 2)
                            }
                            .padding([.top, .trailing], 8)
                            
                        } else if let urlString = coverImageURL, let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .cornerRadius(15)
                                    .clipped()
                            } placeholder: {
                                cardColor.opacity(0.5)
                                    .frame(height: 200)
                                    .cornerRadius(15)
                            }
                            
                            Button {
                                coverImageURL = nil
                                journal.imageURL = nil
                                journalModel.saveContext()
                            } label: {
                                Image(systemName: "xmark")
                                    .padding(7)
                                    .background(Circle().fill(cardColor.opacity(0.9)))
                                    .shadow(radius: 2)
                            }
                            .padding([.top, .trailing], 8)
                            
                        } else {
                            VStack(spacing: 30) {
                                Button {
                                    showUserLibraryPicker = true
                                } label: {
                                    Image(systemName: "photo")
                                    Text("Choose from Library")
                                }
                                .frame(maxWidth: .infinity)
                                
                                Button {
                                    showImageSearchPicker = true
                                } label: {
                                    Image(systemName: "magnifyingglass")
                                    Text("Search Image")
                                }
                            }
                            .frame(height: 200)
                            .background(cardColor)
                            .cornerRadius(15)
                        }
                    }
                    .onAppear {
                        coverImageURL = journal.imageURL
                    }
                    
                    // MARK: - JOURNAL CONTENT
                    ZStack(alignment: .topLeading) {
                        // Placeholder text when empty
                        if (journal.content ?? "").isEmpty {
                            Text("Write a Journal")
                                .foregroundColor(.gray.opacity(2))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 12)
                        }
                        TextEditor(text: Binding(
                            get: { journal.content ?? "" },
                            set: { journal.content = $0 }
                        ))
                        .scrollContentBackground(.hidden)
                        .frame(height: 550)
                        .padding(4)
                        .background(cardColor.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        )
                        .cornerRadius(15)
                    }
                    
                    // Image pickers
                    .sheet(isPresented: $showUserLibraryPicker) {
                        ImagePicker(image: $selectedUIImage)
                            .onDisappear {
                                if let selectedUIImage = selectedUIImage,
                                   let data = selectedUIImage.jpegData(compressionQuality: 0.8) {
                                    journal.imageData = data
                                    journalModel.saveContext()
                                }
                            }
                    }
                    .sheet(isPresented: $showImageSearchPicker) {
                        ImagePickerView(journalModel: journalModel) { photo in
                            journal.imageURL = photo.src.large
                            coverImageURL = photo.src.large
                            journalModel.saveContext()
                        }
                    }
                }
                .padding(.horizontal)
            }
            .background(brandBackground.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
        }
    }
}
// Date formatter
private func DateFormatStyle(for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "- MMMM d, yyyy -"
    return formatter.string(from: date)
}
