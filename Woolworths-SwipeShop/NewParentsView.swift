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
        if bundle.opensDetail {
            Button {
                model.path.append(.bundleDetail)
            } label: {
                BundleCard(bundle: bundle)
            }
            .buttonStyle(.plain)
        } else {
            BundleCard(bundle: bundle)
        }
    }
}

private struct BundleCard: View {
    let bundle: ParentBundle

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color(.systemGray6)
                .frame(height: 112)
                .overlay {
                    if let image = bundle.image {
                        Image(image)
                            .resizable()
                            .scaledToFill()
                            .allowsHitTesting(false)
                    }
                }
                .clipped()
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4.1) {
                Text(bundle.name)
                    .font(.app(14.4, .semibold))
                    .foregroundStyle(Palette.ink)
                    .lineSpacing(1)
                    .lineLimit(2, reservesSpace: true)
                Text("\(bundle.itemCount) items")
                    .font(.app(12.3))
                    .foregroundStyle(Palette.muted)
            }
            .padding(10.3)
        }
        .frame(width: 153.9)
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
