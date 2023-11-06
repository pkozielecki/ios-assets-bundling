//
//  MainApp.swift
//  Assets Bundling POC
//

import SwiftUI

@main
struct Assets_Bundling_POCApp: App {
    var body: some Scene {
        WindowGroup {
            let model = AssetsListViewModel()
            AssetsListView(viewModel: model)
        }
    }
}
