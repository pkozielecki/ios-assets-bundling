//
//  AssetFilesManager.swift
//  Assets Bundling POC
//

import Foundation

public protocol AssetFilesManager {
    func setUp()
    func sharedStorageAssetFile(for assetID: String) -> URL
    func permanentStorageAssetFile(for assetID: String) -> URL
    func ephemeralStorageAssetFile(for assetID: String) -> URL
    func replaceItemAt(_ originalItemURL: URL, withItemAt newItemURL: URL, backupItemName: String?, options: FileManager.ItemReplacementOptions) throws -> URL?
    func moveItem(at srcURL: URL, to dstURL: URL) throws
    func removeItem(at URL: URL) throws
    func fileExists(atPath path: String) -> Bool
    func createDirectory(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey: Any]?
    ) throws
}

extension FileManager: AssetFilesManager {

    public var sharedContainerURL: URL {
        containerURL(forSecurityApplicationGroupIdentifier: AppConfiguration.appBundleGroup)!
    }

    public var permanentContainerURL: URL {
        urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

    public var ephemeralContainerURL: URL {
        do {
            return try url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        } catch {
            return sharedContainerURL
        }
    }

    public var sharedAssetsContainer: URL {
        sharedContainerURL.appending(component: "Assets", directoryHint: .isDirectory)
    }

    public var permanentAssetsContainer: URL {
        permanentContainerURL.appending(component: "Assets", directoryHint: .isDirectory)
    }

    public func ephemeralStorageAssetFile(for assetID: String) -> URL {
        ephemeralContainerURL.appending(component: "\(assetID).zip", directoryHint: .notDirectory)
    }

    public func sharedStorageAssetFile(for assetID: String) -> URL {
        sharedAssetsContainer.appending(component: "\(assetID).zip", directoryHint: .notDirectory)
    }

    public func permanentStorageAssetFile(for assetID: String) -> URL {
        permanentAssetsContainer.appending(component: "\(assetID).zip", directoryHint: .notDirectory)
    }

    public func setUp() {
        try? createDirectory(at: ephemeralContainerURL, withIntermediateDirectories: true, attributes: nil)
        try? createDirectory(at: sharedAssetsContainer, withIntermediateDirectories: true, attributes: nil)
        try? createDirectory(at: permanentAssetsContainer, withIntermediateDirectories: true, attributes: nil)
    }
}
