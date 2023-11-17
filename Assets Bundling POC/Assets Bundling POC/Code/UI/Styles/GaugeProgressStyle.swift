//
//  GaugeProgressStyle.swift
//  Assets Bundling POC
//

import SwiftUI

/// SeeAlso: https://developer.apple.com/videos/play/wwdc2023/10108/
struct GaugeProgressStyle: ProgressViewStyle {
    var strokeColor = Color("Progress-Background")
    var strokeWidth = 6.0

    public func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0

        return Circle()
            .fill(
                strokeColor.opacity(0.1)
            )
            .frame(width: 30, height: 30)
            .overlay {
                ZStack {
                    Circle()
                        .trim(from: 0, to: CGFloat(fractionCompleted))
                        .stroke(strokeColor, style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 20, height: 20)
                        .animation(.linear, value: fractionCompleted)
                }
            }
    }
}
