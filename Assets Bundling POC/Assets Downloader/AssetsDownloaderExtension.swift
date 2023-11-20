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
    private var packages: [ManifestPackage] = []

    required init() {
        Logger.ext.log("🤖🟢Extension initialized")
    }

    func downloads(for request: BAContentRequest, manifestURL: URL, extensionInfo: BAAppExtensionInfo) -> Set<BADownload> {
        // Discussion: At this moment, the manifest is already downloaded and stored locally.

        // TODO: Extract 1) checking downloaded assets 2) composing downloads to Commons.

        Logger.ext.log("🤖🟢Loading manifest \(manifestURL.absoluteString, privacy: .public)")
        guard let data = try? Data(contentsOf: manifestURL) else {
            Logger.ext.error("🤖🔴Loading manifest failed")
            return []
        }

        let manifest = try? JSONDecoder().decode(GetManifestResponse.self, from: data)
        packages = manifest?.packages ?? []
        Logger.ext.log("🤖🟢Manifest loaded, packages: \(self.packages.count, privacy: .public)")

        // TODO: load packages from storage for cross-reference.
        return Set(packages.map { $0.baDownload })
    }

    func backgroundDownload(_ failedDownload: BADownload, failedWithError error: Error) {
        Logger.ext.log("🤖🟠Loading failed: \(failedDownload.identifier, privacy: .public), error: \(error, privacy: .public)")
    }

    func backgroundDownload(_ finishedDownload: BADownload, finishedWithFileURL fileURL: URL) {
        Logger.ext.log("🤖🟢Loading success: \(finishedDownload.identifier, privacy: .public), file: \(fileURL.absoluteString, privacy: .public)")
    }

    func backgroundDownload(
        _ download: BADownload,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        (.performDefaultHandling, nil)
    }
}
