//
//  AssetBundlerApp.swift
//  Assets Bundling POC
//

import SwiftUI
import NgNetworkModuleCore
import ConcurrentNgNetworkModule
import Assets_Bundling_POC_Commons
import AVKit

@main
struct AssetBundlerApp: App {
    let model: AssetsListViewModel
    let router = LiveNavigationRouter()
    let networkModule: NetworkModule
    let assetsManager: AssetsManager
    let odrManager: ODRManager

    init() {
        networkModule = NetworkingFactory.makeNetworkModule()
        assetsManager = LiveAssetsManager(manifestPath: AppConfiguration.manifestPath, networkModule: networkModule)
        odrManager = LiveODRManager()
        model = LiveAssetsListViewModel(router: router, assetsProvider: assetsManager, assetsCleaner: assetsManager)

        Task { [assetsManager] in
            await assetsManager.start()
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(
                path: .init(get: { router.navigationStack }, set: { stack in router.set(navigationStack: stack) })
            ) {
                AssetsListView(viewModel: model)
                    .navigationDestination(for: NavigationRoute.self) { destination in
                        switch destination {
                        case let .assetDetails(asset):
                            AssetDetailsView(
                                viewModel: LiveAssetDetailsViewModel(
                                    selectedAsset: asset,
                                    router: router,
                                    assetStateManager: assetsManager,
                                    assetsCleaner: assetsManager,
                                    odrManager: odrManager
                                )
                            )
                        case let .video(url):
                            let player = AVPlayer(url: url)
                            VideoPlayer(player: player)
                                .onAppear {
                                    player.play()
                                }
                        case let .document(url):
                            PDFKitView(documentURL: url)
                        case let .website(url):
                            WebView(url: url)
                        }
                    }
                    .sheet(
                        item: .init(get: { router.presentedPopup }, set: { handlePopupRoute($0) })
                    ) { popupRoute in
                        switch popupRoute {
                        case .info:
                            Text("Info popup")
                        }
                    }
                // TODO: Add alert support.
            }
        }
    }
}

private extension AssetBundlerApp {

    func handlePopupRoute(_ popupRoute: PopupRoute?) {
        if let popupRoute {
            router.present(popup: popupRoute)
        } else {
            router.dismiss()
        }
    }

    @ViewBuilder func makePopupView(for popupRoute: PopupRoute?) -> any View {}
}
