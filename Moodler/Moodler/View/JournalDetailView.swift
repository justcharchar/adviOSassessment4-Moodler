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
    
    @ObservedObject var journalEntry: JournalEntry
    var body: some View {
        Text("Journal Detail View")
    }
}
