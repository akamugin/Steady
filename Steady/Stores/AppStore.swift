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
    var userProfile = UserProfile.default
    var usesCustomGoals = false

    var meals: [MealEntry] = []
    var water: [WaterEntry] = []

    init() {
        goals = recommendedGoals(for: userProfile)
    }

    func logMeal(name: String, calories: Int, protein: Int) {
        meals.insert(MealEntry(name: name, calories: calories, protein: protein, timestamp: .now), at: 0)
    }

    func addWater(ml: Int) {
        water.insert(WaterEntry(ml: ml, timestamp: .now), at: 0)
    }

    func removeWaterEntries(ids: Set<UUID>) {
        water.removeAll { ids.contains($0.id) }
    }

    func updateMeal(id: UUID, name: String, calories: Int, protein: Int) {
        guard let index = meals.firstIndex(where: { $0.id == id }) else { return }
        meals[index].name = name
        meals[index].calories = calories
        meals[index].protein = protein
    }

    func updateWater(id: UUID, ml: Int) {
        guard let index = water.firstIndex(where: { $0.id == id }) else { return }
        water[index].ml = ml
    }

    func updateUserProfile(_ profile: UserProfile) {
        userProfile = profile
        guard !usesCustomGoals else { return }
        goals = recommendedGoals(for: profile)
    }

    func updateGoals(calories: Int, protein: Int, waterMl: Int) {
        goals = Goals(
            calories: max(calories, 0),
            protein: max(protein, 0),
            waterMl: max(waterMl, 0)
        )
        usesCustomGoals = true
    }

    func resetGoalsToRecommended() {
        usesCustomGoals = false
        goals = recommendedGoals(for: userProfile)
    }

    func recommendedGoals(for profile: UserProfile) -> Goals {
        let weightKg = profile.weightLb * 0.45359237
        let bmrWoman = (10 * weightKg) + (6.25 * profile.heightCm) - (5 * Double(profile.age)) - 161
        let bmrMan = (10 * weightKg) + (6.25 * profile.heightCm) - (5 * Double(profile.age)) + 5

        let calorieValue: Double
        switch profile.genderIdentity {
        case .woman:
            calorieValue = bmrWoman
        case .man:
            calorieValue = bmrMan
        case .nonBinary, .preferNotToSay:
            calorieValue = (bmrWoman + bmrMan) / 2.0
        }

        let caloriesGoal = max(Int(calorieValue.rounded()), 1200)
        let proteinGoal = max(Int((profile.weightLb * 0.5).rounded()), 1)

        let waterOz = profile.weightLb / 2.0
        let waterMl = max(Int((waterOz * 29.5735).rounded()), 250)

        return Goals(calories: caloriesGoal, protein: proteinGoal, waterMl: waterMl)
    }

    var recommendedWaterPerDrinkMl: Int {
        let times = max(userProfile.waterTimesPerDay, 1)
        return max(goals.waterMl / times, 1)
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
