//
//  NetworkingFactory.swift
//  Assets Bundling POC
//

import Foundation
import NgNetworkModuleCore
import ConcurrentNgNetworkModule

public struct NetworkingFactory {

    public static func makeNetworkModule() -> NetworkModule {
        let requestBuilder = DefaultRequestBuilder(baseURL: AppConfiguration.baseURL)
        return DefaultNetworkModule(requestBuilder: requestBuilder)
    }
}
