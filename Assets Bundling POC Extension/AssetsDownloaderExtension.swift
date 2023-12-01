//
//  AssetsDownloaderExtension.swift
//  Assets Bundling POC
//

import Foundation
import ExtensionFoundation
import Assets_Bundling_POC_Commons
import BackgroundAssets
import OSLog

@main
class AssetsDownloaderExtension: BADownloaderExtension {
    let currentAssetsComposer: CurrentAssetsComposer
    let storage: LocalStorage
    let fileManager: AssetFilesManager
    let downloadManager: BAWrapper
    private var assets: [AssetData] = []

    required init() {
        currentAssetsComposer = LiveCurrentAssetsComposer()
        storage = UserDefaults(suiteName: AppConfiguration.appBundleGroup) ?? .standard
        fileManager = FileManager.default
        downloadManager = BADownloadManager.shared

        fileManager.setUp()
        Logger.ext.log("🤖🟢Extension initialized")
    }

    func downloads(for request: BAContentRequest, manifestURL: URL, extensionInfo: BAAppExtensionInfo) -> Set<BADownload> {
        // Discussion: At this moment, the manifest is already downloaded and stored locally.
        let essentialDownloadsPermitted = request == .install || request == .update
        let manifestPackages = manifestURL.getManifestPackage()
        let storedAssets = storage.readAssetsFromStorage()
        let currentAssets = currentAssetsComposer.compose(
                storedAssets: storedAssets,
                manifestPackages: manifestPackages,
                essentialDownloadsPermitted: essentialDownloadsPermitted
        )

        assets = currentAssets.allAssets

        Logger.ext.log("🤖🟢Assets to download: \(currentAssets.assetsToDownload.map { $0.id }, privacy: .public)")
        return Set(currentAssets.assetsToDownload.map { $0.baDownload })
    }

    func backgroundDownload(_ finishedDownload: BADownload, finishedWithFileURL fileURL: URL) {
        Logger.ext.log("🤖🟢Loading success: \(finishedDownload.identifier, privacy: .public)")
        let ephemeralFileURL = fileManager.ephemeralStorageAssetFile(for: finishedDownload.identifier)
        _ = try? fileManager.replaceItemAt(ephemeralFileURL, withItemAt: fileURL, backupItemName: nil, options: [])

        // Discussion: Need to assert exclusive control as the app might be modifying assets state at the same time.
        downloadManager.withExclusiveControl { [weak self] lockAcquired, error in
            guard let self, lockAcquired else {
                Logger.ext.error("🤖🔴Failed to acquire lock or object deallocated: \(error, privacy: .public)")
                return
            }

            moveDownloadedPackage(finishedDownload: finishedDownload, tempFileURL: ephemeralFileURL)
        }
    }

    func backgroundDownload(_ failedDownload: BADownload, failedWithError error: Error) {
        // Discussion: If the manifest fails to download, it'll also be handled here.
        guard type(of: failedDownload) == BAURLDownload.self else {
            Logger.ext.warning("Download of unsupported type failed: \(failedDownload.identifier). \(error)")
            return
        }
        
        if failedDownload.isEssential {
            Logger.ext.log("🤖🟠Rescheduling failed download: \(failedDownload.identifier, privacy: .public), error: \(error, privacy: .public)")
            rescheduleFailedEssentialDownload(failedDownload: failedDownload)
        } else {
            // Discussion: Need to assert exclusive control as the app might be modifying assets state at the same time.
            downloadManager.withExclusiveControl { [weak self] lockAcquired, error in
                guard let self, lockAcquired else {
                    Logger.ext.error("🤖🔴Failed to acquire lock or object deallocated: \(error, privacy: .public)")
                    return
                }

                Logger.ext.log("🤖🔴Loading failed: \(failedDownload.identifier, privacy: .public), error: \(error, privacy: .public)")
                updateAssetState(assetID: failedDownload.identifier, newState: .failed)
            }
        }
    }

    func backgroundDownload(
        _ download: BADownload,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        (.performDefaultHandling, nil)
    }
}

private extension AssetsDownloaderExtension {

    func moveDownloadedPackage(finishedDownload: BADownload, tempFileURL: URL) {
        let targetURL = fileManager.sharedStorageAssetFile(for: finishedDownload.identifier)
        do {
            _ = try fileManager.replaceItemAt(targetURL, withItemAt: tempFileURL, backupItemName: nil, options: [])
            updateAssetState(assetID: finishedDownload.identifier, newState: .toBeTransferred)
            Logger.ext.log("🤖🟢File transferred: \(targetURL, privacy: .public)")
        } catch {
            // Discussion: If the file failed to move, it'll have to be re-downloaded.
            Logger.ext.error("🤖🔴Failed to move downloaded file \(tempFileURL.absoluteString, privacy: .public) \(targetURL.absoluteString, privacy: .public), error: \(error, privacy: .public)")
            return
        }
    }

    func rescheduleFailedEssentialDownload(failedDownload: BADownload) {
        do {
            let optionalDownload = failedDownload.removingEssential()
            try downloadManager.scheduleDownload(optionalDownload)
        } catch {
            Logger.ext.warning("Failed to reschedule download \(failedDownload.identifier). \(error)")
        }
    }

    func updateAssetState(assetID: String, newState: AssetData.State) {
        let updatedAssets = assets.updateState(assetID: assetID, newState: newState)
        storage.writeAssetsToStorage(updatedAssets)
        assets = updatedAssets
    }
}
