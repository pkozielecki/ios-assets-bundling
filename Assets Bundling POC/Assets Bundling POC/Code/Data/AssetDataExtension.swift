//
//  AssetDataExtension.swift
//  Assets Bundling POC
//

import Foundation
import Assets_Bundling_POC_Commons

extension AssetData {

    func makeRowViewData() -> AssetListViewRowData {
        AssetListViewRowData(
            id: id,
            state: state.toViewState(),
            name: name
        )
    }
}

extension AssetData.State {

    func toViewState() -> AssetListViewRowData.State {
        switch self {
        case .notLoaded:
            .notLoaded
        case let .loading(progress):
            .loading(progress)
        case .loaded:
            .loaded
        case .failed:
            .failed
        }
    }
}
