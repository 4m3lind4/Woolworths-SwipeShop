//
//  NewParentsView.swift
//  Woolworths-SwipeShop
//
//  Figma: "Page" — New Parents bundles grouped by need.
//

import SwiftUI

struct NewParentsView: View {
    @Environment(AppModel.self) private var model
    @State private var filter: NewParentsFilter = .all

    private var visibleCategories: [BundleCategory] {
        guard let id = filter.categoryID else { return BundleCategory.newParents }
        return BundleCategory.newParents.filter { $0.id == id }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20.5) {
                chips

                ForEach(visibleCategories) { category in
                    VStack(alignment: .leading, spacing: 10.3) {
                        SectionHeader(title: category.title)
                            .padding(.horizontal, 16.4)
                        ScrollView(.horizontal) {
                            HStack(alignment: .top, spacing: 10.3) {
                                ForEach(category.bundles) { bundle in
                                    card(for: bundle, in: category)
                                }
                            }
                            .padding(.horizontal, 16.4)
                        }
                        .scrollIndicators(.hidden)
                    }
                }

                HStack(spacing: 10.3) {
                    Image("icon-swap")
                    Text("Bundles are a starting point. Swap brands or sizes on the next screen.")
                        .font(.app(13.3))
                        .foregroundStyle(Color(hex: 0x444444))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(12.3)
                .background(Palette.chipFill, in: .rect(cornerRadius: 12.3))
                .padding(.horizontal, 16.4)
            }
            .padding(.top, 12.3)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(.white)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ScreenTitle(title: "New Parents")
            CartToolbarItem()
        }
    }

    private var chips: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8.2) {
                ForEach(NewParentsFilter.allCases) { option in
                    let selected = option == filter
                    Button {
                        withAnimation(.snappy) { filter = option }
                    } label: {
                        Text(option.rawValue)
                            .font(.app(14.4, selected ? .semibold : .medium))
                            .foregroundStyle(selected ? .white : Palette.ink)
                            .padding(.horizontal, 14.4)
                            .padding(.vertical, 9.2)
                            .background(selected ? Palette.green : Palette.chipFill, in: .capsule)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16.4)
        }
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    private func card(for bundle: ParentBundle, in category: BundleCategory) -> some View {
        let card = BundleCard(bundle: bundle, tint: category.tint, icon: category.icon) {
            model.cartCount += 1
        }
        if bundle.opensDetail {
            // A gesture rather than a Button so the card's own "+" button keeps its taps.
            card
                .onTapGesture { model.path.append(.bundleDetail) }
                .accessibilityAddTraits(.isButton)
        } else {
            card
        }
    }
}

private struct BundleCard: View {
    let bundle: ParentBundle
    let tint: Color
    let icon: String
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Figma places the 24.6pt glyph at the top-left of a 45pt box centred in the image well.
            Image(icon)
                .frame(width: 45.1, height: 45.1, alignment: .topLeading)
                .frame(maxWidth: .infinity)
                .frame(height: 98.5)
                .background(tint)

            VStack(alignment: .leading, spacing: 4.1) {
                Text(bundle.name)
                    .font(.app(14.4, .semibold))
                    .foregroundStyle(Palette.ink)
                    .lineSpacing(1)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(bundle.itemCount) items")
                    .font(.app(12.3))
                    .foregroundStyle(Palette.muted)
                HStack {
                    Text(bundle.price.currency)
                        .font(.app(15.4, .bold))
                        .foregroundStyle(Palette.ink)
                    Spacer()
                    Button(action: onAdd) {
                        Image("icon-plus")
                            .frame(width: 30.8, height: 30.8)
                            .background(Palette.green, in: .circle)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Add \(bundle.name) to cart")
                }
            }
            .padding(10.3)

            Spacer(minLength: 0)
        }
        .frame(width: 153.9, height: 205.2)
        .background(.white)
        .clipShape(.rect(cornerRadius: 14.4))
        .overlay(RoundedRectangle(cornerRadius: 14.4).stroke(Palette.border, lineWidth: 1))
        .contentShape(.rect(cornerRadius: 14.4))
    }
}

#Preview {
    NavigationStack { NewParentsView() }
        .environment(AppModel())
}
