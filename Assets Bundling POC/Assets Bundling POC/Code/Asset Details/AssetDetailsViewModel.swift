//
//  AssetDetailsViewModel.swift
//  Assets Bundling POC
//

import SwiftUI
import Assets_Bundling_POC_Commons
import Observation

protocol AssetDetailsViewModel: Observable {
    var viewState: AssetDetailsViewState { get }
    func onViewAppeared() async
    func onPlayVideoRequested()
    func onShowDocumentRequested()
}

@Observable final class LiveAssetDetailsViewModel: AssetDetailsViewModel {
    private let router: NavigationRouter
    private let fileManager: AssetFilesManager
    private let assetStateManager: AssetStateManager
    private let selectedAsset: AssetData

    private(set) var viewState: AssetDetailsViewState = .loading

    init(
        selectedAsset: AssetData,
        router: NavigationRouter,
        assetStateManager: AssetStateManager,
        fileManager: AssetFilesManager = FileManager.default
    ) {
        self.selectedAsset = selectedAsset
        self.router = router
        self.assetStateManager = assetStateManager
        self.fileManager = fileManager
    }

    func onViewAppeared() async {
        await unpackAssetIfNeeded()
    }

    func onPlayVideoRequested() {
        guard case let .loaded(viewData) = viewState else {
            return
        }
        router.push(route: .video(url: viewData.videoURL))
    }

    func onShowDocumentRequested() {
        guard case let .loaded(viewData) = viewState else {
            return
        }
        router.push(route: .document(url: viewData.documentURL))
    }
}

private extension LiveAssetDetailsViewModel {

    @MainActor func composeViewState() -> AssetDetailsViewState {
        guard selectedAsset.state == .loaded else {
            return .error
        }

        // TODO: Check if asset folder is not empty.
        let assetDirectoryURL = fileManager.unpackedAssetFolder(for: selectedAsset.id)
        if fileManager.folderExists(at: assetDirectoryURL) {
            let viewData = AssetDetailsViewState.ViewData(
                title: selectedAsset.name,
                subtitle: "Created: \(selectedAsset.createdDate.formatted()),\nsize: \(Int(selectedAsset.size / 1024 / 1024)) MB",
                description: selectedAsset.description,
                imageURL: assetDirectoryURL.appendingPathComponent("image.jpg"),
                videoURL: assetDirectoryURL.appendingPathComponent("video.mov"),
                documentURL: assetDirectoryURL.appendingPathComponent("document.pdf")
            )
            return .loaded(viewData)
        }

        return .loading
    }

    func unpackAssetIfNeeded() async {
        let assetDirectoryURL = fileManager.unpackedAssetFolder(for: selectedAsset.id)
        // TODO: Check if not empty.
        guard !fileManager.folderExists(at: assetDirectoryURL) else {
            viewState = await composeViewState()
            return
        }

        try? fileManager.createDirectory(at: assetDirectoryURL, withIntermediateDirectories: true, attributes: nil)

        let assetURL = fileManager.permanentStorageAssetFile(for: selectedAsset.id)
        do {
            // Discussion: This is happening on bg thread and `composeViewState()` is annotated by @MainActor.
            try fileManager.unzipItem(at: assetURL, to: assetDirectoryURL, skipCRC32: false, progress: nil, pathEncoding: nil)
            viewState = await composeViewState()
        } catch {
            assetStateManager.updateAssetState(assetID: selectedAsset.id, newState: .failed)
            Task { @MainActor in
                viewState = .error
            }
        }
    }
}
