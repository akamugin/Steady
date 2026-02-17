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
        if !loadState() {
            goals = recommendedGoals(for: userProfile)
            saveState()
        }
    }

    func logMeal(name: String, calories: Int, protein: Int) {
        meals.insert(MealEntry(name: name, calories: calories, protein: protein, timestamp: .now), at: 0)
        saveState()
    }

    func addWater(ml: Int) {
        water.insert(WaterEntry(ml: ml, timestamp: .now), at: 0)
        saveState()
    }

    func removeWaterEntries(ids: Set<UUID>) {
        water.removeAll { ids.contains($0.id) }
        saveState()
    }

    func updateMeal(id: UUID, name: String, calories: Int, protein: Int) {
        guard let index = meals.firstIndex(where: { $0.id == id }) else { return }
        meals[index].name = name
        meals[index].calories = calories
        meals[index].protein = protein
        saveState()
    }

    func updateWater(id: UUID, ml: Int) {
        guard let index = water.firstIndex(where: { $0.id == id }) else { return }
        water[index].ml = ml
        saveState()
    }

    func updateUserProfile(_ profile: UserProfile) {
        userProfile = profile
        if !usesCustomGoals {
            goals = recommendedGoals(for: profile)
        }
        saveState()
    }

    func updateGoals(calories: Int, protein: Int, waterMl: Int) {
        goals = Goals(
            calories: max(calories, 0),
            protein: max(protein, 0),
            waterMl: max(waterMl, 0)
        )
        usesCustomGoals = true
        saveState()
    }

    func resetGoalsToRecommended() {
        usesCustomGoals = false
        goals = recommendedGoals(for: userProfile)
        saveState()
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

    private struct PersistedState: Codable {
        var goals: Goals
        var userProfile: UserProfile
        var usesCustomGoals: Bool
        var meals: [MealEntry]
        var water: [WaterEntry]
    }

    private static var storageURL: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directory = base.appendingPathComponent("Steady", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("app-state.json")
    }

    private func saveState() {
        let snapshot = PersistedState(
            goals: goals,
            userProfile: userProfile,
            usesCustomGoals: usesCustomGoals,
            meals: meals,
            water: water
        )

        do {
            let data = try JSONEncoder().encode(snapshot)
            try data.write(to: Self.storageURL, options: .atomic)
        } catch {
            assertionFailure("Failed to save app state: \(error)")
        }
    }

    private func loadState() -> Bool {
        do {
            let data = try Data(contentsOf: Self.storageURL)
            let saved = try JSONDecoder().decode(PersistedState.self, from: data)
            goals = saved.goals
            userProfile = saved.userProfile
            usesCustomGoals = saved.usesCustomGoals
            meals = saved.meals
            water = saved.water
            return true
        } catch {
            return false
        }
    }
}
