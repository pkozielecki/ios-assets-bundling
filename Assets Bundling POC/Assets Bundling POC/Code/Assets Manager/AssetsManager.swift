//
//  AssetsManager.swift
//  Assets Bundling POC
//

import Foundation
import NgNetworkModuleCore
import ConcurrentNgNetworkModule

protocol AssetsManager {}

final class LiveAssetsManager: AssetsManager {
    private let manifestPath: String
    private let networkModule: NetworkModule

    init(
        manifestPath: String,
        networkModule: NetworkModule
    ) {
        self.manifestPath = manifestPath
        self.networkModule = networkModule

        Task {
            await refreshManifest()
        }
    }
}

private extension LiveAssetsManager {

    func refreshManifest() async {
        let request = GetManifestRequest(path: manifestPath)
        do {
            let response = try await networkModule.performAndDecode(request: request, responseType: GetManifestResponse.self)
            print(response)
        } catch {
            print("Error: \(error)")
        }
    }
}
