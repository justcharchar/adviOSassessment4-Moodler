//
//  ImageAPI.swift
//  Moodler
//
//  Created by Chloe on 16/10/2025.
//

import Foundation

struct PexelsResponse: Codable {
    let photos: [Photo]
    let totalResults: Int
    let page: Int
    let perPage: Int

    enum CodingKeys: String, CodingKey {
        case photos
        case totalResults = "total_results"
        case page
        case perPage = "per_page"
    }
}

struct Photo: Codable, Identifiable {
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let photographer: String
    let src: PhotoSrc
}

struct PhotoSrc: Codable {
    let original: String
    let large: String
    let medium: String
    let small: String
}

