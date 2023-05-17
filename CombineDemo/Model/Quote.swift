//
//  Quote.swift
//  CombineDemo
//
//  Created by Pardy Panda Mac Mini on 16/05/23.
//

import Foundation


struct QuotesModel : Codable {
    let count, totalCount, page, totalPages: Int?
    let lastItemIndex: Int?
    let results: [Quote]?
}

struct Quote : Codable {
    let id, content, author: String?
    let tags: [String]?
    let authorSlug: String?
    let length: Int?
    let dateAdded, dateModified: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case content, author, tags, authorSlug, length, dateAdded, dateModified
    }
}
