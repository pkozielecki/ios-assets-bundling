//
//  NavigationRoute.swift
//  Assets Bundling POC
//

import Foundation
import Assets_Bundling_POC_Commons

enum NavigationRoute: Equatable, Hashable, Identifiable {
    case assetDetails(AssetData)
    case video(url: URL)
    case document(url: URL)

    var id: Int {
        hashValue
    }
}
