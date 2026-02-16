//
//  CharacterHeaderView.swift
//  Steady
//
//  Created by Stella Lee on 2/15/26.
//

import SwiftUI

struct CharacterHeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            Text("🙂") //TODO: SWAP LATER FOR MY CHARACTER
                .font(.system(size: 48))
            
            VStack(alignment: .leading) {
                Text("Hi! Let's stay steady.")
                    .font(.title3).bold()
                Text("Log a meal to help me grow.")
                    .foregroundStyle(.secondary)
            }
        }
        Spacer()
    }
}
