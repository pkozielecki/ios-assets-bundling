//
//  ODRManager.swift
//  Assets Bundling POC
//

import Foundation

protocol ODRManager {
    func fetchResourcesPack(_ pack: ODRPack) async throws -> Void
}

final class LiveODRManager: ODRManager {
    private var currentRequest: NSBundleResourceRequest?

    func fetchResourcesPack(_ pack: ODRPack) async throws {
        let request = NSBundleResourceRequest(tags: [pack.id])
        request.loadingPriority = pack.priority
        try await request.beginAccessingResources()
    }
}
