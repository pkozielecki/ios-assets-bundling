//
//  AssetData.swift
//  Assets Bundling POC
//

import Foundation

struct AssetData: Equatable, Hashable, Identifiable {
    let id: String
    let name: String
    let localPath: String
    let remoteURL: URL
}

extension AssetData {

    func makeViewData(state: AssetListViewRowData.State = .notLoaded) -> AssetListViewRowData {
        AssetListViewRowData(
            id: id,
            state: state,
            name: name
        )
    }
}
