//
//  SteadyApp.swift
//  Steady
//
//  Created by Stella Lee on 2/15/26.
//

import SwiftUI
import CoreText

@main
struct SteadyApp: App {
    @State private var store = AppStore()
    
    init() {
        if let url = Bundle.main.url(forResource: "SuperMagic-L3XVn", withExtension: "ttf") {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
