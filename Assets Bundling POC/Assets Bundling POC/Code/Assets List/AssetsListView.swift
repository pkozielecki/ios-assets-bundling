//
//  AssetsListView.swift
//  Assets Bundling POC
//

import SwiftUI

struct AssetsListView: View {
    let viewModel: AssetsListViewModel

    var body: some View {
        ZStack {
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

    func makeSectionHeader() -> some View {
        HStack {
            Text("Assets:")
            Spacer()
            Button {
                viewModel.onClearAssetsRequested()
            } label: {
                Image(systemName: "clear.fill")
            }
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
    return AssetsListView(viewModel: model)
}
