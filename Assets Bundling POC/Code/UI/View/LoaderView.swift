//
//  LoaderView.swift
//  Assets Bundling POC
//

import SwiftUI

extension LoaderView {
    struct Configuration {
        let message: String
        let width: Double
        let height: Double
        let backgroundColor: Color
        let cornerRadius: Double
    }
}

struct LoaderView: View {
    let configuration: Configuration

    var body: some View {
        ZStack(alignment: .center) {
            ProgressView(configuration.message)
                .tint(.primary)
                .scaleEffect(2)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .frame(width: configuration.width, height: configuration.height)
        .background(configuration.backgroundColor)
        .cornerRadius(configuration.cornerRadius)
    }
}

struct LoaderView_Previews: PreviewProvider {
    static var previews: some View {
        LoaderView(configuration: .default)
    }
}

extension LoaderView.Configuration {

    static var `default`: LoaderView.Configuration {
        .init(
            message: "Loading...",
            width: 200,
            height: 150,
            backgroundColor: .secondary.opacity(0.2),
            cornerRadius: 10
        )
    }
}
