//
//  PreviewViewModels.swift
//  Assets Bundling POC
//

import SwiftUI

final class PreviewAssetDetailsViewModel: AssetDetailsViewModel {
    var viewState: AssetDetailsViewState = .loading

    func onViewAppeared() async {}
}

final class PreviewAssetListViewModel: AssetsListViewModel {
    var viewState: AssetsListViewState = .loading

    func onViewAppeared() {}
    func onAssetSelected(_ assetID: String) {}
    func onClearAssetsRequested() {}
    func onReloadRequested() {}
}
