//
//  ManifestPackage.swift
//  Assets Bundling POC
//

import Foundation
import BackgroundAssets

public struct ManifestPackage: Codable {
    public let id: String
    public let name: String
    public let description: String
    public let path: String
    public let size: Int
    public let created: Double
}

extension ManifestPackage {

    public var url: URL? {
        URL(string: path)
    }

    public var createdDate: Date {
        Date(timeIntervalSince1970: created)
    }

    public var baDownload: BAURLDownload {
        BAURLDownload(
            identifier: id,
            request: URLRequest(url: url!),
            essential: false, // TODO: Change when there are essential downloads.
            fileSize: size,
            applicationGroupIdentifier: AppConfiguration.appBundleGroup,
            priority: .default
        )
    }
}
