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
                            case .topic(let id):
                                if let topic = Topic.find(id) { TopicView(topic: topic) }
                            case .bundleDetail(let id):
                                if let bundle = ShopBundle.find(id) { BundleDetailView(bundle: bundle) }
                            case .customBundle: CustomBundleView()
                            case .cart: CartView()
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
