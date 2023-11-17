//
//  AssetListRowView.swift
//  Assets Bundling POC
//

import SwiftUI

struct AssetListRowView: View {
    let data: AssetListViewRowData
    var thumbnailWidth = 30.0
    var thumbnailHeight = 30.0

    var body: some View {
        // TODO: Move to separate view.
        HStack {
            switch data.state {
            case .loaded:
                Image(systemName: "checkmark.circle.fill")
                    .assetListIconStyle()
            case let .loading(progress):
                ProgressView(value: progress)
                    .progressViewStyle(GaugeProgressStyle())
                    .frame(width: thumbnailWidth, height: thumbnailHeight)
            case .notLoaded:
                ProgressView(value: 0)
                    .progressViewStyle(GaugeProgressStyle())
                    .frame(width: thumbnailWidth, height: thumbnailHeight)
            case .failed:
                Image(systemName: "xmark.circle.fill")
                    .assetListIconStyle()
            }
            Text(data.name)
                .font(.body)
                .listRowSeparator(.hidden)
                .tint(.primary)
        }
        .animation(.easeIn, value: data.state)
    }
}
