//
//  URL + Manifest Parsing.swift
//  Assets Bundling POC
//

import Foundation
import OSLog

public extension URL {

    func getManifestPackage() -> [ManifestPackage] {
        guard let data = try? Data(contentsOf: self) else {
            Logger.ext.error("🛠️🔴Loading manifest failed")
            return []
        }
        let manifest = try? JSONDecoder().decode(GetManifestResponse.self, from: data)
        return manifest?.packages ?? []
    }
}
