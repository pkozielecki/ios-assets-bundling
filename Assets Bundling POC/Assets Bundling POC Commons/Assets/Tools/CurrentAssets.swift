import Foundation

public struct CurrentAssets {
    public let assetsToDownload: [AssetData]
    public let readyAssets: [AssetData]
    public let assetsToTransfer: [AssetData]
}

extension CurrentAssets {

    public var allAssets: [AssetData] {
        assetsToDownload + readyAssets + assetsToTransfer
    }
}
