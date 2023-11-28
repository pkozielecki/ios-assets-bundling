//
//  Settings.swift
//  Assets Bundling POC
//

import Foundation
import Assets_Bundling_POC_Commons

extension AppConfiguration {

    static var manifestPath: String {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let manifestURLString = infoDictionary["BAManifestURL"] as? String else {
            return ""
        }
        return manifestURLString
    }
}
