//
//  ImageStyles.swift
//  Assets Bundling POC
//

import SwiftUI

extension Image {

    func assetListIconStyle(color: Color = Color("Progress-Background")) -> some View {
        resizable()
            .foregroundColor(color)
            .imageScale(.large)
            .frame(width: 30, height: 30)
    }
}
