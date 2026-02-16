//
//  HistoryView.swift
//  Steady
//
//  Created by Stella Lee on 2/15/26.
//

import SwiftUI

struct HistoryView: View {
    @Environment(AppStore.self) private var store
    @State private var selectedDate = Date()
    
    var mealsForSelectedDate: [MealEntry] {
        store.meals
            .filter { Calendar.current.isDate($0.timestamp, inSameDayAs: selectedDate)}
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    var waterForSelectedDate: [WaterEntry] {
        store.water
            .filter { Calendar.current.isDate($0.timestamp, inSameDayAs: selectedDate) }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                DatePicker(
                    "Select a date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal)
                
                List {
                    Section(header: Text("Meals")) {
                        if mealsForSelectedDate.isEmpty {
                            Text("No meals logged today!").foregroundStyle(.secondary)
                        }
                        else {
                            ForEach(mealsForSelectedDate) { meal in VStack(alignment: .leading, spacing: 4) {
                                Text(meal.name).font(.headline)
                                Text("\(meal.calories) cal * \(meal.protein)g protein").foregroundStyle(.secondary)
                                Text(formatTime(meal.timestamp))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                            }
                        }
                    }
                    Section(header: Text("Water")) {
                        if waterForSelectedDate.isEmpty {
                            Text("No water logged.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(waterForSelectedDate) { entry in
                                HStack {
                                    Text("+\(entry.ml) ml")
                                    Spacer()
                                    Text(formatTime(entry.timestamp))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
        }
    }
    private func formatTime(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}


#Preview {
    HistoryView()
        .environment(AppStore())
}

