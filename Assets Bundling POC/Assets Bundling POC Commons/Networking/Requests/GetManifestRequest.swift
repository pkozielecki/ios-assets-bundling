//
//  GetManifestRequest.swift
//  Assets Bundling POC
//

import Foundation
import NgNetworkModuleCore
import ConcurrentNgNetworkModule

public struct GetManifestRequest: NetworkRequest {
    public let path: String
    public let method = NetworkRequestType.get

    public init(path: String) {
        self.path = path
    }
}
