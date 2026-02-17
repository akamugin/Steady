//
//  LogMealView.swift
//  Steady
//
//  Created by Stella Lee on 2/15/26.
//

import SwiftUI
import UIKit
import Vision

struct LogMealView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var inputMode: LogInputMode = .photo
    @State private var name = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var capturedImage: UIImage?
    @State private var showingCamera = false
    @State private var isAnalyzingImage = false
    @State private var detectedFoodLabel: String?
    @State private var detectionStatus: String?
    @State private var isLookingUpNutrition = false
    @State private var nutritionStatus: String?
    @State private var caloriesEditedManually = false
    @State private var proteinEditedManually = false
    @State private var isApplyingAutoFill = false
    @State private var nutritionLookupTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            ZStack {
                RadialGradient(
                    colors: [
                        Color(red: 1.0, green: 0.95, blue: 0.70),
                        Color(red: 0.68, green: 0.92, blue: 0.70)
                    ],
                    center: .center,
                    startRadius: 30,
                    endRadius: 900
                )
                .ignoresSafeArea()

                ParticleBackgroundView()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("log your munch")
                            .font(.system(size: 33, weight: .black, design: .rounded))

                        Text("snap your plate or nutrition label, or type it in")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)

                        Picker("Input Mode", selection: $inputMode) {
                            ForEach(LogInputMode.allCases) { mode in
                                Text(mode.label).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)

                        if inputMode == .photo {
                            photoCaptureCard
                        }

                        mealDetailsCard
                    }
                    .padding()
                }
            }
            .navigationTitle("meal log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        store.logMeal(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Meal" : name,
                            calories: Int(calories) ?? 0,
                            protein: Int(protein) ?? 0
                        )
                        dismiss()
                    }
                    .disabled(isSaveDisabled)
                }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraCaptureView(image: $capturedImage, isPresented: $showingCamera)
                    .ignoresSafeArea()
            }
            .onChange(of: capturedImage) { _, newImage in
                guard let image = newImage else { return }
                analyzeFood(in: image)
            }
            .onChange(of: name) { _, newName in
                scheduleNutritionLookup(for: newName)
            }
            .onChange(of: calories) { _, newValue in
                guard !isApplyingAutoFill else { return }
                caloriesEditedManually = !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            .onChange(of: protein) { _, newValue in
                guard !isApplyingAutoFill else { return }
                proteinEditedManually = !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
        }
    }

    private var isSaveDisabled: Bool {
        (Int(calories) ?? 0) <= 0 && (Int(protein) ?? 0) <= 0 && name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var photoCaptureCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.35))
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "camera.macro")
                                .font(.system(size: 28))
                            Text("no photo yet")
                                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        }
                        .foregroundStyle(.secondary)
                    }
                    .frame(height: 180)
            }

            if isAnalyzingImage {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("reading photo...")
                        .font(.system(.subheadline, design: .rounded))
                }
            } else if let detectedFoodLabel {
                Text("looks like: \(detectedFoodLabel)")
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
            } else if let detectionStatus {
                Text(detectionStatus)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Button {
                showingCamera = true
            } label: {
                Label("Take photo", systemImage: "camera.fill")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

            if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                Text("Camera is unavailable here. You can still use manual mode.")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.45))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.55), lineWidth: 1)
        )
    }

    private var mealDetailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("meal details")
                .font(.system(.headline, design: .rounded).weight(.heavy))

            TextField("what did you eat?", text: $name)
                .textFieldStyle(.roundedBorder)

            HStack(spacing: 10) {
                TextField("cals", text: $calories)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)

                TextField("protein (g)", text: $protein)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
            }

            Text("you can edit these after auto-detection.")
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)

            if isLookingUpNutrition {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("researching nutrition...")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            } else if let nutritionStatus {
                Text(nutritionStatus)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(
            WavyCardShape(waveAmplitude: 2.0, waveCount: 3)
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
        )
        .overlay {
            WavyCardShape(waveAmplitude: 2.0, waveCount: 3)
                .stroke(Color.white.opacity(0.45), lineWidth: 1)
        }
    }

    private func analyzeFood(in image: UIImage) {
        detectedFoodLabel = nil
        detectionStatus = nil
        isAnalyzingImage = true

        Task {
            let labelNutrition = try? await extractNutritionFromLabel(in: image)
            let labels = try? await classifyImageLabels(from: image)
            let foodMatch = labels?.first(where: { looksLikeFood($0.identifier) }) ?? labels?.first

            await MainActor.run {
                isAnalyzingImage = false

                if let labelNutrition {
                    isApplyingAutoFill = true
                    if !caloriesEditedManually {
                        calories = String(labelNutrition.calories)
                    }
                    if !proteinEditedManually {
                        protein = String(labelNutrition.protein)
                    }
                    isApplyingAutoFill = false
                    nutritionStatus = "pulled calories/protein from nutrition facts label."
                }

                if let foodMatch {
                    let suggestion = prettifyLabel(foodMatch.identifier)
                    detectedFoodLabel = suggestion
                    if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        name = suggestion
                    }
                } else if labelNutrition == nil {
                    detectionStatus = "couldn't identify food. you can type it manually."
                }
            }
        }
    }

    private func scheduleNutritionLookup(for mealName: String) {
        nutritionLookupTask?.cancel()
        let query = mealName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard query.count >= 3 else {
            isLookingUpNutrition = false
            nutritionStatus = nil
            return
        }

        nutritionLookupTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(450))
                try Task.checkCancellation()
                await lookupAndApplyNutrition(for: query)
            } catch {
                // Task cancelled; ignore.
            }
        }
    }

    @MainActor
    private func lookupAndApplyNutrition(for query: String) async {
        isLookingUpNutrition = true
        nutritionStatus = nil

        do {
            guard let result = try await NutritionResearcher.shared.lookup(mealName: query) else {
                isLookingUpNutrition = false
                nutritionStatus = "couldn't find strong nutrition data yet."
                return
            }

            isApplyingAutoFill = true
            if !caloriesEditedManually {
                calories = String(result.calories)
            }
            if !proteinEditedManually {
                protein = String(result.protein)
            }
            isApplyingAutoFill = false

            isLookingUpNutrition = false
            let sourceLabel = result.source == .preset ? "local estimate" : "food database estimate"
            nutritionStatus = "auto-filled from \(sourceLabel). edit if needed."
        } catch {
            isLookingUpNutrition = false
            nutritionStatus = "nutrition lookup failed. you can type values manually."
        }
    }

    private func classifyImageLabels(from image: UIImage) async throws -> [VNClassificationObservation] {
        try await Task.detached(priority: .userInitiated) {
            guard let cgImage = image.cgImage else {
                throw FoodDetectionError.invalidImage
            }

            let request = VNClassifyImageRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try handler.perform([request])
            return request.results ?? []
        }.value
    }

    private func extractNutritionFromLabel(in image: UIImage) async throws -> NutritionEstimate? {
        let recognizedText = try await recognizeText(in: image)
        guard !recognizedText.isEmpty else { return nil }

        let caloriesPattern = #"(?:calories|calorie)\s*[:\-]?\s*(\d{1,4})|(\d{1,4})\s*(?:kcal|calories)"#
        let proteinPattern = #"(?:protein)\s*[:\-]?\s*(\d{1,3}(?:\.\d+)?)\s*g?|(\d{1,3}(?:\.\d+)?)\s*g\s*(?:protein)"#

        guard
            let calories = firstIntMatch(in: recognizedText, pattern: caloriesPattern),
            let proteinValue = firstDoubleMatch(in: recognizedText, pattern: proteinPattern)
        else {
            return nil
        }

        return NutritionEstimate(
            calories: max(calories, 1),
            protein: max(Int(proteinValue.rounded()), 0),
            source: .label
        )
    }

    private func recognizeText(in image: UIImage) async throws -> String {
        try await Task.detached(priority: .userInitiated) {
            guard let cgImage = image.cgImage else {
                throw FoodDetectionError.invalidImage
            }

            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.minimumTextHeight = 0.015

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try handler.perform([request])

            let text = (request.results ?? [])
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")

            return text.lowercased()
        }.value
    }

    private func firstIntMatch(in text: String, pattern: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }

        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range) else {
            return nil
        }

        for idx in 1..<match.numberOfRanges {
            let matchRange = match.range(at: idx)
            guard
                matchRange.location != NSNotFound,
                let swiftRange = Range(matchRange, in: text),
                let value = Int(String(text[swiftRange]))
            else { continue }
            return value
        }

        return nil
    }

    private func firstDoubleMatch(in text: String, pattern: String) -> Double? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }

        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range) else {
            return nil
        }

        for idx in 1..<match.numberOfRanges {
            let matchRange = match.range(at: idx)
            guard
                matchRange.location != NSNotFound,
                let swiftRange = Range(matchRange, in: text),
                let value = Double(String(text[swiftRange]))
            else { continue }
            return value
        }

        return nil
    }

    private func looksLikeFood(_ label: String) -> Bool {
        let lowered = label.lowercased()
        let keywords = [
            "food", "meal", "dish", "fruit", "vegetable", "bread", "rice", "salad",
            "pizza", "burger", "pasta", "noodle", "soup", "sandwich", "meat",
            "chicken", "beef", "fish", "egg", "dessert", "cake", "cookie", "taco",
            "sushi", "fries", "drink", "coffee", "tea"
        ]
        return keywords.contains(where: lowered.contains)
    }

    private func prettifyLabel(_ raw: String) -> String {
        raw
            .components(separatedBy: ",")
            .first?
            .replacingOccurrences(of: "_", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized ?? raw.capitalized
    }
}

private actor NutritionResearcher {
    static let shared = NutritionResearcher()

    private let presets: [String: NutritionEstimate] = [
        "chicken bowl": .init(calories: 520, protein: 36, source: .preset),
        "salad": .init(calories: 280, protein: 10, source: .preset),
        "caesar salad": .init(calories: 420, protein: 14, source: .preset),
        "avocado toast": .init(calories: 310, protein: 9, source: .preset),
        "oatmeal": .init(calories: 250, protein: 8, source: .preset),
        "yogurt bowl": .init(calories: 320, protein: 14, source: .preset),
        "omelette": .init(calories: 280, protein: 20, source: .preset),
        "fried rice": .init(calories: 450, protein: 12, source: .preset),
        "sushi": .init(calories: 380, protein: 17, source: .preset),
        "ramen": .init(calories: 540, protein: 19, source: .preset),
        "pasta": .init(calories: 520, protein: 18, source: .preset),
        "burger": .init(calories: 560, protein: 27, source: .preset),
        "sandwich": .init(calories: 420, protein: 20, source: .preset),
        "taco": .init(calories: 210, protein: 9, source: .preset),
        "pizza": .init(calories: 300, protein: 12, source: .preset)
    ]

    func lookup(mealName: String) async throws -> NutritionEstimate? {
        let normalized = mealName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if let direct = presets[normalized] {
            return direct
        }

        if let fuzzy = presets.first(where: { normalized.contains($0.key) || $0.key.contains(normalized) })?.value {
            return fuzzy
        }

        return try await lookupFromOpenFoodFacts(query: mealName)
    }

    private func lookupFromOpenFoodFacts(query: String) async throws -> NutritionEstimate? {
        var components = URLComponents(string: "https://world.openfoodfacts.org/cgi/search.pl")
        components?.queryItems = [
            URLQueryItem(name: "search_terms", value: query),
            URLQueryItem(name: "search_simple", value: "1"),
            URLQueryItem(name: "action", value: "process"),
            URLQueryItem(name: "json", value: "1"),
            URLQueryItem(name: "page_size", value: "20")
        ]

        guard let url = components?.url else { return nil }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            return nil
        }

        let decoded = try JSONDecoder().decode(OpenFoodFactsResponse.self, from: data)
        for product in decoded.products {
            guard
                let kcal = product.nutriments.kcalPer100g,
                let protein = product.nutriments.proteinPer100g,
                kcal > 0,
                protein >= 0
            else { continue }

            // Use a practical single-meal estimate from per-100g values.
            let estimatedCalories = Int((kcal * 2.2).rounded())
            let estimatedProtein = Int((protein * 2.2).rounded())
            return NutritionEstimate(
                calories: max(estimatedCalories, 1),
                protein: max(estimatedProtein, 0),
                source: .database
            )
        }

        return nil
    }
}

private struct NutritionEstimate {
    let calories: Int
    let protein: Int
    let source: NutritionSource
}

private enum NutritionSource {
    case preset
    case database
    case label
}

private struct OpenFoodFactsResponse: Decodable {
    let products: [OpenFoodProduct]
}

private struct OpenFoodProduct: Decodable {
    let nutriments: OpenFoodNutriments
}

private struct OpenFoodNutriments: Decodable {
    let kcalPer100g: Double?
    let proteinPer100g: Double?

    enum CodingKeys: String, CodingKey {
        case kcalPer100g = "energy-kcal_100g"
        case proteinPer100g = "proteins_100g"
    }
}

private enum FoodDetectionError: Error {
    case invalidImage
}

private enum LogInputMode: String, CaseIterable, Identifiable {
    case photo
    case manual

    var id: String { rawValue }
    var label: String {
        switch self {
        case .photo: return "Photo"
        case .manual: return "Manual"
        }
    }
}

private struct CameraCaptureView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraCaptureView

        init(parent: CameraCaptureView) {
            self.parent = parent
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            parent.image = info[.originalImage] as? UIImage
            parent.isPresented = false
        }
    }
}

private struct WavyCardShape: InsettableShape {
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
