//
//  AssetsListViewState.swift
//  Assets Bundling POC
//

import Foundation

struct AssetListViewRowData: Equatable, Identifiable, Hashable {
    var id: String
    let state: State
    let name: String
}

extension AssetListViewRowData {

    enum State: Equatable, Hashable {
        case notLoaded
        case loading(Int)
        case loaded
        case failed
    }
}

struct AssetsListViewState: Equatable {
    let assetsListRows: [AssetListViewRowData]
}
