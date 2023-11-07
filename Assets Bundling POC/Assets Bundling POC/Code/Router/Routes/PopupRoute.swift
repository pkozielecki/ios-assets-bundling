//
//  PopupRoute.swift
//  Assets Bundling POC
//

import Foundation

enum PopupRoute: Hashable, Codable, Identifiable {
    case info

    var id: Int {
        hashValue
    }
}
