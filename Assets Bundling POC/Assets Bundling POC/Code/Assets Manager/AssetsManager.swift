//
//  AssetsManager.swift
//  Assets Bundling POC
//

import Foundation
import NgNetworkModuleCore
import ConcurrentNgNetworkModule
import BackgroundAssets
import OSLog

protocol AssetsManager {}

// TODO: Can this NOT implement NSObject?
final class LiveAssetsManager: NSObject, AssetsManager {
    private let manifestPath: String
    private let networkModule: NetworkModule
    private let downloadManager: BADownloadManager // TODO: Wrap in protocol

    private var manifestPackages: [GetManifestResponse.Package] = []
    private var downloadedPackages: [GetManifestResponse.Package] = []

    init(
        manifestPath: String,
        networkModule: NetworkModule,
        downloadManager: BADownloadManager = .shared
    ) {
        self.manifestPath = manifestPath
        self.networkModule = networkModule
        self.downloadManager = downloadManager

        super.init()

        self.downloadManager.delegate = self

        Task { @MainActor in
            await refreshManifest()
            await startDownloads()
        }
    }
}

private extension LiveAssetsManager {

    func refreshManifest() async {
        let request = GetManifestRequest(path: manifestPath)
        do {
            let response = try await networkModule.performAndDecode(request: request, responseType: GetManifestResponse.self)
            manifestPackages = response.packages
            // TODO: Check which packages are already downloaded.
            // TODO: Restore packages from storage.
            // TODO: Start downloading packages.
        } catch {
            Logger.app.error("APP - Manifest Error: \(error)")
        }
    }

    func startDownloads() async {
        manifestPackages.forEach { download(package: $0) }
    }

    func download(package: GetManifestResponse.Package) {
        guard let url = package.url else {
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
                    download = composeAssetDownload(package: package, url: url)
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

    func composeAssetDownload(package: GetManifestResponse.Package, url: URL) -> BAURLDownload {
        BAURLDownload(
            identifier: package.id,
            request: URLRequest(url: url),
            essential: false,
            fileSize: Int(package.size),
            applicationGroupIdentifier: AppConfiguration.appBundleGroup,
            priority: .default
        )
    }
}

extension LiveAssetsManager: BADownloadManagerDelegate {

    func downloadDidBegin(_ download: BADownload) {
        Logger.app.warning("APP - Did begin download: \(download.identifier)")
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
        Logger.app.info("APP - Download \(download.identifier) progress: \(progress)")
    }

    func download(_ download: BADownload, failedWithError error: Error) {
        Logger.app.error("APP - Download \(download.identifier) did fail: \(error)")
    }

    func download(_ download: BADownload, finishedWithFileURL fileURL: URL) {
        // TODO: Move file to the correct location.
        Logger.app.info("APP - Download complete: \(download.identifier)")
    }
}
