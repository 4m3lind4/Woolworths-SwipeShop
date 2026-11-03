//
//  ContentView.swift
//  Woolworths-SwipeShop
//
//  Created by Jessica Amelinda Mang on 3/11/2026.
//

import SwiftUI

enum AppTab: Hashable {
    case home, lists, products, specials, more
}

struct ContentView: View {
    @State private var model = AppModel()
    @State private var selection: AppTab = .home

    var body: some View {
        TabView(selection: $selection) {
            Tab("Home", image: "tab-home", value: .home) {
                NavigationStack(path: $model.path) {
                    HomeView()
                        .navigationDestination(for: Route.self) { route in
                            switch route {
                            case .bundles: BundlesView()
                            case .newParents: NewParentsView()
                            case .bundleDetail: BundleDetailView()
                            case .customBundle: CustomBundleView()
                            }
                        }
                }
            }
            Tab("Lists", image: "tab-lists", value: .lists) {
                ContentUnavailableView("Lists", image: "tab-lists")
            }
            Tab("Products", image: "tab-products", value: .products) {
                ContentUnavailableView("Products", image: "tab-products")
            }
            Tab("Specials", image: "tab-specials", value: .specials) {
                ContentUnavailableView("Specials", image: "tab-specials")
            }
            Tab("More", image: "tab-more", value: .more) {
                ContentUnavailableView("More", image: "tab-more")
            }
        }
        .environment(model)
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
