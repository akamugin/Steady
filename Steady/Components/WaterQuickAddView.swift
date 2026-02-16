//
//  WaterQuickAddView.swift
//  Steady
//
//  Created by Stella Lee on 2/15/26.
//

import SwiftUI

struct WaterQuickAddView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        HStack(spacing: 12) {
            Button("+250ml") { store.addWater(ml: 250) }
            Button("+500ml") { store.addWater(ml: 500) }
            Spacer()
        }
        .buttonStyle(.bordered)
    }
}

