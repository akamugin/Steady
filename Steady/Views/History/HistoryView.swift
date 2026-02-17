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
    @State private var editingMeal: MealEntry?
    @State private var editingWater: WaterEntry?
    
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
            ZStack {
                RadialGradient(
                    colors: [
                        Color(red: 1.0, green: 0.95, blue: 0.70),
                        Color(red: 0.68, green: 0.92, blue: 0.70)
                    ],
                    center: .center,
                    startRadius: 40,
                    endRadius: 800
                )
                .ignoresSafeArea()

                ParticleBackgroundView()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("history vibes")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .padding(.horizontal, 4)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("pick a day")
                                .font(.system(.headline, design: .rounded).weight(.bold))
                            DatePicker(
                                "Select a date",
                                selection: $selectedDate,
                                displayedComponents: .date
                            )
                            .labelsHidden()
                            .datePickerStyle(.graphical)
                        }
                        .padding(14)
                        .background(historyCardBackground)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("meals")
                                .font(.system(.headline, design: .rounded).weight(.bold))

                            if mealsForSelectedDate.isEmpty {
                                Text("no meals logged for this day yet")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            } else {
                                ForEach(mealsForSelectedDate) { meal in
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(meal.name)
                                                .font(.system(.headline, design: .rounded).weight(.semibold))
                                            Text("\(meal.calories) cals • \(meal.protein)g protein")
                                                .font(.system(.subheadline, design: .rounded))
                                                .foregroundStyle(.secondary)
                                            Text(formatTime(meal.timestamp))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer(minLength: 0)
                                        Button {
                                            editingMeal = meal
                                        } label: {
                                            Image(systemName: "line.3.horizontal")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundStyle(.primary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white.opacity(0.35))
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }
                            }
                        }
                        .padding(14)
                        .background(historyCardBackground)

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("water")
                                    .font(.system(.headline, design: .rounded).weight(.bold))
                                Spacer()
                                Button("undo last add") {
                                    undoLastWaterForSelectedDate()
                                }
                                .font(.system(.subheadline, design: .rounded).weight(.bold))
                                .disabled(waterForSelectedDate.isEmpty)
                            }

                            if waterForSelectedDate.isEmpty {
                                Text("no water logged for this day")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(waterForSelectedDate) { entry in
                                    HStack {
                                        Text("+\(entry.ml) ml")
                                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                                        Spacer()
                                        Text(formatTime(entry.timestamp))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Button {
                                            editingWater = entry
                                        } label: {
                                            Image(systemName: "line.3.horizontal")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundStyle(.primary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(12)
                                    .background(Color.white.opacity(0.35))
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }
                            }
                        }
                        .padding(14)
                        .background(historyCardBackground)
                    }
                    .padding()
                }
            }
            .navigationTitle("history")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $editingMeal) { meal in
                MealEditSheet(meal: meal) { updatedName, updatedCalories, updatedProtein in
                    store.updateMeal(
                        id: meal.id,
                        name: updatedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Meal" : updatedName,
                        calories: max(updatedCalories, 0),
                        protein: max(updatedProtein, 0)
                    )
                }
            }
            .sheet(item: $editingWater) { water in
                WaterEditSheet(water: water) { updatedMl in
                    store.updateWater(id: water.id, ml: max(updatedMl, 0))
                }
            }
        }
    }

    private var historyCardBackground: some View {
        WavyHistoryShape(waveAmplitude: 2.0, waveCount: 3)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.97, blue: 0.83).opacity(0.88),
                        Color(red: 0.86, green: 0.95, blue: 0.80).opacity(0.85)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay {
                WavyHistoryShape(waveAmplitude: 2.0, waveCount: 3)
                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
            }
    }

    private func undoLastWaterForSelectedDate() {
        guard let latest = waterForSelectedDate.first else { return }
        store.removeWaterEntries(ids: [latest.id])
    }

    private func formatTime(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}

private struct MealEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    let meal: MealEntry
    let onSave: (_ name: String, _ calories: Int, _ protein: Int) -> Void

    @State private var name: String
    @State private var calories: String
    @State private var protein: String

    init(meal: MealEntry, onSave: @escaping (_ name: String, _ calories: Int, _ protein: Int) -> Void) {
        self.meal = meal
        self.onSave = onSave
        _name = State(initialValue: meal.name)
        _calories = State(initialValue: String(meal.calories))
        _protein = State(initialValue: String(meal.protein))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Meal") {
                    TextField("name", text: $name)
                    TextField("calories", text: $calories)
                        .keyboardType(.numberPad)
                    TextField("protein (g)", text: $protein)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("edit meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        onSave(name, Int(calories) ?? 0, Int(protein) ?? 0)
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct WaterEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    let water: WaterEntry
    let onSave: (_ ml: Int) -> Void

    @State private var ml: String

    init(water: WaterEntry, onSave: @escaping (_ ml: Int) -> Void) {
        self.water = water
        self.onSave = onSave
        _ml = State(initialValue: String(water.ml))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Water") {
                    TextField("milliliters", text: $ml)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("edit water")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        onSave(Int(ml) ?? 0)
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct WavyHistoryShape: InsettableShape {
    var waveAmplitude: CGFloat
    var waveCount: CGFloat
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let r = rect.insetBy(dx: insetAmount, dy: insetAmount)
        guard r.width > 0, r.height > 0 else { return Path() }

        let cornerRadius = min(r.width, r.height) * 0.10
        let topStart = CGPoint(x: r.minX + cornerRadius, y: r.minY)
        let topEnd = CGPoint(x: r.maxX - cornerRadius, y: r.minY)
        let rightStart = CGPoint(x: r.maxX, y: r.minY + cornerRadius)
        let rightEnd = CGPoint(x: r.maxX, y: r.maxY - cornerRadius)
        let bottomStart = CGPoint(x: r.maxX - cornerRadius, y: r.maxY)
        let bottomEnd = CGPoint(x: r.minX + cornerRadius, y: r.maxY)
        let leftStart = CGPoint(x: r.minX, y: r.maxY - cornerRadius)
        let leftEnd = CGPoint(x: r.minX, y: r.minY + cornerRadius)

        var path = Path()
        path.move(to: topStart)
        addWavyEdge(to: &path, from: topStart, toPoint: topEnd, amplitude: waveAmplitude, waves: waveCount, outward: -1)
        path.addQuadCurve(to: rightStart, control: CGPoint(x: r.maxX, y: r.minY))
        addWavyEdge(to: &path, from: rightStart, toPoint: rightEnd, amplitude: waveAmplitude, waves: waveCount, outward: 1)
        path.addQuadCurve(to: bottomStart, control: CGPoint(x: r.maxX, y: r.maxY))
        addWavyEdge(to: &path, from: bottomStart, toPoint: bottomEnd, amplitude: waveAmplitude, waves: waveCount, outward: 1)
        path.addQuadCurve(to: leftStart, control: CGPoint(x: r.minX, y: r.maxY))
        addWavyEdge(to: &path, from: leftStart, toPoint: leftEnd, amplitude: waveAmplitude, waves: waveCount, outward: -1)
        path.addQuadCurve(to: topStart, control: CGPoint(x: r.minX, y: r.minY))
        path.closeSubpath()
        return path
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }

    private func addWavyEdge(
        to path: inout Path,
        from start: CGPoint,
        toPoint end: CGPoint,
        amplitude: CGFloat,
        waves: CGFloat,
        outward: CGFloat
    ) {
        let segments = max(Int(waves) * 14, 20)
        for i in 1...segments {
            let t = CGFloat(i) / CGFloat(segments)
            let x = start.x + (end.x - start.x) * t
            let y = start.y + (end.y - start.y) * t

            let nx = -(end.y - start.y)
            let ny = (end.x - start.x)
            let nLen = max(sqrt(nx * nx + ny * ny), 0.0001)
            let ux = nx / nLen
            let uy = ny / nLen

            let wave = sin(t * .pi * 2 * waves) * amplitude * outward
            path.addLine(to: CGPoint(x: x + ux * wave, y: y + uy * wave))
        }
    }
}


#Preview {
    ContentView()
        .environment(AppStore())
}
