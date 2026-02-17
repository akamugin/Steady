//
//  HomeView.swift
//  Steady
//
//  Created by Stella Lee on 2/15/26.
//

import SwiftUI

struct HomeView: View {
    @Environment(AppStore.self) private var store
    @State private var showingLogMeal = false
    
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

                ZStack {
                    VStack(alignment: .leading, spacing: 16) {
                        TitleHeaderView()
                            .frame(maxWidth: .infinity, alignment: .center)

                        Spacer(minLength: 0)

                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("today")
                                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                                Spacer()
                                Text("\(todayCompletionPercent)% done")
                                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                                    .foregroundStyle(.secondary)
                            }

                            TodayMetricRow(
                                title: "calorie",
                                valueText: "\(store.todayCalories)kcal",
                                goalText: "\(store.goals.calories)kcal",
                                tint: .orange,
                                progress: todayCaloriesProgress
                            )

                            TodayMetricRow(
                                title: "protein",
                                valueText: "\(store.todayProtein)g",
                                goalText: "\(store.goals.protein)g",
                                tint: .mint,
                                progress: todayProteinProgress
                            )

                            TodayMetricRow(
                                title: "water",
                                valueText: "\(store.todayWaterMl)ml",
                                goalText: "\(store.goals.waterMl)ml",
                                tint: .blue,
                                progress: todayWaterProgress
                            )
                        }
                        .padding(16)
                        .background(
                            WavyFrameShape(waveAmplitude: 2.2, waveCount: 3)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.97, blue: 0.83).opacity(0.86),
                                            Color(red: 0.86, green: 0.95, blue: 0.80).opacity(0.82)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: Color.black.opacity(0.10), radius: 8, y: 4)
                        )
                        .overlay {
                            WavyFrameShape(waveAmplitude: 2.2, waveCount: 3)
                                .stroke(Color.white.opacity(0.45), lineWidth: 1)
                        }

                        HStack {
                            Spacer()

                            Button {
                                showingLogMeal = true
                            } label: {
                                Image("feed_icon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 72, height: 72)
                            }
                            .buttonStyle(.plain)

                            Spacer(minLength: 0)
                            Spacer(minLength: 0)

                            WaterQuickAddView()

                            Spacer()
                        }
                    }
                    .padding()

                    GeometryReader { proxy in
                        CharacterHeaderView()
                            .offset(y: (proxy.size.height / 2) - CharacterHeaderView.imageHeight)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
//            .navigationTitle("Steady")
            .sheet(isPresented: $showingLogMeal) {
                LogMealView()
            }
        }
    }

    private var todayCaloriesProgress: Double {
        progress(value: store.todayCalories, goal: store.goals.calories)
    }

    private var todayProteinProgress: Double {
        progress(value: store.todayProtein, goal: store.goals.protein)
    }

    private var todayWaterProgress: Double {
        progress(value: store.todayWaterMl, goal: store.goals.waterMl)
    }

    private var todayCompletionPercent: Int {
        Int(((todayCaloriesProgress + todayProteinProgress + todayWaterProgress) / 3.0) * 100.0)
    }

    private func progress(value: Int, goal: Int) -> Double {
        guard goal > 0 else { return 0 }
        return min(max(Double(value) / Double(goal), 0), 1)
    }
}

private struct TodayMetricRow: View {
    let title: String
    let valueText: String
    let goalText: String
    let tint: Color
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                Spacer()
                Text("\(valueText) / \(goalText)")
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
            }

            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(tint)
        }
    }
}

private struct WavyFrameShape: InsettableShape {
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
    HomeView()
        .environment(AppStore())
}
