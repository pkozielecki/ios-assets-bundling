//
//  GetManifestResponse.swift
//  Assets Bundling POC
//

import Foundation
import NgNetworkModuleCore
import ConcurrentNgNetworkModule

public struct GetManifestResponse: Codable {
    public let packages: [Package]
}

extension GetManifestResponse {

    public struct Package: Codable {
        public let id: String
        public let name: String
        public let path: String
        public let size: Int
        public let created: Double
    }
}

extension GetManifestResponse.Package {

    public var url: URL? {
        URL(string: path)
    }

    public var createdDate: Date {
        Date(timeIntervalSince1970: created)
    }
}
