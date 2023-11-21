//
//  AssetsListViewState.swift
//  Assets Bundling POC
//

import Foundation

enum AssetsListViewState: Equatable {
    case loading
    case loaded(assetsListRows: [AssetListViewRowData])
    case noAssets
}

struct AssetListViewRowData: Equatable, Identifiable, Hashable {
    var id: String
    let state: State
    let name: String
}

extension AssetListViewRowData {

    enum State: Equatable, Hashable {
        case notLoaded
        case loading(Double)
        case toBeTransferred
        case loaded
        case failed
    }
}
