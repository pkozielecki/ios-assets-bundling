//
//  MainApp.swift
//  Assets Bundling POC
//

import SwiftUI

@main
struct Assets_Bundling_POCApp: App {
    let model = AssetsListViewModel()
    let router = LiveNavigationRouter()

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
