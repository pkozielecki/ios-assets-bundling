//
//  LocalStorage.swift
//  Assets Bundling POC
//

import Foundation
import OSLog

public enum StorageKeys: String {
    case assets
}

public enum StorageError: Error {
    case unableToEncodeData
    case dataStorageError
}

public protocol LocalStorage {
    func setValue<T: Encodable>(_ value: T, forKey key: String) throws
    func getValue<T: Decodable>(forKey key: String) throws -> T?
    func removeValue(forKey key: String) throws
}

extension LocalStorage {

    public func readAssetsFromStorage() -> [AssetData] {
        do {
            let packages: [AssetData]? = try getValue(forKey: StorageKeys.assets.rawValue)
            return packages ?? []
        } catch {
            Logger.app.error("🛠️🔴Failed to read assets from storage: \(error)")
            return []
        }
    }

    public func writeAssetsToStorage(_ assets: [AssetData]) {
        do {
            try setValue(assets, forKey: StorageKeys.assets.rawValue)
        } catch {
            Logger.app.error("🛠🔴Failed to write assets to storage: \(error)")
        }
    }
}
