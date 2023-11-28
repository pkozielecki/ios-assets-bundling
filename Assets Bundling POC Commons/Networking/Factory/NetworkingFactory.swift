//
//  NetworkingFactory.swift
//  Assets Bundling POC
//

import Foundation
import NgNetworkModuleCore
import ConcurrentNgNetworkModule

/// Factory for creating networking module.
public struct NetworkingFactory {

    /// Creates networking module.
    /// - Returns: Networking module.
    public static func makeNetworkModule() -> NetworkModule {
        let requestBuilder = DefaultRequestBuilder(baseURL: AppConfiguration.baseURL)
        return DefaultNetworkModule(requestBuilder: requestBuilder)
    }
}
