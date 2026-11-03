//
//  HomeView.swift
//  Woolworths-SwipeShop
//
//  Figma: "Page 1" / "Page 2" — Woolworths home with the Personalised Bundles entry point.
//

import SwiftUI

enum FulfilmentMode: String, CaseIterable, Identifiable {
    case pickUp = "Pick up"
    case delivery = "Delivery"
    case inStore = "In-store"

    var id: Self { self }
}

struct HomeView: View {
    @Environment(AppModel.self) private var model
    @State private var mode: FulfilmentMode = .delivery

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                topBar
                    .padding(.top, 11)

                Text("Set a delivery address")
                    .font(.app(12.6))
                    .foregroundStyle(Palette.grey555)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 38)

                searchRow
                    .padding(.top, 27)

                categories
                    .padding(.top, 22)

                rewardsRow
                    .padding(.top, 14)

                promotions
                    .padding(.top, 28.3)

                VStack(alignment: .leading, spacing: 2) {
                    Text("More ways to save and earn")
                        .font(.app(19.9, .semibold))
                        .foregroundStyle(Color(hex: 0xBBBBBB))
                    Text("Top Specials and Online Boosts on what you love")
                        .font(.app(12.6))
                        .foregroundStyle(Color(hex: 0xCCCCCC))
                }
                .padding(.top, 26)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 15.75)
        }
        .scrollIndicators(.hidden)
        .background(.white)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: Fulfilment + account

    private var topBar: some View {
        HStack(spacing: 0) {
            HStack(spacing: 8) {
                ForEach(FulfilmentMode.allCases) { option in
                    Button {
                        mode = option
                    } label: {
                        let selected = option == mode
                        HStack(spacing: 3.15) {
                            Text(option.rawValue)
                                .font(.app(13.6, .semibold))
                                .lineLimit(1)
                                .fixedSize()
                            Image("chevron-down-grey")
                                .resizable()
                                .frame(width: selected ? 11.5 : 10.5, height: selected ? 11.5 : 10.5)
                        }
                        .foregroundStyle(selected ? .white : Palette.grey555)
                        .padding(.horizontal, selected ? 12 : 0)
                        .frame(height: 40.9)
                        .background(selected ? Palette.greenAlt : .clear, in: .capsule)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.leading, 8.6)

            Spacer(minLength: 8)

            HStack(spacing: 20) {
                Image("icon-message")
                Button {
                    model.openCart()
                } label: {
                    CartIcon(count: model.cartCount)
                }
                .buttonStyle(.plain)
            }
            .frame(width: 105, height: 45.1)
            .background(.white, in: .capsule)
            .shadow(color: .black.opacity(0.04), radius: 15.7, y: 8.4)
        }
    }

    // MARK: Search

    private var searchRow: some View {
        HStack(spacing: 12.6) {
            HStack(spacing: 10.5) {
                Image("icon-search")
                Text("Search products")
                    .font(.app(15.75))
                    .foregroundStyle(Color(hex: 0x707070))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image("icon-scan-barcode")
            }
            .padding(.horizontal, 13.6)
            .frame(height: 45.1)
            .background(Color(hex: 0xFDFDFD), in: .capsule)
            .shadow(color: .black.opacity(0.04), radius: 15.7, y: 8.4)

            ArtworkCrop.home(x: 347.5, y: 185.83, width: 40.94, height: 45.14)
        }
    }

    // MARK: Categories

    private var categories: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8.4) {
                CategoryCard(title: "Smart Basket") {
                    ArtworkCrop.home(x: 30.45, y: 264.57, width: 65.09, height: 65.09)
                }
                CategoryCard(title: "Weekly\nCatalogue") {
                    ArtworkCrop.home(x: 137.53, y: 264.57, width: 65.09, height: 65.09)
                }
                CategoryCard(title: "Half Price\nSpecials") {
                    ArtworkCrop.home(x: 243.57, y: 264.57, width: 65.09, height: 65.09)
                }
                CategoryCard(title: "Free Food\nContainers") {
                    ZStack(alignment: .topLeading) {
                        Image("bundles-ellipse")
                            .offset(x: 1.03, y: 3.43)
                        ArtworkCrop.home(x: 350.65, y: 264.57, width: 65.09, height: 65.09)
                    }
                    .frame(width: 65.09, height: 65.09, alignment: .topLeading)
                    .clipped()
                }
                Button {
                    model.path.append(.bundles)
                } label: {
                    CategoryCard(title: "Personalised\nBundles") {
                        ZStack(alignment: .topLeading) {
                            Image("bundles-ellipse")
                            Image("bundles-category-icon")
                                .offset(x: 8, y: 13)
                        }
                        .frame(width: 59, height: 59, alignment: .topLeading)
                        .padding(.top, 3)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }

    // MARK: Rewards

    private var rewardsRow: some View {
        HStack(spacing: 9.45) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline) {
                    Text("4 of 12 offers boosted ›")
                        .font(.app(13.6, .semibold))
                        .foregroundStyle(Palette.grey555)
                    Spacer()
                    (Text("172").font(.app(13.6, .bold)).foregroundStyle(Palette.inkStrong)
                     + Text(" / 2000").font(.app(10.5)).foregroundStyle(Palette.grey555))
                }
                .padding(.top, 7.35)

                ProgressView(value: 172, total: 2000)
                    .progressViewStyle(RewardsProgressStyle())
                    .padding(.top, 13)

                (Text("1828").font(.app(10.5, .semibold)).foregroundStyle(Palette.rewards)
                 + Text(" more points to collect your reward").font(.app(10.5)).foregroundStyle(Palette.grey555))
                    .padding(.top, 4.2)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10.5)
            .frame(height: 69.3)
            .background(.white, in: .rect(cornerRadius: 12.6))
            .shadow(color: .black.opacity(0.07), radius: 2.6, y: 2.1)

            VStack(spacing: 8.4) {
                Text("r")
                    .font(.system(size: 19.9, weight: .black).italic())
                    .foregroundStyle(.white)
                    .frame(width: 33.6, height: 21)
                    .background(Palette.rewardsLogo, in: .rect(cornerRadius: 4.2))
                Text("Show\nCard")
                    .font(.app(10.5))
                    .foregroundStyle(Palette.grey555)
                    .multilineTextAlignment(.center)
                    .lineSpacing(0)
            }
            .padding(.top, 7.35)
            .frame(width: 66.1, height: 69.3, alignment: .top)
            .background(.white, in: .rect(cornerRadius: 12.6))
            .shadow(color: .black.opacity(0.07), radius: 2.6, y: 2.1)
        }
    }

    // MARK: Promotions

    private var promotions: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 16.8) {
                VStack(alignment: .leading, spacing: 0) {
                    ArtworkCrop.home(x: 15.75, y: 507.08, width: 343.3, height: 171.13)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Buy 1 Get 1 Bonus Credit")
                            .font(.app(21, .bold))
                            .tracking(-0.63)
                            .padding(.top, 4.2)
                        Text("Buy ONE of these participating products in\na $20 shop^")
                            .font(.app(14.7))
                            .lineSpacing(1.5)
                            .padding(.top, 11)
                        Text("^T&Cs apply. While stocks last.")
                            .font(.app(11.5))
                            .foregroundStyle(Color(hex: 0xE6EFE6))
                            .padding(.top, 9)
                    }
                    .padding(.horizontal, 12.6)
                    Spacer(minLength: 0)
                }
                .foregroundStyle(.white)
                .frame(width: 343.3, height: 287.66, alignment: .topLeading)
                .background(Palette.greenDeep)
                .clipShape(.rect(cornerRadius: 10.5))

                ArtworkCrop.home(x: 375.85, y: 507.08, width: 27.3, height: 287.66)
            }
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }
}

private struct CategoryCard<Artwork: View>: View {
    let title: String
    @ViewBuilder let artwork: Artwork

    var body: some View {
        VStack(spacing: 0) {
            artwork
                .frame(width: 65.09, height: 65.09)
                .padding(.top, 11.55)
            Text(title)
                .font(.app(12.6))
                .foregroundStyle(Palette.inkStrong)
                .multilineTextAlignment(.center)
                .lineSpacing(1.8)
                .frame(maxHeight: .infinity)
                .padding(.bottom, 4)
        }
        .frame(width: 97.64, height: 118.63)
        .background(Palette.cardFill, in: .rect(cornerRadius: 12.6))
    }
}

private struct RewardsProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Color(hex: 0xE8E8E8))
                Capsule().fill(Palette.rewards)
                    .frame(width: max(24, proxy.size.width * (configuration.fractionCompleted ?? 0)))
            }
        }
        .frame(height: 6.3)
    }
}

#Preview {
    NavigationStack { HomeView() }
        .environment(AppModel())
}
