//
//  JournalDetailView.swift
//  Moodler
//
//  Created by Chloe on 18/10/2025.
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
    @State var showDeleteAlert: Bool = false
    
    
    var body: some View {

        ScrollView {
            
            VStack(alignment: .leading, spacing: 16) {
                
                // MARK: Top Menu
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .padding()
                            .background(Circle().fill(Color.gray.opacity(0.1)))
                    }
                    Spacer()
                    
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.title3)
                            .padding()
                            .foregroundColor(.black)
                            .background(Circle().fill(Color.gray.opacity(0.1)))
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
                    
                    Button {
                       withAnimation(.bouncy) {
                           journalModel.toggleFavourite(for: journal)
                       }
                   } label: {
                       Image(systemName: journalModel.isFavourite(journal: journal) ? "heart.fill" : "heart")
                           .font(.title3)
                           .foregroundColor(.pink)
                           .padding()
                           .background(Circle().fill(Color.gray.opacity(0.1)))
                   }
                    // NEED TO DO
                    Button {
                        
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .padding()
                            .background(Circle().fill(Color.gray.opacity(0.1)))
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
                    
                    Divider()
                    
                    HStack {
                        // MOOD ANALYSIS - MACHINE LEARNING
                        Button {
                            
                        } label: {
                            Text("Mood Analysis")
                            Image(systemName: "brain")
                        }
                        .font(.subheadline)
                        .foregroundColor(.purple)
                        .padding(8)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(15)
                        
                        Spacer()
                        
                        Button {
                            journalModel.saveDraft()
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
                    
                    
                    // IMAGE SELECTION THING HERE
                    
                    
                    // CONTENT 
                    
                }
            }
            .padding(.horizontal)
          
            
        }
    
    }
    
    
}

private func DateFormatStyle(for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "- MMMM d, yyyy -"
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
