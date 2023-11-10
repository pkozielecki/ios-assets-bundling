//
//  Settings.swift
//  Assets Bundling POC
//

import Foundation

enum AppConfiguration {

    static let appBundleGroup = "group.com.whitehatgaming.Assets-Bundling-POC"

    static var manifestPath: String {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let manifestURLString = infoDictionary["BAManifestURL"] as? String else {
            return ""
        }
        return manifestURLString
    }
}
