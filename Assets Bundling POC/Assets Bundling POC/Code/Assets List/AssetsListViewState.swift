//
//  AssetsListViewState.swift
//  Assets Bundling POC
//

import Foundation

struct AssetListViewRowData: Equatable, Identifiable, Hashable {
    let id: UUID
    let state: State
    let name: String
}

extension AssetListViewRowData {

    enum State: Equatable {
        case notLoaded
        case loading
        case loaded
    }
}

struct AssetsListViewState: Equatable {
    let assets: [AssetListViewRowData]
}
