//
//  AssetData.swift
//  Assets Bundling POC
//

import Foundation
import BackgroundAssets

public struct AssetData: Equatable, Hashable, Codable {
    public let id: String
    public let name: String
    public let state: State
    public let created: Double
    public let size: Int
    public let remoteURL: URL?

    public init(id: String, name: String, state: State, created: Double, size: Int, remoteURL: URL?) {
        self.id = id
        self.name = name
        self.state = state
        self.created = created
        self.size = size
        self.remoteURL = remoteURL
    }
}

extension AssetData {

    public enum State: Codable, Equatable, Hashable {
        case notLoaded
        case loading(Double)
        case loaded
        case failed
    }

    public init(from package: ManifestPackage) {
        self.init(
            id: package.id,
            name: package.name,
            state: .notLoaded, // Discussion: Package download is not started yet.
            created: package.created,
            size: package.size,
            remoteURL: package.url
        )
    }

    public var baDownload: BAURLDownload {
        guard let remoteURL else {
            fatalError("🛠️🔴 Remote URL is nil for asset \(id).")
        }

        return BAURLDownload(
            identifier: id,
            request: URLRequest(url: remoteURL),
            essential: false, // TODO: Change when there are essential downloads.
            fileSize: size,
            applicationGroupIdentifier: AppConfiguration.appBundleGroup,
            priority: .default
        )
    }

    public var createdDate: Date {
        Date(timeIntervalSince1970: created)
    }

    public func changingState(_ newState: State) -> AssetData {
        AssetData(
            id: id,
            name: name,
            state: newState,
            created: created,
            size: size,
            remoteURL: remoteURL
        )
    }
}