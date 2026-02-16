//
//  LogMealView.swift
//  Steady
//
//  Created by Stella Lee on 2/15/26.
//

import SwiftUI

struct LogMealView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var calories = ""
    @State private var protein = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Meal") {
                    TextField("Name (e.g., chicken bowl)", text: $name)
                    TextField("Calories", text: $calories)
                        .keyboardType(.numberPad)
                    TextField("Protein (g)", text: $protein)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Log Meal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Log") {
                        let cals = Int(calories) ?? 0
                        let pro = Int(protein) ?? 0
                        store.logMeal(name: name.isEmpty ? "Meal" : name, calories: cals, protein: pro)
                        dismiss()
                    }
                    .disabled((Int(calories) ?? 0) <= 0 && (Int(protein) ?? 0) <= 0 && name.isEmpty)
                }
            }
        }
    }
}

