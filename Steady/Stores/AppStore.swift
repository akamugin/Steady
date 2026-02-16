//
//  AppStore.swift
//  Steady
//
//  Created by Stella Lee on 2/15/26.
//

import Foundation
import Observation

@Observable
final class AppStore {
    var goals = Goals(calories: 2000, protein: 120, waterMl: 2000)

    var meals: [MealEntry] = []
    var water: [WaterEntry] = []

    func logMeal(name: String, calories: Int, protein: Int) {
        meals.insert(MealEntry(name: name, calories: calories, protein: protein, timestamp: .now), at: 0)
    }

    func addWater(ml: Int) {
        water.insert(WaterEntry(ml: ml, timestamp: .now), at: 0)
    }

    var todayCalories: Int {
        meals.filter { Calendar.current.isDateInToday($0.timestamp) }.reduce(0) { $0 + $1.calories }
    }

    var todayProtein: Int {
        meals.filter { Calendar.current.isDateInToday($0.timestamp) }.reduce(0) { $0 + $1.protein }
    }

    var todayWaterMl: Int {
        water.filter { Calendar.current.isDateInToday($0.timestamp) }.reduce(0) { $0 + $1.ml }
    }
}
