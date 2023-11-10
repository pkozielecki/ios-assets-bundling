//
//  MainApp.swift
//  Assets Bundling POC
//

import SwiftUI
import NgNetworkModuleCore
import ConcurrentNgNetworkModule

@main
struct Assets_Bundling_POCApp: App {
    let model = AssetsListViewModel()
    let router = LiveNavigationRouter()
    let networkModule: NetworkModule
    let assetsManager: AssetsManager

    init() {
        let baseURL = URL(string: "https://cvws.icloud-content.com")!
        let requestBuilder = DefaultRequestBuilder(baseURL: baseURL)
        networkModule = DefaultNetworkModule(requestBuilder: requestBuilder)
        assetsManager = LiveAssetsManager(manifestPath: AppConfiguration.manifestPath, networkModule: networkModule)
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(
                path: .init(get: { router.navigationStack }, set: { stack in router.set(navigationStack: stack) })
            ) {
                AssetsListView(viewModel: model, router: router)
                    .navigationDestination(for: NavigationRoute.self) { destination in
                        switch destination {
                        case let .assetDetails(asset):
                            Text(asset.name)
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

private extension Assets_Bundling_POCApp {

    func handlePopupRoute(_ popupRoute: PopupRoute?) {
        if let popupRoute {
            router.present(popup: popupRoute)
        } else {
            router.dismiss()
        }
    }

    @ViewBuilder func makePopupView(for popupRoute: PopupRoute?) -> any View {}
}
