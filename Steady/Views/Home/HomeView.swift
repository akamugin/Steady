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

                        VStack(spacing: 10) {
                            Text("Today")
                                .font(.headline)

                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Calories: \(store.todayCalories) / \(store.goals.calories)")
                                    Text("Protein: \(store.todayProtein)g / \(store.goals.protein)g")
                                    Text("Water: \(store.todayWaterMl)ml / \(store.goals.waterMl)ml")
                                }
                                Spacer()
                            }
                        }
                        .padding()
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

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
}

#Preview {
    HomeView()
        .environment(AppStore())
}
