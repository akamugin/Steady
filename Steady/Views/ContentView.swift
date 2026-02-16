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
                    Label("Home", systemImage: "")
                }
            HistoryView ()
                .tabItem {
                    Label("History", systemImage: "")
                }
            SettingsView ()
                .tabItem {
                    Label("Setting", systemImage: "")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppStore())
}
