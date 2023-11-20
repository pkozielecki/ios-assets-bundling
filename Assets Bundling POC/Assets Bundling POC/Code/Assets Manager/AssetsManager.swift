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

protocol AssetsCleaner: AnyObject {
    func clear() async
}

protocol AssetsManager: AssetsProvider, AssetsCleaner {
    func start() async
}

// TODO: Can this NOT implement NSObject?
final class LiveAssetsManager: NSObject, AssetsManager {
    var currentAssets: AnyPublisher<[AssetData], Never> {
        currentAssetsSubject.eraseToAnyPublisher()
    }

    private let manifestPath: String
    private let networkModule: NetworkModule
    private let downloadManager: BADownloadManager // TODO: Wrap in protocol
    private let storage: LocalStorage
    private let fileManager: AssetFilesManager

    private var assets: [AssetData] = []
    private var currentAssetsSubject: CurrentValueSubject<[AssetData], Never> = .init([])

    init(
        manifestPath: String,
        networkModule: NetworkModule,
        downloadManager: BADownloadManager = .shared,
        storage: LocalStorage = UserDefaults(suiteName: AppConfiguration.appBundleGroup) ?? .standard,
        fileManager: AssetFilesManager = FileManager.default
    ) {
        self.manifestPath = manifestPath
        self.networkModule = networkModule
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
        let storedAssets = await readAssetsFromStorage()
        let manifestAssets = await fetchManifestPackages()
        let assetsToDownload = composeAssetsToDownload(storedAssets: storedAssets, manifestPackages: manifestAssets)
        let downloadedAssets = composeDownloadedAssets(
            storedAssets: storedAssets,
            assetsToDownload: assetsToDownload,
            manifestPackageIDs: manifestAssets.map { $0.id }
        )

        assets = downloadedAssets + assetsToDownload
        currentAssetsSubject.send(assets)
        await writeAssetsToStorage(assets)
        assetsToDownload.forEach(download)
    }

    func clear() async {
        try? await storage.removeValue(forKey: StorageKeys.assets.rawValue)
        assets.forEach {
            try? fileManager.removeItem(at: fileManager.assetFileURL(for: $0.id))
        }
        assets = []
        storeAndNotify(assets: assets)
    }
}

extension LiveAssetsManager: BADownloadManagerDelegate {

    func downloadDidBegin(_ download: BADownload) {
        Logger.app.info("📱🟢Did begin download: \(download.identifier)")
        updateAssetState(assetID: download.identifier, state: .loading(0))
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
        updateAssetState(assetID: download.identifier, state: .loading(progress))
        Logger.app.info("📱🟢Download \(download.identifier) progress: \(progress)")
    }

    func download(_ download: BADownload, failedWithError error: Error) {
        Logger.app.error("APP - Download \(download.identifier) did fail: \(error)")
        updateAssetState(assetID: download.identifier, state: .failed)
    }

    func download(_ download: BADownload, finishedWithFileURL fileURL: URL) {
        Logger.app.info("📱🟢Download complete: \(download.identifier)")
        let targetURL = fileManager.assetFileURL(for: download.identifier)
        do {
            _ = try fileManager.replaceItemAt(targetURL, withItemAt: fileURL, backupItemName: nil, options: [])
            Logger.app.info("📱🟢File transferred: \(targetURL)")
            updateAssetState(assetID: download.identifier, state: .loaded)
        } catch {
            Logger.app.error("📱🔴Failed to move downloaded file \(fileURL.absoluteString) \(targetURL.absoluteString), error: \(error)")
            updateAssetState(assetID: download.identifier, state: .failed)
        }
    }
}

private extension LiveAssetsManager {

    func readAssetsFromStorage() async -> [AssetData] {
        do {
            let packages: [AssetData]? = try await storage.getValue(forKey: StorageKeys.assets.rawValue)
            return packages ?? []
        } catch {
            Logger.app.error("📱🔴Failed to read assets from storage: \(error)")
            return []
        }
    }

    func writeAssetsToStorage(_ assets: [AssetData]) async {
        do {
            try await storage.setValue(assets, forKey: StorageKeys.assets.rawValue)
        } catch {
            Logger.app.error("📱🔴Failed to write assets to storage: \(error)")
        }
    }

    func fetchManifestPackages() async -> [ManifestPackage] {
        let request = GetManifestRequest(path: manifestPath)
        do {
            let response = try await networkModule.performAndDecode(request: request, responseType: GetManifestResponse.self)
            return response.packages
        } catch {
            Logger.app.error("📱🔴Manifest Error: \(error)")
            return []
        }
    }

    func composeAssetsToDownload(storedAssets: [AssetData], manifestPackages: [ManifestPackage]) -> [AssetData] {
        manifestPackages.filter {
            !isAlreadyDownloaded(package: $0, storedAssets: storedAssets)
        }.map {
            AssetData(from: $0)
        }
    }

    func composeDownloadedAssets(storedAssets: [AssetData], assetsToDownload: [AssetData], manifestPackageIDs: [String]) -> [AssetData] {
        storedAssets.filter {
            isDownloadedAndValid(asset: $0, assetsToDownload: assetsToDownload, manifestPackageIDs: manifestPackageIDs)
        }
    }

    func download(package: AssetData) {
        // TODO: Rewrite into async/await.
        downloadManager.withExclusiveControl { [weak self] lockAcquired, error in
            guard let self, lockAcquired else {
                Logger.app.error("📱🔴Failed to acquire lock or object deallocated: \(error)")
                return
            }

            do {
                let download: BADownload
                let currentDownloads = try downloadManager.fetchCurrentDownloads()

                if let existingDownload = currentDownloads.first(where: { $0.identifier == package.id }) {
                    download = existingDownload
                } else {
                    download = package.baDownload
                }

                guard download.state != .failed else {
                    Logger.app.warning("📱🟠Download for session \(package.id) is in the failed state.")
                    return
                }

                try downloadManager.startForegroundDownload(download)
            } catch {
                Logger.app.warning("📱🟠Failed to start download for session \(package.id): \(error.localizedDescription)")
            }
        }
    }

    func isAlreadyDownloaded(package: ManifestPackage, storedAssets: [AssetData]) -> Bool {
        // Discussion: An asset is downloaded only when stored & was not modified since last download.
        storedAssets.contains {
            $0.id == package.id && $0.state == .loaded && $0.createdDate == package.createdDate
        }
    }

    func isDownloadedAndValid(asset: AssetData, assetsToDownload: [AssetData], manifestPackageIDs: [String]) -> Bool {
        // Discussion: An asset is already downloaded and not marked to be re-downloaded.
        manifestPackageIDs.contains(asset.id) && !assetsToDownload.contains { $0.id == asset.id }
    }

    func updateAssetState(assetID: String, state: AssetData.State) {
        let assets = assets.map {
            guard $0.id == assetID else { return $0 }
            return $0.changingState(state)
        }
        storeAndNotify(assets: assets)
        self.assets = assets
    }

    func storeAndNotify(assets: [AssetData]) {
        Task {
            await writeAssetsToStorage(assets)
        }
        currentAssetsSubject.send(assets)
    }
}
