//
//  AssetData.swift
//  Assets Bundling POC
//

import Foundation
import BackgroundAssets

public struct AssetData: Equatable, Hashable, Codable {
    public let id: String
    public let essential: Bool
    public let name: String
    public let description: String
    public let state: State
    public let created: Double
    public let size: Int
    public let remoteURL: URL?

    public init(id: String, essential: Bool, name: String, description: String, state: State, created: Double, size: Int, remoteURL: URL?) {
        self.id = id
        self.essential = essential
        self.name = name
        self.description = description
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
        case toBeTransferred
        case loaded
        case failed
    }

    public init(from package: ManifestPackage, essentialDownloadsPermitted: Bool) {
        self.init(
            id: package.id,
            essential: package.essential && essentialDownloadsPermitted,
            name: package.name,
            description: package.description,
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
            essential: essential,
            fileSize: size,
            applicationGroupIdentifier: AppConfiguration.appBundleGroup,
            priority: essential ? .max : .default
        )
    }

    public var createdDate: Date {
        Date(timeIntervalSince1970: created)
    }

    public func changingState(_ newState: State) -> AssetData {
        AssetData(
            id: id,
            essential: essential,
            name: name,
            description: description,
            state: newState,
            created: created,
            size: size,
            remoteURL: remoteURL
        )
    }
}

extension AssetData.State {

    var isDownloadCompleted: Bool {
        switch self {
        case .loaded, .toBeTransferred:
            true
        default:
            false
        }
    }
}
