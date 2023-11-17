//
//  NavigationRoute.swift
//  Assets Bundling POC
//

import Foundation
import Assets_Bundling_POC_Commons

enum NavigationRoute: Equatable, Hashable, Identifiable {
    case assetDetails(AssetData)

    var id: Int {
        hashValue
    }
}
