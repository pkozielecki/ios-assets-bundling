//
//  AssetFilesManager.swift
//  Assets Bundling POC
//

import Foundation

public protocol AssetFilesManager {
    func setUp()
    func assetFileURL(for assetID: String) -> URL
    func replaceItemAt(_ originalItemURL: URL, withItemAt newItemURL: URL, backupItemName: String?, options: FileManager.ItemReplacementOptions) throws -> URL?
    func moveItem(at srcURL: URL, to dstURL: URL) throws
    func removeItem(at URL: URL) throws
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

    public var sharedAssetsContainer: URL {
        sharedContainerURL.appending(component: "Assets", directoryHint: .isDirectory)
    }

    public func setUp() {
        try? createDirectory(at: sharedAssetsContainer, withIntermediateDirectories: true, attributes: nil)
    }

    public func assetFileURL(for assetID: String) -> URL {
        sharedAssetsContainer.appending(component: "\(assetID).zip", directoryHint: .notDirectory)
    }
}
