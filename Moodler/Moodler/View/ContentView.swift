//
//  ContentView.swift
//  Moodler
//
//  Created by Chloe on 15/10/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var journalModel = JournalViewModel()

    var body: some View {
        
        TabView {
            HomeView().environmentObject(journalModel)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            JournalListView().environmentObject(journalModel)
                .tabItem {
                    Image(systemName: "book.pages.fill")
                    Text("Journals")
                }
            
            FavouriteJournalView().environmentObject(journalModel)
                .tabItem {
                    Image(systemName: "heart")
                    Text("Favourite")
                }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
