//
//  AssetsListViewModel.swift
//  Assets Bundling POC
//

import Foundation
import Observation

@Observable final class AssetsListViewModel {
    private(set) var viewState: AssetsListViewState

    @ObservationIgnored
    private var assets = [AssetData]()

    init() {
        // TODO: Read from local storage.
        assets = [
            AssetData(
                id: "asset1",
                name: "Asset 1",
                localPath: "",
                remoteURL: URL(string: "https://wp.pl")!
            ),
            AssetData(
                id: "asset2",
                name: "Asset 2",
                localPath: "",
                remoteURL: URL(string: "https://wp.pl")!
            ),
            AssetData(
                id: "asset3",
                name: "Asset 3",
                localPath: "",
                remoteURL: URL(string: "https://wp.pl")!
            )
        ]
        // TODO: Get info about asset loading state:
        viewState = AssetsListViewState(assets: assets.map { $0.makeViewData() })
    }

    @MainActor func onViewAppeared() {}

    func calculateNavigationDesitination(for assetID: String) -> NavigationRoute? {
        guard let data = assets.filter({ $0.id == assetID }).first else {
            return nil
        }

        return .assetDetails(data)
    }

    func onAssetSelected(_ assetID: String) {}
}

private extension AssetsListViewModel {

    func composeViewState() {}
}
