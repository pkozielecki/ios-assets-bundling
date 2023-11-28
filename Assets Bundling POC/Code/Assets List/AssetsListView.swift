//
//  AssetsListView.swift
//  Assets Bundling POC
//

import SwiftUI

struct AssetsListView: View {
    let viewModel: AssetsListViewModel

    var body: some View {
        ZStack {

            // MARK: List with assets

            List {
                Section(header: makeSectionHeader()) {
                    ForEach(assets, id: \.self) { data in
                        Button {
                            viewModel.onAssetSelected(data.id)
                        } label: {
                            AssetListRowView(data: data)
                        }
                    }
                }
            }
            .listStyle(.grouped)
            .opacity(assets.isEmpty ? 0.5 : 1)
            .refreshable {
                viewModel.onReloadRequested()
            }

            // MARK: Reload button

            Button {
                viewModel.onReloadRequested()
            } label: {
                Text("No assets loaded\nTap to reload")
                    .font(.title)
            }
            .opacity(shouldShowReloadButton ? 1 : 0)
            .animation(.easeIn, value: viewState)

            // MARK: Loading indicator

            if isLoading {
                LoaderView(configuration: .default)
                    .animation(.easeIn, value: viewState)
            }
        }
        .onAppear {
            viewModel.onViewAppeared()
        }
    }
}

private extension AssetsListView {

    var viewState: AssetsListViewState {
        viewModel.viewState
    }

    var isLoading: Bool {
        viewState == .loading
    }

    var shouldShowReloadButton: Bool {
        assets.isEmpty && !isLoading
    }

    var assets: [AssetListViewRowData] {
        if case let .loaded(assetsListRows) = viewModel.viewState {
            return assetsListRows
        }
        return []
    }

    func makeSectionHeader() -> some View {
        HStack {
            Text("Assets:")
            Spacer()
            Button {
                viewModel.onClearAssetsRequested()
            } label: {
                Image(systemName: "clear.fill")
            }
            .opacity(shouldShowReloadButton ? 0 : 1)
        }
    }
}

#Preview {
    let model = PreviewAssetListViewModel()
    let assetListRows: [AssetListViewRowData] = [
        .init(id: "abc", state: .loading(0.5), name: "asset1"),
        .init(id: "def", state: .loaded, name: "asset2"),
        .init(id: "zxy", state: .failed, name: "asset3"),
        .init(id: "uio", state: .notLoaded, name: "asset4"),
        .init(id: "ert", state: .toBeTransferred, name: "asset5")
    ]
    model.viewState = .loaded(assetsListRows: assetListRows)
//    model.viewState = .loading
//    model.viewState = .noAssets
    return AssetsListView(viewModel: model)
}
