//
//  AlertRoute.swift
//  Assets Bundling POC
//

import Foundation

enum AlertRoute: Hashable, Codable, Identifiable {
    case info

    var id: Int {
        hashValue
    }
}
