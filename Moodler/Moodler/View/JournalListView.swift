//
//  JournalListView.swift
//  Moodler
//
//  Created by Chloe on 19/10/2025.
//

import SwiftUI
import CoreData

struct JournalListView: View {
    @EnvironmentObject var journalModel: JournalViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                
                LazyVStack {
                    if journalModel.entries.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "book.circle")
                                .font(.system(size: 72))
                                .foregroundColor(.blue.opacity(0.8))
                            
                            Text("Your journals will appear here ")
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 50)
                    } else {
                        // Displays all of the users journals
                        ForEach(journalModel.entries, id: \.objectID) { journal in
                            NavigationLink(destination: JournalDetailView(journal: journal)
                                .environmentObject(journalModel)) {
                                    JournalDisplayView(journal: journal)
                                }
                        }
                    }
                }
                .padding(.top)
            }
            .navigationBarTitle("Your Journals")
        }
       
       
    }
}
