//
//  GetManifestResponse.swift
//  Assets Bundling POC
//

import Foundation
import NgNetworkModuleCore
import ConcurrentNgNetworkModule

struct GetManifestResponse: Codable {
    let packages: [Package]
}

extension GetManifestResponse {

    struct Package: Codable {
        let name: String
        let path: String
    }
}

extension GetManifestResponse.Package {

    var packageURL: URL? {
        URL(string: path)
    }
}
