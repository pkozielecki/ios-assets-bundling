//
//  GetManifestResponse.swift
//  Assets Bundling POC
//

import Foundation
import NgNetworkModuleCore
import ConcurrentNgNetworkModule

public struct GetManifestResponse: Codable {
    public let packages: [ManifestPackage]
}
