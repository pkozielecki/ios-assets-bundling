//
//  AssetDetailsViewState.swift
//  Assets Bundling POC
//

import Foundation
import Assets_Bundling_POC_Commons

enum AssetDetailsViewState: Equatable {
    case loading
    case loaded(ViewData)
    case error
}

extension AssetDetailsViewState {
    struct ViewData: Equatable {
        let title: String
        let subtitle: String
        let description: String
        let imageURL: URL
        let videoURL: URL
        let documentURL: URL
    }
}
