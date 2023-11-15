//
//  LocalStorage.swift
//  Assets Bundling POC
//

import Foundation

public enum StorageKeys: String {
    case assets
}

public enum StorageError: Error {
    case unableToEncodeData
    case dataStorageError
}

public protocol LocalStorage {
    func setValue<T: Encodable>(_ value: T, forKey key: String) async throws
    func getValue<T: Decodable>(forKey key: String) async throws -> T?
    func removeValue(forKey key: String) async throws
}
