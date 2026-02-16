//
//  SettingView.swift
//  Steady
//
//  Created by Stella Lee on 2/16/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppStore.self) private var store
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                List {
                    Text("settings 123")
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
        .environment(AppStore())
}

