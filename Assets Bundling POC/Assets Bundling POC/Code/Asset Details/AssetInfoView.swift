//
//  AssetInfoView.swift
//  Assets Bundling POC
//

import SwiftUI

struct AssetInfoView: View {
    let assetData: AssetDetailsViewState.ViewData
    let hasODRdownloaded: Bool
    let onPlayVideoRequested: () -> Void
    let onShowDocumentRequested: () -> Void
    let onOpenWebsiteRequested: () -> Void

    var body: some View {
        VStack {
            Spacer()
                .frame(height: 30)

            // MARK: Title

            Text(assetData.title.uppercased())
                .font(.largeTitle)

            // MARK: Subtitle

            Text(assetData.subtitle.uppercased())
                .font(.headline)
                .multilineTextAlignment(.center)

            Spacer()
                .frame(height: 20)

            // MARK: Image

            ZStack {
                AsyncImage(
                    url: assetData.imageURL,
                    content: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    },
                    placeholder: {
                        ProgressView()
                    }
                )

                Button("Play video") {
                    onPlayVideoRequested()
                }
                .buttonStyle(CapsuleActionButtonStyle())
                .font(.largeTitle)
            }

            Spacer()
                .frame(height: 20)

            // MARK: Open website button

            Button("Open website") {
                onOpenWebsiteRequested()
            }
            .buttonStyle(CapsuleActionButtonStyle())
            .font(.title2)
            .disabled(!hasODRdownloaded)
            .grayscale(hasODRdownloaded ? 0 : 1)

            Spacer()
                .frame(height: 20)

            // MARK: Asset description

            Text(assetData.description)

            Spacer()
                .frame(height: 30)

            // MARK: Read more button

            Button("Read more") {
                onShowDocumentRequested()
            }
            .buttonStyle(CapsuleActionButtonStyle())
            .font(.footnote)
        }
    }
}
