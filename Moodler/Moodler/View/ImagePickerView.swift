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
    
    // MARK: - Theme Colors
    private let brandBackground = Color(red: 0.976, green: 0.953, blue: 0.929)
    private let cardColor = Color(red: 0.957, green: 0.910, blue: 0.875)

    // MARK: - Image Picker View for Image API
    var body: some View {
        NavigationStack {
            ZStack {
                brandBackground.ignoresSafeArea()
                
                VStack {
                    // MARK: - Search Bar
                    HStack {
                        TextField("Search images", text: $searchText, onCommit: {
                            searchImages()
                        })
                        .padding(10)
                        .background(cardColor)
                        .cornerRadius(10)

                        Button("Search") {
                            searchImages()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(cardColor)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // MARK: - Image Grid
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(photos) { photo in
                                AsyncImage(url: URL(string: photo.src.medium)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 120)
                                        .clipped()
                                        .cornerRadius(10)
                                        .background(cardColor)
                                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                } placeholder: {
                                    ZStack {
                                        cardColor
                                            .frame(height: 120)
                                            .cornerRadius(10)
                                        ProgressView()
                                    }
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
                .navigationBarTitleDisplayMode(.inline)
            }
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
