//
//  SettingView.swift
//  Steady
//
//  Created by Stella Lee on 2/16/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppStore.self) private var store

    @State private var ageText = ""
    @State private var weightLbText = ""
    @State private var heightCmText = ""
    @State private var selectedGender: GenderIdentity = .woman
    @State private var waterTimesText = ""

    @State private var goalCaloriesText = ""
    @State private var goalProteinText = ""
    @State private var goalWaterText = ""
    @State private var feedbackMessage: String?
    @State private var isEditingProfile = false
    @State private var isEditingGoals = false

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
                        if let feedbackMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                Text(feedbackMessage)
                                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            }
                            .foregroundStyle(.green)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.60))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("settings vibes")
                                .font(.system(size: 34, weight: .black, design: .rounded))
                            Text("tune your profile and let goals auto-adjust")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 4)

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Label("profile setup", systemImage: "person.crop.circle")
                                    .font(.system(.headline, design: .rounded).weight(.bold))
                                Spacer()
                                if isEditingProfile {
                                    Text("editing")
                                        .font(.system(.caption, design: .rounded).weight(.bold))
                                        .foregroundStyle(.secondary)
                                } else {
                                    Button("edit profile") {
                                        isEditingProfile = true
                                    }
                                    .font(.system(.caption, design: .rounded).weight(.bold))
                                    .buttonStyle(.plain)
                                    .foregroundStyle(.secondary)
                                }
                            }

                            if isEditingProfile {
                                HStack(spacing: 10) {
                                    LabeledInputField(title: "age", text: $ageText, keyboard: .numberPad)
                                    LabeledInputField(title: "weight (lb)", text: $weightLbText, keyboard: .decimalPad)
                                }

                                HStack(spacing: 10) {
                                    LabeledInputField(title: "height (cm)", text: $heightCmText, keyboard: .decimalPad)
                                    LabeledInputField(title: "water times/day", text: $waterTimesText, keyboard: .numberPad)
                                }

                                Picker("Gender", selection: $selectedGender) {
                                    ForEach(GenderIdentity.allCases) { identity in
                                        Text(identity.label).tag(identity)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.35))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                                HStack(spacing: 10) {
                                    Button {
                                        applyProfile()
                                        isEditingProfile = false
                                        showSavedFeedback("Profile + recommended goals saved")
                                    } label: {
                                        Label("apply profile", systemImage: "sparkles")
                                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color.white.opacity(0.55))
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    }
                                    .buttonStyle(.plain)

                                    Button {
                                        syncProfileFieldsFromStore()
                                        isEditingProfile = false
                                    } label: {
                                        Text("cancel")
                                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color.white.opacity(0.42))
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                }
                            } else {
                                HStack(spacing: 8) {
                                    GoalPill(title: "age", value: "\(store.userProfile.age)")
                                    GoalPill(title: "weight", value: "\(Int(store.userProfile.weightLb.rounded())) lb")
                                    GoalPill(title: "height", value: "\(Int(store.userProfile.heightCm.rounded())) cm")
                                }

                                HStack(spacing: 8) {
                                    GoalPill(title: "gender", value: store.userProfile.genderIdentity.label)
                                    GoalPill(title: "water/day", value: "\(store.userProfile.waterTimesPerDay)x")
                                }

                            }
                        }
                        .padding(14)
                        .background(settingsCardBackground)

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Label("current goals", systemImage: "target")
                                    .font(.system(.headline, design: .rounded).weight(.bold))
                                Spacer()
                                Text(store.usesCustomGoals ? "custom mode" : "auto mode")
                                    .font(.system(.caption, design: .rounded).weight(.bold))
                                    .foregroundStyle(.secondary)
                            }

                            HStack(spacing: 8) {
                                GoalPill(title: "cals", value: "\(store.goals.calories)")
                                GoalPill(title: "protein", value: "\(store.goals.protein)g")
                                GoalPill(title: "water", value: "\(store.goals.waterMl)ml")
                            }
                        }
                        .padding(14)
                        .background(settingsCardBackground)

                        VStack(alignment: .leading, spacing: 10) {
                            Label("recommended goals", systemImage: "chart.bar.xaxis")
                                .font(.system(.headline, design: .rounded).weight(.bold))

                            let recommended = recommendedGoalsPreview
                            HStack(spacing: 8) {
                                GoalPill(title: "calories", value: "\(recommended.calories)")
                                GoalPill(title: "protein", value: "\(recommended.protein)g")
                                GoalPill(title: "water", value: "\(recommended.waterMl)ml")
                            }
                            Text("per drink target: \(recommendedPerDrinkMl(for: resolvedProfile, waterMl: recommended.waterMl))ml")
                                .foregroundStyle(.secondary)
                                .font(.system(.footnote, design: .rounded))

                            Button {
                                store.updateUserProfile(resolvedProfile)
                                store.resetGoalsToRecommended()
                                syncGoalFieldsFromStore()
                                showSavedFeedback("Using recommended goals")
                            } label: {
                                Label("use recommended now", systemImage: "checkmark.circle.fill")
                                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.55))
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(14)
                        .background(settingsCardBackground)

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Label("goal edit", systemImage: "slider.horizontal.3")
                                    .font(.system(.headline, design: .rounded).weight(.bold))
                                Spacer()
                                Text(store.usesCustomGoals ? "custom" : "recommended")
                                    .font(.system(.caption, design: .rounded).weight(.bold))
                                    .foregroundStyle(.secondary)
                            }

                            if isEditingGoals {
                                HStack(spacing: 10) {
                                    LabeledInputField(title: "calorie goal", text: $goalCaloriesText, keyboard: .numberPad)
                                    LabeledInputField(title: "protein goal (g)", text: $goalProteinText, keyboard: .numberPad)
                                }

                                LabeledInputField(title: "water goal (ml)", text: $goalWaterText, keyboard: .numberPad)

                                HStack(spacing: 10) {
                                    Button {
                                        store.updateGoals(
                                            calories: Int(goalCaloriesText) ?? 0,
                                            protein: Int(goalProteinText) ?? 0,
                                            waterMl: Int(goalWaterText) ?? 0
                                        )
                                        syncGoalFieldsFromStore()
                                        isEditingGoals = false
                                        showSavedFeedback("Custom goals saved")
                                    } label: {
                                        Text("save custom")
                                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 11)
                                            .background(Color.white.opacity(0.58))
                                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                                    }
                                    .buttonStyle(.plain)

                                    Button {
                                        store.updateUserProfile(resolvedProfile)
                                        store.resetGoalsToRecommended()
                                        syncGoalFieldsFromStore()
                                        isEditingGoals = false
                                        showSavedFeedback("Reset to recommended goals")
                                    } label: {
                                        Text("reset recommended")
                                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 11)
                                            .background(Color.white.opacity(0.44))
                                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                }
                            } else {
                                HStack(spacing: 8) {
                                    GoalPill(title: "calories", value: "\(store.goals.calories)")
                                    GoalPill(title: "protein", value: "\(store.goals.protein)g")
                                    GoalPill(title: "water", value: "\(store.goals.waterMl)ml")
                                }

                                Button {
                                    isEditingGoals = true
                                } label: {
                                    Label("edit goals", systemImage: "line.3.horizontal")
                                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 11)
                                        .background(Color.white.opacity(0.50))
                                        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(14)
                        .background(settingsCardBackground)
                    }
                    .padding()
                }
            }
            .navigationTitle("settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                syncProfileFieldsFromStore()
                syncGoalFieldsFromStore()
            }
        }
    }

    private var resolvedProfile: UserProfile {
        UserProfile(
            age: max(Int(ageText) ?? store.userProfile.age, 1),
            weightLb: max(Double(weightLbText) ?? store.userProfile.weightLb, 1),
            heightCm: max(Double(heightCmText) ?? store.userProfile.heightCm, 1),
            genderIdentity: selectedGender,
            waterTimesPerDay: max(Int(waterTimesText) ?? store.userProfile.waterTimesPerDay, 1)
        )
    }

    private var recommendedGoalsPreview: Goals {
        store.recommendedGoals(for: resolvedProfile)
    }

    private var settingsCardBackground: some View {
        WavySettingsShape(waveAmplitude: 2.0, waveCount: 3)
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
                WavySettingsShape(waveAmplitude: 2.0, waveCount: 3)
                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
            }
    }

    private func recommendedPerDrinkMl(for profile: UserProfile, waterMl: Int) -> Int {
        max(waterMl / max(profile.waterTimesPerDay, 1), 1)
    }

    private func applyProfile() {
        store.updateUserProfile(resolvedProfile)
        syncProfileFieldsFromStore()
        syncGoalFieldsFromStore()
    }

    private func syncProfileFieldsFromStore() {
        ageText = String(store.userProfile.age)
        weightLbText = String(Int(store.userProfile.weightLb.rounded()))
        heightCmText = String(Int(store.userProfile.heightCm.rounded()))
        selectedGender = store.userProfile.genderIdentity
        waterTimesText = String(store.userProfile.waterTimesPerDay)
    }

    private func syncGoalFieldsFromStore() {
        goalCaloriesText = String(store.goals.calories)
        goalProteinText = String(store.goals.protein)
        goalWaterText = String(store.goals.waterMl)
    }

    private func showSavedFeedback(_ message: String) {
        withAnimation(.spring(duration: 0.25)) {
            feedbackMessage = message
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeOut(duration: 0.2)) {
                feedbackMessage = nil
            }
        }
    }
}

private struct GoalPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(.caption2, design: .rounded).weight(.bold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(.subheadline, design: .rounded).weight(.heavy))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.38))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct LabeledInputField: View {
    let title: String
    @Binding var text: String
    var keyboard: UIKeyboardType

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundStyle(.secondary)
            TextField(title, text: $text)
                .keyboardType(keyboard)
                .textFieldStyle(.roundedBorder)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct WavySettingsShape: InsettableShape {
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
    SettingsView()
        .environment(AppStore())
}
