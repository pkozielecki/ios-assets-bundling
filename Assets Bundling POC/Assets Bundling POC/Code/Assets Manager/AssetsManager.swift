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
}

protocol AssetsManager: AssetsProvider {
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
        fileManager: AssetFilesManager = LiveAssetFilesManager()
    ) {
        self.manifestPath = manifestPath
        self.networkModule = networkModule
        self.downloadManager = downloadManager
        self.storage = storage
        self.fileManager = fileManager

        super.init()

        self.downloadManager.delegate = self
    }

    @MainActor func start() async {
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
}

extension LiveAssetsManager: BADownloadManagerDelegate {

    func downloadDidBegin(_ download: BADownload) {
        Logger.app.warning("APP - Did begin download: \(download.identifier)")
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
        updateAssetState(assetID: download.identifier, state: .loading(Int(progress * 100)))
        Logger.app.info("APP - Download \(download.identifier) progress: \(progress)")
    }

    func download(_ download: BADownload, failedWithError error: Error) {
        Logger.app.error("APP - Download \(download.identifier) did fail: \(error)")
        updateAssetState(assetID: download.identifier, state: .failed)
    }

    func download(_ download: BADownload, finishedWithFileURL fileURL: URL) {
        // TODO: Move file to the correct location.
//        do {
//            _ = try FileManager.default.replaceItemAt(session.fileURL, withItemAt: fileURL)
//        } catch {
//            Logger.app.error("Failed to move downloaded file: \(error)")
//            return
//        }

//        Task { @MainActor in
//            session.state = .downloaded
//            await session.fetchThumbnail()
//        }
        updateAssetState(assetID: download.identifier, state: .loaded)
        Logger.app.info("APP - Download complete: \(download.identifier)")
    }
}

private extension LiveAssetsManager {

    func readAssetsFromStorage() async -> [AssetData] {
        do {
            let packages: [AssetData]? = try await storage.getValue(forKey: StorageKeys.assets.rawValue)
            return packages ?? []
        } catch {
            Logger.app.error("APP - Failed to read assets from storage: \(error)")
            return []
        }
    }

    func writeAssetsToStorage(_ assets: [AssetData]) async {
        do {
            try await storage.setValue(assets, forKey: StorageKeys.assets.rawValue)
        } catch {
            Logger.app.error("APP - Failed to write assets to storage: \(error)")
        }
    }

    func fetchManifestPackages() async -> [GetManifestResponse.Package] {
        let request = GetManifestRequest(path: manifestPath)
        do {
            let response = try await networkModule.performAndDecode(request: request, responseType: GetManifestResponse.self)
            return response.packages
        } catch {
            Logger.app.error("APP - Manifest Error: \(error)")
            return []
        }
    }

    func composeAssetsToDownload(storedAssets: [AssetData], manifestPackages: [GetManifestResponse.Package]) -> [AssetData] {
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
        guard let url = package.remoteURL else {
            Logger.app.error("APP - Invalid URL for package \(package.id)")
            return
        }

        // TODO: Rewrite into async/await.
        downloadManager.withExclusiveControl { [weak self] lockAcquired, error in
            guard let self, lockAcquired else {
                Logger.app.error("APP - Failed to acquire lock or object deallocated: \(error)")
                return
            }

            do {
                let download: BADownload
                let currentDownloads = try downloadManager.fetchCurrentDownloads()

                if let existingDownload = currentDownloads.first(where: { $0.identifier == package.id }) {
                    download = existingDownload
                } else {
                    download = composeAssetDownload(asset: package, url: url)
                }

                guard download.state != .failed else {
                    Logger.app.warning("APP - Download for session \(package.id) is in the failed state.")
                    return
                }

                try downloadManager.startForegroundDownload(download)
            } catch {
                Logger.app.warning("APP - Failed to start download for session \(package.id): \(error.localizedDescription)")
            }
        }
    }

    func isAlreadyDownloaded(package: GetManifestResponse.Package, storedAssets: [AssetData]) -> Bool {
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
        assets = assets.map {
            guard $0.id == assetID else { return $0 }
            return $0.changingState(state)
        }
        Task {
            await writeAssetsToStorage(assets)
        }
        currentAssetsSubject.send(assets)
    }

    func composeAssetDownload(asset: AssetData, url: URL) -> BAURLDownload {
        BAURLDownload(
            identifier: asset.id,
            request: URLRequest(url: url),
            essential: false,
            fileSize: Int(asset.size),
            applicationGroupIdentifier: AppConfiguration.appBundleGroup,
            priority: .default
        )
    }
}
