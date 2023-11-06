//
//  AssetsListViewModel.swift
//  Assets Bundling POC
//

import Foundation
import Observation

@Observable final class AssetsListViewModel {
    private(set) var viewState: AssetsListViewState = .default

    init(

    ) {}

    @MainActor func onViewAppeared() {}
}

private extension AssetsListViewModel {

    func composeViewState() {}
}

private extension AssetsListViewState {

    static var `default`: AssetsListViewState {
        AssetsListViewState(
            assets: [
                AssetListViewRowData(
                    id: UUID(),
                    state: .notLoaded,
                    name: "Asset 1"
                ),
                AssetListViewRowData(
                    id: UUID(),
                    state: .loading,
                    name: "Asset 2"
                ),
                AssetListViewRowData(
                    id: UUID(),
                    state: .loaded,
                    name: "Asset 3"
                )
            ]
        )
    }
}
