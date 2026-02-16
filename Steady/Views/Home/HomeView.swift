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
            VStack(alignment: .leading, spacing: 16) {
                CharacterHeaderView()
                
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
                
                Button {
                    showingLogMeal = true
                } label: {
                    Text("Feed (Log Meal)")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                
                WaterQuickAddView()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Steady")
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

