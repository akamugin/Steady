//
//  TitleHeaderView.swift
//  Steady
//
//  Created by Stella Lee on 2/16/26.
//

import SwiftUI
import UIKit

struct TitleHeaderView: View {
    private static var didLogFonts = false

    private let titleFont = Font.custom("Super Magic", size: 72)

    var body: some View {
        ZStack {
            Text("Steady")
                .font(titleFont)
                .kerning(3.5)
                .foregroundStyle(Color(red: 0.18, green: 0.55, blue: 0.38))
                .offset(x: 6, y: 6)
                .blur(radius: 0.3)

            Text("Steady")
                .font(titleFont)
                .kerning(3.5)
                .foregroundStyle(Color(red: 0.30, green: 0.72, blue: 0.46))
                .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 6)
                .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 2)

            Text("Steady")
                .font(titleFont)
                .kerning(3.5)
                .foregroundStyle(Color.white.opacity(0.35))
                .offset(x: -2, y: -3)
                .blendMode(.screen)
        }
    }
}

#Preview {
    TitleHeaderView()
        .environment(AppStore())
}
