//
//  AssetDetailsViewModel.swift
//  Assets Bundling POC
//

import SwiftUI
import Assets_Bundling_POC_Commons
import Observation
import OSLog

protocol AssetDetailsViewModel: Observable {
    var viewState: AssetDetailsViewState { get }
    func onViewAppeared() async
    func onPlayVideoRequested()
    func onShowDocumentRequested()
    func onOpenWebsiteRequested()
    func onFixBrokenAssetRequested() async
}

@Observable final class LiveAssetDetailsViewModel: AssetDetailsViewModel {
    private let selectedAsset: AssetData
    private let router: NavigationRouter
    private let assetStateManager: AssetStateManager
    private let assetsCleaner: AssetsCleaner
    private let odrManager: ODRManager
    private let fileManager: AssetFilesManager

    private(set) var viewState: AssetDetailsViewState = .loading
    private var assetUnpackingSucceeded = true
    private var odrUnpackingSucceeded = true

    init(
        selectedAsset: AssetData,
        router: NavigationRouter,
        assetStateManager: AssetStateManager,
        assetsCleaner: AssetsCleaner,
        odrManager: ODRManager,
        fileManager: AssetFilesManager = FileManager.default
    ) {
        self.selectedAsset = selectedAsset
        self.router = router
        self.assetStateManager = assetStateManager
        self.assetsCleaner = assetsCleaner
        self.odrManager = odrManager
        self.fileManager = fileManager
    }

    func onViewAppeared() async {
        // TODO: Start at the same time.
        // TODO: Regardless of the order the tasks finish, unpack package and assemble games.
        await unpackAssetIfNeeded()
        await fetchAndUnpackODRifNeeded()
    }

    func onPlayVideoRequested() {
        if assetsUnpacked {
            router.push(route: .video(url: fileManager.resourceURL(for: assetID, of: .video)))
        }
    }

    func onShowDocumentRequested() {
        if assetsUnpacked {
            router.push(route: .document(url: fileManager.resourceURL(for: assetID, of: .document)))
        }
    }

    func onOpenWebsiteRequested() {
        if assetsUnpacked, odrUnpacked {
            router.push(route: .website(url: fileManager.resourceURL(for: assetID, of: .website)))
        }
    }

    @MainActor func onFixBrokenAssetRequested() async {
        viewState = .loading
        await assetsCleaner.clearCache(for: assetID)
        router.pop()
    }
}

private extension LiveAssetDetailsViewModel {

    func composeViewState() -> AssetDetailsViewState {
        guard selectedAsset.state == .loaded, assetUnpackingSucceeded, odrUnpackingSucceeded else {
            return .error
        }

        if assetsUnpacked {
            let viewData = composeViewData()
            if odrUnpacked {
                return .ready(viewData)
            } else {
                return .assetsLoaded(viewData)
            }
        }

        return .loading
    }

    func unpackAssetIfNeeded() async {
        guard !fileManager.fileExists(atPath: imageFileURL.path) else {
            assetUnpackingSucceeded = true
            await refreshViewState()
            return
        }

        let assetDirectoryURL = fileManager.unpackedAssetFolder(for: assetID)
        try? fileManager.createDirectory(at: assetDirectoryURL, withIntermediateDirectories: true, attributes: nil)

        let assetURL = fileManager.permanentStorageAssetFile(for: assetID)
        do {
            // Discussion: This is happening on bg thread - UI should not be affected.
            try fileManager.unzipItem(at: assetURL, to: assetDirectoryURL, skipCRC32: false, progress: nil, pathEncoding: nil)
            try fileManager.removeItem(at: assetURL)
            assetUnpackingSucceeded = true
            await refreshViewState()
        } catch {
            Logger.app.error("📱🔴Failed to unzip asset: \(error, privacy: .public)")
            assetUnpackingSucceeded = false
            await handleFailure()
        }
    }

    func fetchAndUnpackODRifNeeded() async {
        guard !fileManager.fileExists(atPath: websiteFileURL.path) else {
            odrUnpackingSucceeded = true
            await refreshViewState()
            return
        }

        let pack = ODRPack(id: "odr-\(assetID)", priority: 0.5)
        do {
            // Discussion: This is happening on bg thread - UI should not be affected.
            try await odrManager.fetchResourcesPack(pack)
            if let odrURL = Bundle.main.url(forResource: assetID, withExtension: "zip") {
                let assetDirectoryURL = fileManager.unpackedAssetFolder(for: assetID)
                try fileManager.unzipItem(at: odrURL, to: assetDirectoryURL, skipCRC32: false, progress: nil, pathEncoding: nil)
                odrUnpackingSucceeded = true
                await refreshViewState()
            } else {
                Logger.app.error("📱🔴Failed to find ODR pack")
                odrUnpackingSucceeded = false
                await handleFailure()
            }
        } catch {
            Logger.app.error("📱🔴Failed to fetch ODR pack: \(error, privacy: .public)")
            odrUnpackingSucceeded = false
            await handleFailure()
        }
    }

    func handleFailure() async {
        assetStateManager.updateAssetState(assetID: assetID, newState: .failed)
        await refreshViewState()
    }

    @MainActor func refreshViewState() {
        viewState = composeViewState()
    }

    func composeViewData() -> AssetDetailsViewState.ViewData {
        AssetDetailsViewState.ViewData(
            title: selectedAsset.name,
            subtitle: "Created: \(selectedAsset.createdDate.formatted()),\nSize: \(selectedAsset.size.megabytes) MB",
            description: selectedAsset.description,
            imageURL: imageFileURL,
            videoURL: videoFileURL,
            documentURL: documentFileURL,
            websiteURL: websiteFileURL
        )
    }
}

private extension LiveAssetDetailsViewModel {

    var imageFileURL: URL {
        fileManager.resourceURL(for: assetID, of: .image)
    }

    var videoFileURL: URL {
        fileManager.resourceURL(for: assetID, of: .video)
    }

    var documentFileURL: URL {
        fileManager.resourceURL(for: assetID, of: .document)
    }

    var websiteFileURL: URL {
        fileManager.resourceURL(for: assetID, of: .website)
    }

    var assetsUnpacked: Bool {
        fileManager.fileExists(atPath: imageFileURL.path)
    }

    var odrUnpacked: Bool {
        fileManager.fileExists(atPath: websiteFileURL.path)
    }

    var assetID: String {
        selectedAsset.id
    }
}
