//
//  BundleDetailView.swift
//  Woolworths-SwipeShop
//
//  Figma: "New Parents Bundles" — Nappy Change Essentials before swiping.
//

import SwiftUI

struct BundleDetailView: View {
    @Environment(AppModel.self) private var model
    @State private var selected: Set<String> = []
    @State private var isSwiping = false

    /// Products to swipe: those for the ticked rows, or the whole bundle when nothing is ticked.
    private var deck: [SwipeProduct] {
        let all = SwipeProduct.nappyChangeEssentials
        return selected.isEmpty ? all : all.filter { selected.contains($0.bundleItem) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10.3) {
                SectionHeader(title: "Personalised")

                PersonalisedCard(imageCaption: "ADD IMAGE RELATED TO\nNAPPIES") {
                    ForEach(SwipeProduct.bundleItems, id: \.self) { item in
                        Button {
                            if selected.contains(item) { selected.remove(item) } else { selected.insert(item) }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: selected.contains(item) ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 20, weight: .light))
                                    .foregroundStyle(selected.contains(item) ? Palette.green : Color(.tertiaryLabel))
                                Text(item)
                                    .font(.caption2)
                                    .foregroundStyle(Palette.ink)
                                Spacer()
                            }
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(selected.contains(item) ? .isSelected : [])
                        Divider()
                    }
                } footer: {
                    Button {
                        selected = selected.count == SwipeProduct.bundleItems.count
                            ? [] : Set(SwipeProduct.bundleItems)
                    } label: {
                        EditItemsLabel()
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button {
                        isSwiping = true
                    } label: {
                        HStack(spacing: 6.2) {
                            Text("Swipe shop")
                                .font(.app(13.4, .semibold))
                            Image("arrow-right-white")
                        }
                        .foregroundStyle(.white)
                        .frame(width: 128, height: 30)
                        .background(Palette.green, in: .capsule)
                    }
                    .buttonStyle(.plain)
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
            ScreenTitle(title: "Nappy Change Essentials")
            CartToolbarItem()
        }
        .fullScreenCover(isPresented: $isSwiping) {
            SwipeShopView(products: deck) { loved in
                isSwiping = false
                model.finishSwiping(with: loved)
            }
        }
    }
}

/// The white "Bundle Selected" card shared by the bundle and custom-bundle screens.
struct PersonalisedCard<Rows: View, Footer: View>: View {
    var imageCaption: String? = nil
    @ViewBuilder let rows: Rows
    @ViewBuilder let footer: Footer

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                Color(hex: 0xE3F0FA)
                if let imageCaption {
                    Text(imageCaption)
                        .font(.app(15.5, .heavy))
                        .tracking(-0.35)
                        .foregroundStyle(Palette.greenInk)
                        .multilineTextAlignment(.center)
                        .padding(.top, 59.5)
                }
            }
            .frame(height: 150)

            VStack(alignment: .leading, spacing: 10) {
                rows
            }
            .frame(maxWidth: .infinity, minHeight: 350, alignment: .top)
            .padding(10)
            .padding(.horizontal, 15)
            .padding(.top, 15)

            HStack { footer }
                .padding(.horizontal, 15)
                .padding(.bottom, 17)
        }
        .frame(minHeight: 582, alignment: .top)
        .background(.white)
        .clipShape(.rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Palette.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.25), radius: 1, y: 2)
    }
}

struct EditItemsLabel: View {
    var body: some View {
        HStack(spacing: 4) {
            Text("Edit Items")
                .font(.app(12, .bold))
            Image("icon-pencil")
        }
        .foregroundStyle(Palette.green)
        .frame(width: 110, height: 30)
        .background(Color(hex: 0xEBEBEB), in: .capsule)
        .overlay(Capsule().stroke(Palette.green, style: StrokeStyle(lineWidth: 1, dash: [2, 2])))
    }
}

#Preview {
    NavigationStack { BundleDetailView() }
        .environment(AppModel())
}
