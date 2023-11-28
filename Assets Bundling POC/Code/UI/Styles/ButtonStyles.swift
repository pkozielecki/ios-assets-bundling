//
//  ButtonStyles.swift
//  Assets Bundling POC
//

import SwiftUI

struct CapsuleActionButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color("Progress-Background"))
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
}
