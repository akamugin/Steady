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
        Button {
            store.addWater(ml: 250)
        } label: {
            Image("water_icon")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
        }
        .buttonStyle(.plain)
    }
}
