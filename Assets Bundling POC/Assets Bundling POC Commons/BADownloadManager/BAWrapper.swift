//
//  BAWrapper.swift
//  Assets Bundling POC
//

import Foundation
import BackgroundAssets

public protocol BAWrapper: AnyObject {
    var delegate: BADownloadManagerDelegate? { get set }
    func withExclusiveControl(_ performHandler: @escaping (Bool, Error?) -> Void)
    func startForegroundDownload(_ download: BADownload) throws
    func fetchCurrentDownloads() throws -> [BADownload]
}

extension BADownloadManager: BAWrapper {}
