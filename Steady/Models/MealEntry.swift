
//
//  MealsEntry.swift
//  Steady
//
//  Created by Stella Lee on 2/15/26.
//

import Foundation

struct MealEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var calories: Int
    var protein: Int
    var timestamp: Date

    init(id: UUID = UUID(), name: String, calories: Int, protein: Int, timestamp: Date) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.timestamp = timestamp
    }
}
