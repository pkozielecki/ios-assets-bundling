//
//  GetManifestRequest.swift
//  Assets Bundling POC
//

import Foundation
import NgNetworkModuleCore
import ConcurrentNgNetworkModule

/// A request for getting assets manifest.
public struct GetManifestRequest: NetworkRequest {
    public let path: String
    public let method = NetworkRequestType.get

    /// Initializes request with given path.
    /// - Parameter path: Path to manifest.
    public init(path: String) {
        self.path = path
    }
}
