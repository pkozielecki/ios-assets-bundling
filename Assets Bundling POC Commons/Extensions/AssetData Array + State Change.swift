//
//  AssetData Array + State Change.swift
//  Assets Bundling POC
//

import Foundation

extension Array where Element == AssetData {

    public func updateState(assetID: String, newState: AssetData.State) -> Self {
        map {
            guard $0.id == assetID else {
                return $0
            }
            return $0.changingState(newState)
        }
    }
}
