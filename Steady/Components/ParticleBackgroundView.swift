//
//  ParticleBackgroundView.swift
//  Steady
//
//  Created by Stella Lee on 2/16/26.
//

import SwiftUI

struct ParticleBackgroundView: View {
    private struct Particle: Identifiable {
        let id = UUID()
        let x: Double
        let y: Double
        let size: Double
        let speed: Double
        let drift: Double
    }

    private static let particles: [Particle] = (0..<80).map { i in
        let base = Double(i)
        return Particle(
            x: Double((base * 0.73).truncatingRemainder(dividingBy: 1)),
            y: Double((base * 0.41).truncatingRemainder(dividingBy: 1)),
            size: 1.5 + Double((base * 0.19).truncatingRemainder(dividingBy: 1)) * 2.0,
            speed: 0.006 + Double((base * 0.23).truncatingRemainder(dividingBy: 1)) * 0.01,
            drift: 8 + Double((base * 0.17).truncatingRemainder(dividingBy: 1)) * 14
        )
    }

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                Canvas { context, size in
                    for particle in Self.particles {
                        let y = (particle.y + t * particle.speed)
                            .truncatingRemainder(dividingBy: 1)
                        let xOffset = sin(t * 0.6 + particle.x * 12) * particle.drift
                        let point = CGPoint(
                            x: particle.x * size.width + xOffset,
                            y: y * size.height
                        )

                        let rect = CGRect(
                            x: point.x,
                            y: point.y,
                            width: particle.size,
                            height: particle.size
                        )

                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(Color.white.opacity(0.6))
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    ParticleBackgroundView()
}
