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
    
    private let brandBackground = Color(red: 0.976, green: 0.953, blue: 0.929)
    private let cardColor = Color(red: 0.957, green: 0.910, blue: 0.875)

    var favouriteJournals: [JournalEntry] {
        journalModel.entries.filter { $0.isFavourite }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    if favouriteJournals.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "heart.slash.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.pink)
                            Text("You currently have no favourited journals")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 80)
                    } else {
                        ForEach(favouriteJournals, id: \.objectID) { journal in
                            NavigationLink(
                                destination: JournalDetailView(journal: journal)
                                    .environmentObject(journalModel)
                            ) {
                                JournalDisplayView(journal: journal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(brandBackground.ignoresSafeArea())
            .navigationTitle("Favourite Journals")
        }
    }
}
