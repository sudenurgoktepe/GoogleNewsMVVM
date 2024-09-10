//
//  NewsDto.swift
//  NewsApp
//
//  Created by sude on 24.07.2024.
//

import Foundation

struct NewsResponse: Codable {
    let success: Bool
    let result: [Article]
}

struct Article: Codable, Equatable, Hashable {
    let key: String
    let url: String?
    let description: String?
    let image: String?
    let name: String
    let source: String
    
    enum CodingKeys: CodingKey {
        case key
        case url
        case description
        case image
        case name
        case source
    }
    var isFavorited: Bool? = false
}
