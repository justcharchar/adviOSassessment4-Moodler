//
//  ImagePickerView.swift
//  Moodler
//
//  Created by Chloe on 17/10/2025.
//

import SwiftUI

struct ImagePickerView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var journalModel: JournalViewModel
    @State private var searchText: String = ""
    @State private var photos: [Photo] = []
    
    let onSelect: (Photo) -> Void

        var body: some View {
            NavigationStack {
                VStack {
                    HStack {
                        
                        // Search bar
                        TextField("Search images", text: $searchText, onCommit: {
                            searchImages()
                        })
                        .textFieldStyle(.roundedBorder)
                        Button("Search") { searchImages() }
                    }
                    .padding()

                    ScrollView {
                        
                        // Photo Display
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(photos) { photo in
                                AsyncImage(url: URL(string: photo.src.medium)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 120)
                                        .clipped()
                                        .cornerRadius(8)
                                } placeholder: {
                                    ProgressView()
                                }
                                .onTapGesture {
                                    onSelect(photo)
                                    dismiss()
                                }
                            }
                        }
                        .padding()
                    }
                }
                .navigationTitle("Select Image")
            }
            .onAppear { searchImages() }
        }

    private func searchImages() {
        guard !searchText.isEmpty else { return }
        journalModel.searchPexelsImages(query: searchText) { results in
            self.photos = results
        }
    }

}

