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
        let id: String
        let name: String
        let path: String
        let size: Int64
    }
}

extension GetManifestResponse.Package {

    var url: URL? {
        URL(string: path)
    }
}
