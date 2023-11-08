//
//  GetManifestRequest.swift
//  Assets Bundling POC
//

import Foundation
import NgNetworkModuleCore
import ConcurrentNgNetworkModule

struct GetManifestRequest: NetworkRequest {
    let path: String
    let method = NetworkRequestType.get
}
