//
//  AssetFilesManager.swift
//  Assets Bundling POC
//

import Foundation

public protocol AssetFilesManager {}

public final class LiveAssetFilesManager: AssetFilesManager {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
}
