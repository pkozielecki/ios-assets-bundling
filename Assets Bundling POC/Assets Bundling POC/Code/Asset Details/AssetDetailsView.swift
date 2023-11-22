//
//  AssetDetailsView.swift
//  Assets Bundling POC
//

import SwiftUI

struct AssetDetailsView: View {
    let viewModel: AssetDetailsViewModel

    var body: some View {
        ZStack {
            if let assetData = assetData {
                VStack {
                    Spacer()
                        .frame(height: 30)

                    Text(assetData.title.uppercased())
                        .font(.largeTitle)

                    Text(assetData.subtitle.uppercased())
                        .font(.headline)

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
                            print("Button pressed!")
                        }
                        .buttonStyle(CapsuleActionButtonStyle())
                        .font(.largeTitle)
                    }

                    Text(assetData.description)

                    Spacer()
                        .frame(height: 30)

                    Button("Read more") {
                        print("Button pressed!")
                    }
                    .buttonStyle(CapsuleActionButtonStyle())
                    .font(.footnote)

                    Spacer()
                }
                .animation(/*@START_MENU_TOKEN@*/ .easeIn/*@END_MENU_TOKEN@*/, value: viewState)
                .padding()
            }

            if isLoading {
                LoaderView(configuration: .default)
                    .animation(/*@START_MENU_TOKEN@*/ .easeIn/*@END_MENU_TOKEN@*/, value: viewState)
            }
        }
        .onAppear {
            Task {
                await viewModel.onViewAppeared()
            }
        }
    }
}

private extension AssetDetailsView {

    var viewState: AssetDetailsViewState {
        viewModel.viewState
    }

    var isLoading: Bool {
        viewState == .loading
    }

    var hasError: Bool {
        viewState == .error
    }

    var assetData: AssetDetailsViewState.ViewData? {
        guard case let .loaded(assetData) = viewState else {
            return nil
        }
        return assetData
    }
}

#Preview {
    let model = PreviewAssetDetailsViewModel()
    let imagePath = Bundle.main.path(forResource: "preview-asset-image", ofType: "jpg") ?? ""
    model.viewState = .loaded(
        .init(
            title: "Fake asset title",
            subtitle: "Asset XYZ,\ncreated 10.10.2023",
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
            imageURL: URL(fileURLWithPath: imagePath),
            videoURL: URL(string: "http://wp.pl")!,
            documentURL: URL(string: "http://wp.pl")!
        )
    )
    return AssetDetailsView(viewModel: model)
}
