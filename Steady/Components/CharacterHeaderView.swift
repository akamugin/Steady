//
//  CharacterHeaderView.swift
//  Steady
//
//  Created by Stella Lee on 2/15/26.
//

import SwiftUI

struct CharacterHeaderView: View {
    static let imageHeight: CGFloat = 240

    var body: some View {
        VStack(spacing: 10) {
            Image("character_1")
                .resizable()
                .scaledToFit()
                .frame(height: Self.imageHeight)

            VStack(spacing: 2) {
                Text("Hi, let's do this!")
                    .font(.system(size: 25, weight: .black, design: .rounded))
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CharacterHeaderView()
        .environment(AppStore())
}
