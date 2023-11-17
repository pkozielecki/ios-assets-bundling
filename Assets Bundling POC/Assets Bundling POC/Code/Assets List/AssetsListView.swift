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

// TODO: Enable preview and use Preview dependencies.
// #Preview {
//    AssetsListView(
//        viewModel: AssetsListViewModel(assetsProvider: LiveAssetsManager()),
//        router: LiveNavigationRouter()
//    )
// }
