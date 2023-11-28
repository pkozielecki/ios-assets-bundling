//
//  Logger.swift
//  Assets Bundling POC
//

import Foundation
import OSLog

extension Logger {
    public static let app = Logger(subsystem: "com.whitehatgaming.Assets-Bundling-POC", category: "app")
    public static let ext = Logger(subsystem: "com.whitehatgaming.Assets-Bundling-POC", category: "extension")
}
