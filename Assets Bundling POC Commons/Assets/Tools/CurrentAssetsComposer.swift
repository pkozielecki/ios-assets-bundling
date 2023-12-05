//
//  CurrentAssetsComposer.swift
//  Assets Bundling POC
//

import Foundation

public protocol CurrentAssetsComposer {
    func compose(
        storedAssets: [AssetData],
        manifestPackages: [ManifestPackage],
        essentialDownloadsPermitted: Bool
    ) -> CurrentAssets
}

public struct LiveCurrentAssetsComposer: CurrentAssetsComposer {

    public init() {}

    public func compose(
        storedAssets: [AssetData],
        manifestPackages: [ManifestPackage],
        essentialDownloadsPermitted: Bool
    ) -> CurrentAssets {
        let assetsToTransfer = storedAssets.filter { $0.state == .toBeTransferred }
        let assetsToDownload = composeAssetsToDownload(
            storedAssets: storedAssets,
            manifestPackages: manifestPackages,
            essentialDownloadsPermitted: essentialDownloadsPermitted
        )
        let manifestPackagesIDs = manifestPackages.map { $0.id }
        let readyAssets = composeReadyAssets(
            storedAssets: storedAssets,
            assetsToDownload: assetsToDownload,
            assetsToTransfer: assetsToTransfer,
            manifestPackageIDs: manifestPackagesIDs
        )
        return CurrentAssets(
            assetsToDownload: assetsToDownload,
            readyAssets: readyAssets,
            assetsToTransfer: assetsToTransfer
        )
    }
}

private extension LiveCurrentAssetsComposer {

    func composeAssetsToDownload(
        storedAssets: [AssetData],
        manifestPackages: [ManifestPackage],
        essentialDownloadsPermitted: Bool
    ) -> [AssetData] {
        manifestPackages.filter {
            !isAlreadyDownloaded(package: $0, storedAssets: storedAssets)
        }.map {
            AssetData(from: $0, essentialDownloadsPermitted: essentialDownloadsPermitted)
        }
    }

    func composeReadyAssets(
        storedAssets: [AssetData],
        assetsToDownload: [AssetData],
        assetsToTransfer: [AssetData],
        manifestPackageIDs: [String]
    ) -> [AssetData] {
        storedAssets.filter {
            isReadyAndValid(
                asset: $0,
                assetsToDownload: assetsToDownload,
                assetsToTransfer: assetsToTransfer,
                manifestPackageIDs: manifestPackageIDs
            )
        }
    }

    func isAlreadyDownloaded(package: ManifestPackage, storedAssets: [AssetData]) -> Bool {
        // Discussion: An asset is downloaded only when stored & was not modified since last download.
        storedAssets.contains {
            $0.id == package.id && $0.state.isDownloadCompleted && $0.createdDate == package.createdDate
        }
    }

    func isReadyAndValid(
        asset: AssetData,
        assetsToDownload: [AssetData],
        assetsToTransfer: [AssetData],
        manifestPackageIDs: [String]
    ) -> Bool {
        // Discussion: An asset is already downloaded and transferred to a permanent location.
        manifestPackageIDs.contains(asset.id)
            && !assetsToDownload.contains { $0.id == asset.id }
            && !assetsToTransfer.contains { $0.id == asset.id }
    }
}
