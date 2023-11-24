//
//  ResourceType.swift
//  Assets Bundling POC
//

import Foundation

public enum ResourceType: String, Codable {
    case image
    case video
    case website
    case document
}

extension ResourceType {

    public var fileName: String {
        switch self {
        case .image:
            "image.jpg"
        case .video:
            "video.mov"
        case .website:
            "document.pdf"
        case .document:
            "index.html"
        }
    }
}
