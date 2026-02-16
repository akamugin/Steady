//
//  SteadyApp.swift
//  Steady
//
//  Created by Stella Lee on 2/15/26.
//

import SwiftUI

@main
struct SteadyApp: App {
    @State private var store = AppStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
