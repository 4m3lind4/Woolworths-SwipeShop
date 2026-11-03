//
//  CustomBundleView.swift
//  Woolworths-SwipeShop
//
//  Figma: "Final" — the shopper's custom bundle after swiping.
//

import SwiftUI

struct CustomBundleView: View {
    @Environment(AppModel.self) private var model
    @State private var isSwiping = false

    private var total: Double { model.customBundle.reduce(0) { $0 + $1.price } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10.3) {
                SectionHeader(title: "Personalised")

                PersonalisedCard {
                    ForEach(model.customBundle) { product in
                        HStack(spacing: 10) {
                            Text(product.name)
                                .font(.caption2)
                                .foregroundStyle(Palette.ink)
                            Spacer()
                            Text("x1")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(product.price.currency)
                                .font(.caption2)
                                .foregroundStyle(Palette.ink)
                        }
                        .padding(.vertical, 4)
                        Divider()
                    }
                    if model.customBundle.isEmpty {
                        Text("You didn't keep any items. Tap Edit Items to swipe again.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("TOTAL")
                        Spacer()
                        Text(total.currency)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Palette.ink)
                    .padding(.vertical, 4)
                } footer: {
                    Button {
                        isSwiping = true
                    } label: {
                        EditItemsLabel()
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button {
                        model.addCustomBundleToCart()
                    } label: {
                        HStack(spacing: 0) {
                            Image("icon-plus")
                            Text("Add to Cart")
                                .font(.app(12, .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(width: 122, height: 30)
                        .background(Palette.green, in: .capsule)
                    }
                    .buttonStyle(.plain)
                    .disabled(model.customBundle.isEmpty)
                }
            }
            .padding(.horizontal, 16.4)
            .padding(.top, 12.3)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(.white)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ScreenTitle(title: "Custom Bundle 1")
            CartToolbarItem()
        }
        .fullScreenCover(isPresented: $isSwiping) {
            SwipeShopView(products: SwipeProduct.nappyChangeEssentials) { loved in
                isSwiping = false
                model.customBundle = loved
            }
        }
    }
}

#Preview {
    let model = AppModel()
    model.customBundle = SwipeProduct.nappyChangeEssentials
    return NavigationStack { CustomBundleView() }
        .environment(model)
}
