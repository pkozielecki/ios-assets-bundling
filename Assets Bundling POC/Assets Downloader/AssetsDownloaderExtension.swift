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
    private var packages: [GetManifestResponse.Package] = []

    required init() {
        // TODO: Make .debug() visible in the console.
        Logger.ext.debug("Extension initialized")
    }

    func downloads(for request: BAContentRequest, manifestURL: URL, extensionInfo: BAAppExtensionInfo) -> Set<BADownload> {
        // Discussion: At this moment, the manifest is already downloaded and stored locally.
        // TODO: Change to debug() or info().
        Logger.ext.warning("Loading manifest \(manifestURL.absoluteString, privacy: .public)")
        guard let data = try? Data(contentsOf: manifestURL) else {
            Logger.ext.error("Loading manifest failed")
            return []
        }

        let manifest = try? JSONDecoder().decode(GetManifestResponse.self, from: data)
        packages = manifest?.packages ?? []
        Logger.ext.warning("Manifest loaded, packages: \(packages.count, privacy: .public)")

        // TODO: load packages from storage for cross-reference.
        return Set(composeDownloads(from: packages))
    }

    func backgroundDownload(_ failedDownload: BADownload, failedWithError error: Error) {
        // TODO: Change to debug() or info().
        Logger.ext.error("Loading failed: \(failedDownload.identifier, privacy: .public), error: \(error, privacy: .public)")
    }

    func backgroundDownload(_ finishedDownload: BADownload, finishedWithFileURL fileURL: URL) {
        Logger.ext.warning("Loading success: \(finishedDownload.identifier, privacy: .public), error: \(fileURL.absoluteString, privacy: .public)")
    }

    func backgroundDownload(
        _ download: BADownload,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        (.performDefaultHandling, nil)
    }
}

private extension AssetsDownloaderExtension {

    func composeDownloads(from packages: [GetManifestResponse.Package]) -> [BAURLDownload] {
        packages.map { package in
            BAURLDownload(
                identifier: package.id,
                request: URLRequest(url: package.url!),
                essential: false, // TODO: Change when there are essential downloads.
                fileSize: package.size,
                applicationGroupIdentifier: AppConfiguration.appBundleGroup,
                priority: .default
            )
        }
    }
}
