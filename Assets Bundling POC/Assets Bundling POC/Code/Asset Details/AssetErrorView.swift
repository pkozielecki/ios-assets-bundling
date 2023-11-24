//
//  AssetErrorView.swift
//  Assets Bundling POC
//

import SwiftUI

struct AssetErrorView: View {
    let title: String
    let message: String
    let onFixBrokenAssetRequested: () async -> Void

    var body: some View {
        VStack {

            // MARK: Title

            Text(title)
                .font(.largeTitle)
                .padding()

            // MARK: Subtitle

            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)

            // MARK: Action button

            Button("Reload Asset") {
                Task {
                    await onFixBrokenAssetRequested()
                }
            }
            .buttonStyle(CapsuleActionButtonStyle())
            .font(.subheadline)
            .padding()
        }
    }
}
