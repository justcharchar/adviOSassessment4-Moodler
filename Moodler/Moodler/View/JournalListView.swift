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
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var selectedDate: Date? = nil
    @State private var showDatePicker: Bool = false
    @State private var showAddJournal: Bool = false
    @State private var createdJournal: JournalEntry? = nil
    
    private let brandBackground = Color(red: 0.976, green: 0.953, blue: 0.929)
    private let cardColor = Color(red: 0.957, green: 0.910, blue: 0.875)
    
    private var filteredEntries: [JournalEntry] {
        if let date = selectedDate {
            let calendar = Calendar.current
            return journalModel.entries.filter { entry in
                if let entryDate = entry.date {
                    return calendar.isDate(entryDate, inSameDayAs: date)
                }
                return false
            }
        } else {
            return journalModel.entries
        }
    }
    
    private var journalDates: [Date] {
        journalModel.entries.compactMap { $0.date }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                brandBackground.ignoresSafeArea()
                VStack(alignment: .leading) {
                    
                    // MARK: - Header
                    HStack {
                        Text("Your Journals")
                            .font(.largeTitle.bold())
                        
                        Spacer()
                        
                        Button {
                            showDatePicker.toggle()
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "calendar")
                                Text(selectedDate != nil ? formatDate(selectedDate!) : "Filter Date")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(red: 0.957, green: 0.910, blue: 0.875))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // MARK: - Journal List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if filteredEntries.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "book.circle")
                                        .font(.system(size: 72))
                                        .foregroundColor(.blue.opacity(0.8))
                                    Text(selectedDate == nil ? "Your journals will appear here" : "No journals found for this date")
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 50)
                            } else {
                                ForEach(filteredEntries, id: \.objectID) { journal in
                                    NavigationLink(
                                        destination: JournalDetailView(journal: journal)
                                            .environmentObject(journalModel)
                                    ) {
                                        JournalDisplayView(journal: journal)
                                    }
                                }
                            }
                        }
                        .padding(.top)
                        .frame(maxWidth: .infinity)
                    }
                }
                
                // MARK: - Add Journal Floating Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            if let newJournal = journalModel.addJournal() {
                                print("🆕 Created new journal ID: \(newJournal.id?.uuidString ?? "nil")")
                                createdJournal = newJournal
                                showAddJournal = true
                            } else {
                                print("⚠️ Failed to create new journal.")
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .frame(width: 60, height: 60)
                                .background(Color(red: 0.957, green: 0.910, blue: 0.875))
                                .foregroundColor(.black)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 30)
                    }
                }
            }
            
            .sheet(isPresented: $showDatePicker) {
                CalendarWithDots(
                    selectedDate: $selectedDate,
                    journalDates: journalDates
                )
                .presentationDetents([.medium])
            }
            
            .navigationDestination(isPresented: $showAddJournal) {
                if let j = createdJournal {
                    JournalDetailView(journal: j)
                        .id(j.objectID)
                        .environmentObject(journalModel)
                } else {
                    EmptyView()
                }
            }
        }
        .onAppear {
            journalModel.fetchJournals()
        }
    }
}

private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    return formatter.string(from: date)
}

struct CalendarWithDots: View {
    @Binding var selectedDate: Date?
    let journalDates: [Date]
    
    @State private var currentMonth: Date = Date()
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))
        else { return [] }
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: monthStart)
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 20)
            
            // Month Nav
            HStack {
                Button {
                    currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .padding(8)
                }
                
                Spacer()
                Text(monthTitle)
                    .font(.title2.bold())
                Spacer()
                
                Button {
                    currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .padding(8)
                }
            }
            .padding(.horizontal)
            
            // Days grid
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(daysInMonth, id: \.self) { date in
                    VStack(spacing: 4) {
                        Text("\(calendar.component(.day, from: date))")
                            .font(.subheadline)
                            .fontWeight(calendar.isDate(date, inSameDayAs: selectedDate ?? Date()) ? .bold : .regular)
                            .foregroundColor(calendar.isDate(date, inSameDayAs: selectedDate ?? Date()) ? .white : .primary)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(calendar.isDate(date, inSameDayAs: selectedDate ?? Date()) ? Color.blue : Color.clear)
                            )
                            .onTapGesture {
                                selectedDate = date
                            }
                        
                        if journalDates.contains(where: { calendar.isDate($0, inSameDayAs: date) }) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 6, height: 6)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            
            Button {
                selectedDate = nil
            } label: {
                Text("Clear Filter")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
            .padding(.bottom, 20)
        }
    }
}
