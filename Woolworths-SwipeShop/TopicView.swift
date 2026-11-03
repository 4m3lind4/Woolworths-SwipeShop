//
//  TopicView.swift
//  Woolworths-SwipeShop
//
//  Figma: "Page" (New Parents) — a shopper topic's bundles grouped by category.
//  Every topic on the Bundles grid uses this screen.
//

import SwiftUI

struct TopicView: View {
    @Environment(AppModel.self) private var model
    let topic: Topic
    /// The selected category chip; `nil` shows every category.
    @State private var filter: TopicCategory.ID?

    private var visibleCategories: [TopicCategory] {
        guard let filter else { return topic.categories }
        return topic.categories.filter { $0.id == filter }
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
                                    Button {
                                        model.path.append(.bundleDetail(bundle.id))
                                    } label: {
                                        BundleCard(bundle: bundle)
                                    }
                                    .buttonStyle(.plain)
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
            ScreenTitle(title: topic.title)
            CartToolbarItem()
        }
    }

    private var chips: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8.2) {
                chip("All", selected: filter == nil) { filter = nil }
                ForEach(topic.categories) { category in
                    chip(category.title, selected: filter == category.id) { filter = category.id }
                }
            }
            .padding(.horizontal, 16.4)
        }
        .scrollIndicators(.hidden)
    }

    private func chip(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.snappy, action)
        } label: {
            Text(title)
                .font(.app(14.4, selected ? .semibold : .medium))
                .foregroundStyle(selected ? .white : Palette.ink)
                .padding(.horizontal, 14.4)
                .padding(.vertical, 9.2)
                .background(selected ? Palette.green : Palette.chipFill, in: .capsule)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

private struct BundleCard: View {
    let bundle: ShopBundle

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
                    } else {
                        ProductCollage(images: Array(bundle.previewImages.prefix(3)), size: 62)
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
                Text("\(bundle.items.count) items")
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
    NavigationStack { TopicView(topic: Topic.all[0]) }
        .environment(AppModel())
}
