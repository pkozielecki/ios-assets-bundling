//
//  AssetsListViewModel.swift
//  Assets Bundling POC
//

import Foundation
import Observation
import Combine

@Observable final class AssetsListViewModel {
    private let assetsProvider: AssetsProvider
    private(set) var viewState: AssetsListViewState = .init(assetsListRows: [])
    private var cancellables = Set<AnyCancellable>()

    @ObservationIgnored
    private var assets = [AssetData]()

    init(assetsProvider: AssetsProvider) {
        self.assetsProvider = assetsProvider
        subscribeToAssetsProvider()
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

    func subscribeToAssetsProvider() {
        assetsProvider.currentAssets.sink { [weak self] assets in
            let assetListRows = assets.map { $0.makeRowViewData() }
            self?.viewState = AssetsListViewState(assetsListRows: assetListRows)
        }
        .store(in: &cancellables)
    }
}
