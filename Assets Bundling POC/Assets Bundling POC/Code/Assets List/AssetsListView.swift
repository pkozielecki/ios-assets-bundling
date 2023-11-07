//
//  AssetsListView.swift
//  Assets Bundling POC
//

import SwiftUI

struct AssetsListView: View {
    let viewModel: AssetsListViewModel
    let router: NavigationRouter

    var body: some View {
        List {
            Section(header: makeSectionHeader()) {
                ForEach(viewModel.viewState.assets, id: \.self) { data in
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
                    }
                }
            }
        }
        .listStyle(.grouped)
        .onAppear {
            viewModel.onViewAppeared()
        }
    }
}

private extension AssetsListView {

    func makeImage(for assetState: AssetListViewRowData.State) -> Image {
        switch assetState {
        case .loaded:
            Image(systemName: "checkmark.circle.fill")
        case .loading:
            Image(systemName: "clock.arrow.circlepath")
        case .notLoaded:
            Image(systemName: "circle.dotted")
        }
    }

    func makeSectionHeader() -> some View {
        HStack {
            Text("Assets:")
            Spacer()
            Button {
                // TODO: Clear assets:
                print("clear assets")
            } label: {
                Image(systemName: "clear.fill")
            }
        }
    }
}

#Preview {
    AssetsListView(
        viewModel: AssetsListViewModel(),
        router: LiveNavigationRouter()
    )
}
