//
//  NavigationRoute.swift
//  Assets Bundling POC
//

import Foundation

enum NavigationRoute: Equatable, Hashable, Identifiable {
    case assetDetails(AssetData)

    var id: Int {
        hashValue
    }
}
