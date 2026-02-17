//
//  UserProfile.swift
//  Steady
//
//  Created by Codex on 2/16/26.
//

import Foundation

enum GenderIdentity: String, CaseIterable, Codable, Identifiable {
    case woman
    case man
    case nonBinary
    case preferNotToSay

    var id: String { rawValue }

    var label: String {
        switch self {
        case .woman: return "Woman"
        case .man: return "Man"
        case .nonBinary: return "Non-binary"
        case .preferNotToSay: return "Prefer not to say"
        }
    }
}

struct UserProfile: Codable, Equatable {
    var age: Int
    var weightLb: Double
    var heightCm: Double
    var genderIdentity: GenderIdentity
    var waterTimesPerDay: Int

    static let `default` = UserProfile(
        age: 25,
        weightLb: 150,
        heightCm: 165,
        genderIdentity: .woman,
        waterTimesPerDay: 8
    )
}
