//
//  AssetsDownloaderExtension.swift
//  Assets Bundling POC
//

import Foundation
import ExtensionFoundation
import Assets_Bundling_POC_Commons
import BackgroundAssets
import NgNetworkModuleCore
import ConcurrentNgNetworkModule
import OSLog

@main
class AssetsDownloaderExtension: BADownloaderExtension {
    private let networkModule: NetworkModule
    private var packages: [GetManifestResponse.Package]?

    required init() {
        Logger.ext.warning("Extension initialized")
        networkModule = NetworkingFactory.makeNetworkModule()
    }

    func downloads(for request: BAContentRequest, manifestURL: URL, extensionInfo: BAAppExtensionInfo) -> Set<BADownload> {
        // Discussion: This is not an async method, so we need to stop the thread until we get the manifest.
        let semaphore = DispatchSemaphore(value: 0)
        Logger.ext.warning("Loading manifest \(manifestURL.absoluteString)")
        Task { [weak self] in
            self?.packages = await self?.getManifest(url: manifestURL)
            Logger.ext.debug("Packages loaded \(self?.packages ?? [])")
            semaphore.signal()
        }
        semaphore.wait()
        return Set(composeDownloads())
    }

    func backgroundDownload(_ failedDownload: BADownload, failedWithError error: Error) {}

    func backgroundDownload(_ finishedDownload: BADownload, finishedWithFileURL fileURL: URL) {}

    func backgroundDownload(
        _ download: BADownload,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        (.performDefaultHandling, nil)
    }
}

private extension AssetsDownloaderExtension {

    func getManifest(url: URL) async -> [GetManifestResponse.Package] {
        let request = GetManifestRequest(path: url.absoluteString)
        if let response = try? await networkModule.performAndDecode(request: request, responseType: GetManifestResponse.self) {
            return response.packages
        } else {
            return []
        }
    }

    func composeDownloads() -> [BAURLDownload] {
        guard let packages = packages else {
            return []
        }

        return packages.map { package in
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
