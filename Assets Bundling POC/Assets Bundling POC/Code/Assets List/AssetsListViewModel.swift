//
//  AssetsListViewModel.swift
//  Assets Bundling POC
//

import Foundation
import Observation
import Combine

@Observable final class AssetsListViewModel {
    private let assetsProvider: AssetsProvider
    private let assetsCleaner: AssetsCleaner
    private let router: NavigationRouter

    private(set) var viewState: AssetsListViewState = .loading

    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    @ObservationIgnored private var assets = [AssetData]()

    init(
        router: NavigationRouter,
        assetsProvider: AssetsProvider,
        assetsCleaner: AssetsCleaner
    ) {
        self.router = router
        self.assetsProvider = assetsProvider
        self.assetsCleaner = assetsCleaner
        subscribeToAssetsProvider()
    }

    @MainActor func onViewAppeared() {}

    func onAssetSelected(_ assetID: String) {
        guard let asset = assets.filter({ $0.id == assetID }).first else {
            return
        }

        router.push(route: .assetDetails(asset))
    }

    func onClearAssetsRequested() {
        Task { @MainActor [weak self] in
            self?.viewState = .noAssets
            await self?.assetsCleaner.clear()
        }
    }

    func onReloadRequested() {
        Task { @MainActor [weak self] in
            self?.viewState = .loading
            await self?.assetsProvider.reloadAssets()
        }
    }
}

private extension AssetsListViewModel {

    func subscribeToAssetsProvider() {
        assetsProvider.currentAssets
            .receive(on: RunLoop.main)
            .dropFirst()
            .sink { [weak self] assets in
                self?.assets = assets
                let assetListRows = assets.map { $0.makeRowViewData() }
                self?.viewState = assetListRows.isEmpty ? .noAssets : .loaded(assetsListRows: assetListRows)
            }
            .store(in: &cancellables)
    }
}
