//
//  ContentView.swift
//  Steady
//
//  Created by Stella Lee on 2/15/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView ()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            HistoryView ()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            SettingsView ()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Color(red: 0.24, green: 0.67, blue: 0.42))
    }
}

#Preview {
    ContentView()
        .environment(AppStore())
}
