//
//  AssetsManager.swift
//  Assets Bundling POC
//

import Foundation
import NgNetworkModuleCore
import ConcurrentNgNetworkModule
import BackgroundAssets
import OSLog
import Assets_Bundling_POC_Commons
import Combine

protocol AssetsProvider: AnyObject {
    var currentAssets: AnyPublisher<[AssetData], Never> { get }
    func reloadAssets() async
}

protocol AssetStateManager: AnyObject {
    func updateAssetState(assetID: String, newState: AssetData.State)
}

protocol AssetsCleaner: AnyObject {
    func clearAll() async
    func clearCache(for assetID: String) async
}

protocol AssetsManager: AssetsProvider, AssetsCleaner, AssetStateManager {
    func start() async
}

// TODO: Can this NOT implement NSObject?
final class LiveAssetsManager: NSObject, AssetsManager {
    var currentAssets: AnyPublisher<[AssetData], Never> {
        currentAssetsSubject.eraseToAnyPublisher()
    }

    private let manifestPath: String
    private let networkModule: NetworkModule
    private let currentAssetsComposer: CurrentAssetsComposer
    private let downloadManager: BAWrapper
    private let storage: LocalStorage
    private let fileManager: AssetFilesManager

    private var assets: [AssetData] = []
    private var currentAssetsSubject: CurrentValueSubject<[AssetData], Never> = .init([])

    init(
        manifestPath: String,
        networkModule: NetworkModule,
        currentAssetsComposer: CurrentAssetsComposer = LiveCurrentAssetsComposer(),
        downloadManager: BAWrapper = BADownloadManager.shared,
        storage: LocalStorage = UserDefaults(suiteName: AppConfiguration.appBundleGroup) ?? .standard,
        fileManager: AssetFilesManager = FileManager.default
    ) {
        self.manifestPath = manifestPath
        self.networkModule = networkModule
        self.currentAssetsComposer = currentAssetsComposer
        self.downloadManager = downloadManager
        self.storage = storage
        self.fileManager = fileManager

        super.init()

        self.downloadManager.delegate = self
    }

    func start() async {
        fileManager.setUp()
        await reloadAssets()
    }

    func reloadAssets() async {
        let currentAssets = await getCurrentAssets()
        assets = currentAssets.allAssets
        storage.writeAssetsToStorage(assets)

        transfer(currentAssets.assetsToTransfer)
        startDownloading(assets: currentAssets.assetsToDownload)

        currentAssetsSubject.send(assets)
    }

    func clearCache(for assetID: String) async {
        try? fileManager.removeItem(at: fileManager.sharedStorageAssetFile(for: assetID))
        try? fileManager.removeItem(at: fileManager.permanentStorageAssetFile(for: assetID))
        try? fileManager.removeItem(at: fileManager.unpackedAssetFolder(for: assetID))
    }

    func clearAll() {
        try? storage.removeValue(forKey: StorageKeys.assets.rawValue)

        try? fileManager.removeItem(at: fileManager.sharedAssetsContainer)
        try? fileManager.removeItem(at: fileManager.permanentAssetsContainer)
        fileManager.setUp()

        assets = []
        storeAndNotify(assets: assets)
    }

    func updateAssetState(assetID: String, newState: AssetData.State) {
        let updatedAssets = assets.updateState(assetID: assetID, newState: newState)
        storeAndNotify(assets: updatedAssets)
        assets = updatedAssets
    }
}

extension LiveAssetsManager: BADownloadManagerDelegate {

    func downloadDidBegin(_ download: BADownload) {
        Logger.app.log("📱🟢Did begin download: \(download.identifier, privacy: .public)")
        updateAssetState(assetID: download.identifier, newState: .loading(0))
    }

    func download(
        _ download: BADownload,
        didWriteBytes bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite totalExpectedBytes: Int64
    ) {
        guard type(of: download) == BAURLDownload.self else {
            return
        }

        let progress = Double(totalBytesWritten) / Double(totalExpectedBytes)
        updateAssetState(assetID: download.identifier, newState: .loading(progress))
        Logger.app.log("📱🟢Download \(download.identifier, privacy: .public) progress: \(progress, privacy: .public)")
    }

    func download(_ download: BADownload, failedWithError error: Error) {
        Logger.app.error("APP - Download \(download.identifier) did fail: \(error)")
        updateAssetState(assetID: download.identifier, newState: .failed)
    }

    func download(_ download: BADownload, finishedWithFileURL fileURL: URL) {
        Logger.app.log("📱🟢Download complete: \(download.identifier, privacy: .public)")
        let targetURL = fileManager.permanentStorageAssetFile(for: download.identifier)
        do {
            _ = try fileManager.replaceItemAt(targetURL, withItemAt: fileURL, backupItemName: nil, options: [])
            Logger.app.log("📱🟢File transferred: \(targetURL, privacy: .public)")
            updateAssetState(assetID: download.identifier, newState: .loaded)
        } catch {
            Logger.app.error("📱🔴Failed to move downloaded file \(fileURL.absoluteString, privacy: .public) \(targetURL.absoluteString, privacy: .public), error: \(error, privacy: .public)")
            updateAssetState(assetID: download.identifier, newState: .failed)
        }
    }
}

private extension LiveAssetsManager {

    func getCurrentAssets() async -> CurrentAssets {
        let storedAssets = storage.readAssetsFromStorage()
        let manifestAssets = await fetchManifestPackages()
        return currentAssetsComposer.compose(
                storedAssets: storedAssets,
                manifestPackages: manifestAssets,
                essentialDownloadsPermitted: false
        )
    }

    func transfer(_ assetsToTransfer: [AssetData]) {
        assetsToTransfer.forEach { asset in
            let from = fileManager.sharedStorageAssetFile(for: asset.id)
            let to = fileManager.permanentStorageAssetFile(for: asset.id)
            do {
                try fileManager.moveItem(at: from, to: to)
                updateAssetState(assetID: asset.id, newState: .loaded)
            } catch {
                Logger.app.error("📱🔴Failed to move file: \(asset.id)")
                updateAssetState(assetID: asset.id, newState: .failed)
            }
        }
    }

    func fetchManifestPackages() async -> [ManifestPackage] {
        let request = GetManifestRequest(path: manifestPath)
        do {
            let response = try await networkModule.performAndDecode(request: request, responseType: GetManifestResponse.self)
            return response.packages
        } catch {
            Logger.app.error("📱🔴Manifest Error: \(error, privacy: .public)")
            return []
        }
    }

    func startDownloading(assets: [AssetData]) {
        downloadManager.withExclusiveControl { [weak self] lockAcquired, error in
            guard let self, lockAcquired else {
                Logger.app.error("📱🔴Failed to acquire lock or object deallocated: \(error, privacy: .public)")
                return
            }

            assets.forEach(download)
        }
    }

    func download(package: AssetData) {
        do {
            let download: BADownload
            let currentDownloads = try downloadManager.fetchCurrentDownloads()

            if let existingDownload = currentDownloads.first(where: { $0.identifier == package.id }) {
                download = existingDownload
            } else {
                download = package.baDownload
            }

            guard download.state != .failed else {
                Logger.app.warning("📱🟠Download for session \(package.id, privacy: .public) is in the failed state.")
                return
            }

            try downloadManager.startForegroundDownload(download)
        } catch {
            Logger.app.warning("📱🟠Failed to start download for session \(package.id, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
    }

    func storeAndNotify(assets: [AssetData]) {
        storage.writeAssetsToStorage(assets)
        currentAssetsSubject.send(assets)
    }
}
