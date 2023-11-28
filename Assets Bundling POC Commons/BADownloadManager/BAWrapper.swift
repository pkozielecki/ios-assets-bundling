//
//  BAWrapper.swift
//  Assets Bundling POC
//

import Foundation
import BackgroundAssets

/// A wrapper for `BADownloadManager` to make it testable.
public protocol BAWrapper: AnyObject {

    /// Delegate for `BADownloadManager`.
    var delegate: BADownloadManagerDelegate? { get set }

    /// Executes given closure with exclusive control.
    /// - SeeAlso: `BADownloadManager.withExclusiveControl(_:)`
    func withExclusiveControl(_ performHandler: @escaping (Bool, Error?) -> Void)

    /// Starts download of given asset.
    /// - SeeAlso: `BADownloadManager.startDownload(_:)`
    func startForegroundDownload(_ download: BADownload) throws

    /// Fetches all current downloads.
    /// - SeeAlso: `BADownloadManager.fetchCurrentDownloads()`
    func fetchCurrentDownloads() throws -> [BADownload]
}

extension BADownloadManager: BAWrapper {}
