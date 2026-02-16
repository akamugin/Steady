//
//  WaterEntry.swift
//  Steady
//
//  Created by Stella Lee on 2/15/26.
//

import Foundation

struct WaterEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var ml: Int
    var timestamp: Date

    init(id: UUID = UUID(), ml: Int, timestamp: Date) {
        self.id = id
        self.ml = ml
        self.timestamp = timestamp
    }
}

