//
//  AssetsListView.swift
//  Assets Bundling POC
//

import SwiftUI

struct AssetsListView: View {
    let viewModel: AssetsListViewModel
    let router: NavigationRouter

    var body: some View {
        ZStack {
            List {
                Section(header: makeSectionHeader()) {
                    ForEach(assets, id: \.self) { data in
                        Button {
                            guard let destination = viewModel.calculateNavigationDesitination(for: data.id) else {
                                return
                            }
                            router.push(route: destination)
                        } label: {
                            HStack {
                                makeImage(for: data.state)
                                    .imageScale(.medium)
                                    .foregroundStyle(.tint)
                                Text(data.name)
                                    .font(.body)
                                    .listRowSeparator(.hidden)
                            }
                            .animation(.easeIn, value: data.state)
                        }
                    }
                }
            }
            .listStyle(.grouped)

            if !isHidden {
                Button {
                    viewModel.onReloadRequested()
                } label: {
                    Text("No assets loaded\nTap to reload")
                        .font(.title)
                }
                .animation(.easeIn, value: isHidden)
            }
        }
        .onAppear {
            viewModel.onViewAppeared()
        }
    }
}

private extension AssetsListView {

    var isHidden: Bool {
        if case .noAssets = viewModel.viewState {
            return false
        }
        return true
    }

    var assets: [AssetListViewRowData] {
        if case let .loaded(assetsListRows) = viewModel.viewState {
            return assetsListRows
        }
        return []
    }

    func makeImage(for assetState: AssetListViewRowData.State) -> Image {
        switch assetState {
        case .loaded:
            Image(systemName: "checkmark.circle.fill")
        case .loading:
            // TODO: Show animated progress.
            Image(systemName: "clock.arrow.circlepath")
        case .notLoaded:
            Image(systemName: "circle.dotted")
        case .failed:
            Image(systemName: "xmark.circle.fill")
        }
    }

    func makeSectionHeader() -> some View {
        HStack {
            Text("Assets:")
            Spacer()
            Button {
                // TODO: Show alert.
                viewModel.onClearAssetsRequested()
            } label: {
                Image(systemName: "clear.fill")
            }
        }
    }
}

// TODO: Enable preview and use Preview dependencies.
// #Preview {
//    AssetsListView(
//        viewModel: AssetsListViewModel(assetsProvider: LiveAssetsManager()),
//        router: LiveNavigationRouter()
//    )
// }
