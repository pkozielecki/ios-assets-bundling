//
//  AssetDetailsView.swift
//  Assets Bundling POC
//

import SwiftUI

struct AssetDetailsView: View {
    let viewModel: AssetDetailsViewModel

    var body: some View {
        ZStack {

            // MARK: Asset info section

            if let assetData = assetData {
                ScrollView {
                    AssetInfoView(
                        assetData: assetData,
                        hasODRdownloaded: isODRdownloaded,
                        onPlayVideoRequested: viewModel.onPlayVideoRequested,
                        onShowDocumentRequested: viewModel.onShowDocumentRequested,
                        onOpenWebsiteRequested: viewModel.onOpenWebsiteRequested
                    )
                }
                .animation(.easeIn, value: viewState)
                .padding()
            }

            // MARK: Error view:

            if hasError {
                AssetErrorView(
                    title: "An error has occurred",
                    message: "Please try re-downloading the asset",
                    onFixBrokenAssetRequested: viewModel.onFixBrokenAssetRequested
                )
                .animation(.easeIn, value: viewState)
            }

            // MARK: Loading indicator

            if isLoading {
                LoaderView(configuration: .default)
                    .animation(.easeIn, value: viewState)
            }
        }
        .onAppear {
            Task {
                await viewModel.onViewAppeared()
            }
        }
    }
}

private extension AssetDetailsView {

    var viewState: AssetDetailsViewState {
        viewModel.viewState
    }

    var isLoading: Bool {
        viewState == .loading
    }

    var hasError: Bool {
        viewState == .error
    }

    var isODRdownloaded: Bool {
        if case .ready = viewState {
            return true
        }
        return false
    }

    var assetData: AssetDetailsViewState.ViewData? {
        switch viewState {
        case let .assetsLoaded(assetData), let .ready(assetData):
            assetData
        default:
            nil
        }
    }
}

#if DEBUG
    #Preview {
        let model = PreviewAssetDetailsViewModel()
        let imagePath = Bundle.main.path(forResource: "preview-asset-image", ofType: "jpg") ?? ""
        model.viewState = .ready(
//    model.viewState = .assetsLoaded(
            .init(
                title: "Fake asset title",
                subtitle: "Asset XYZ,\ncreated 10.10.2023",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                imageURL: URL(fileURLWithPath: imagePath),
                videoURL: URL(string: "http://wp.pl")!,
                documentURL: URL(string: "http://wp.pl")!,
                websiteURL: URL(string: "http://wp.pl")!
            )
        )
//    model.viewState = .error
//    model.viewState = .loading
        return AssetDetailsView(viewModel: model)
    }
#endif
