//
//  AssetData.swift
//  Assets Bundling POC
//

import Foundation

struct AssetData: Equatable, Hashable, Codable {
    let id: String
    let name: String
    let state: State
    let created: Double
    let size: Int64
    let remoteURL: URL?
}

extension AssetData {

    enum State: Codable, Equatable, Hashable {
        case notLoaded
        case loading(Int)
        case loaded
        case failed
    }

    init(from package: GetManifestResponse.Package) {
        self.init(
            id: package.id,
            name: package.name,
            state: .notLoaded, // Discussion: Package download is not started yet.
            created: package.created,
            size: package.size,
            remoteURL: package.url
        )
    }

    var createdDate: Date {
        Date(timeIntervalSince1970: created)
    }

    func changingState(_ newState: State) -> AssetData {
        AssetData(
            id: id,
            name: name,
            state: newState,
            created: created,
            size: size,
            remoteURL: remoteURL
        )
    }

    // TODO: Compose path to asset:
//    var path: URL {
//
//    }

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
