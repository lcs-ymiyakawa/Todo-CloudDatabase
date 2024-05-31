//
//  TodoItem.swift
//  TodoList
//
//  Created by Russell Gordon on 2024-04-08.
//

import Foundation

struct TodoItem: Identifiable, Codable {
    var id: Int?
    var title: String
    var done:  Bool
    var imageURL: String?

    // When decoding and encoding from JSON, translate snake_case
    // column names into camelCase
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case done
        case imageURL = "image_url"
    }
}

let firstItem = TodoItem(title: "Study for Chemisty quiz", done: false)

let secondItem = TodoItem(title: "Finish Computer Science assignment", done: true)

let thirdItem = TodoItem(title: "Go for a run around campus", done: false)

let exampleItems = [
    
    firstItem
    ,
    secondItem
    ,
    thirdItem
    ,
    
]
