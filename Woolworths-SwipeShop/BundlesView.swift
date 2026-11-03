//
//  BundlesView.swift
//  Woolworths-SwipeShop
//
//  Figma: "Page - 3" — Personalised Bundles landing with the shopper-type grid.
//

import SwiftUI

struct BundlesView: View {
    @Environment(AppModel.self) private var model

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 3.5), count: 3)

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                    .padding(.horizontal, 3.5)
                madeForYou
                    .padding(.top, 7)
                LazyVGrid(columns: columns, spacing: 3.5) {
                    ForEach(ShopperTile.all) { tile in
                        if tile.opensNewParents {
                            Button {
                                model.path.append(.newParents)
                            } label: {
                                ShopperTileView(tile: tile)
                            }
                            .buttonStyle(.plain)
                        } else {
                            ShopperTileView(tile: tile)
                        }
                    }
                }
                .padding(.top, 3)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 17.5)
            .padding(.top, 12)
        }
        .scrollIndicators(.hidden)
        .background(.white)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ScreenTitle(title: "Bundles")
            CartToolbarItem()
        }
    }

    private var hero: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [Color(hex: 0x3E884A), Color(hex: 0x194925)],
                startPoint: UnitPoint(x: 0.1, y: 0),
                endPoint: UnitPoint(x: 0.9, y: 1)
            )

            VStack(alignment: .leading, spacing: 0) {
                Text("Personalised Bundles")
                    .font(.app(24.5, .heavy))
                    .tracking(-0.56)
                Group {
                    Text("We know ") + Text("how hard life").bold() + Text(" can be tap on the category you fit best")
                }
                .font(.app(14.1))
                .tracking(-0.32)
                .frame(width: 186.7, alignment: .leading)
                .padding(.top, 7)
                Text("The just swipe to add the right product")
                    .font(.app(14.1, .bold))
                    .tracking(-0.32)
                    .frame(width: 186.7, alignment: .leading)
                    .padding(.top, 14.7)
            }
            .foregroundStyle(.white)
            .padding(.leading, 22)
            .padding(.top, 36.7)

            SwipeShopLogo()
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 2)
                .padding(.top, 47)
        }
        .frame(height: 217)
        .clipShape(.rect(cornerRadius: 7))
    }

    private var madeForYou: some View {
        ZStack(alignment: .topLeading) {
            Palette.tileFill
            Text("ADD IMAGE")
                .frame(maxWidth: .infinity)
                .padding(.top, 80)
            Text("Made for you")
                .padding(.leading, 8.8)
                .padding(.top, 169)
        }
        .font(.app(15.5, .heavy))
        .tracking(-0.35)
        .foregroundStyle(Palette.greenInk)
        .frame(height: 235)
        .clipShape(.rect(cornerRadius: 7))
    }
}

/// Stacked swipe cards with a cart — the Swipe Shop mark from the hero.
struct SwipeShopLogo: View {
    var body: some View {
        ZStack {
            card.opacity(0.25).rotationEffect(.degrees(10)).position(x: 41.45, y: 62.66)
            card.opacity(0.45).rotationEffect(.degrees(2)).position(x: 56.92, y: 64.14)
            card.rotationEffect(.degrees(-8)).position(x: 73.12, y: 63.53)
            Image("logo-cart")
                .rotationEffect(.degrees(-10.08))
                .position(x: 73.09, y: 64.17)
        }
        .frame(width: 114.17, height: 124.74)
        .accessibilityHidden(true)
    }

    private var card: some View {
        RoundedRectangle(cornerRadius: 9.18)
            .fill(.white)
            .frame(width: 62.95, height: 83.93)
    }
}

// MARK: - Shopper tiles

struct PhotoPiece {
    /// Top-left of the (unrotated) piece inside the tile.
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
    let sourceX: CGFloat
    let sourceY: CGFloat
    var rotation: Double = 0
    /// For rotated pieces, the centre of their bounding box inside the tile.
    var center: CGPoint? = nil
}

struct ShopperTile: Identifiable {
    var id: String { title }
    let title: String
    var textLeading: CGFloat = 7.8
    var textTop: CGFloat = 41
    var opensNewParents = false
    let pieces: [PhotoPiece]

    static let all: [ShopperTile] = [
        ShopperTile(title: "New \nParents", opensNewParents: true, pieces: [
            PhotoPiece(x: 67.5, y: -2.08, width: 66.42, height: 60.07, sourceX: 204.93, sourceY: 478.4),
        ]),
        ShopperTile(title: "Expecting Parents", pieces: [
            PhotoPiece(x: 23.32, y: 0, width: 47.35, height: 31.8, sourceX: 169.59, sourceY: 297.5),
            PhotoPiece(x: 70.66, y: 0, width: 54.41, height: 85.5, sourceX: 216.94, sourceY: 297.5),
        ]),
        ShopperTile(title: "Students", textLeading: 6.65, textTop: 55.1, pieces: [
            PhotoPiece(x: 0, y: 0, width: 68.54, height: 85.5, sourceX: 331.42, sourceY: 297.5,
                       rotation: -58.37, center: CGPoint(x: 34.61 + 54.38, y: -41.6 + 51.6)),
        ]),
        ShopperTile(title: "Busy Workers", pieces: [
            PhotoPiece(x: 58.65, y: -14, width: 63.6, height: 64.3, sourceX: 78.44, sourceY: 387.24),
        ]),
        ShopperTile(title: "Remote Workers", textTop: 40.5, pieces: [
            PhotoPiece(x: 16.96, y: 0, width: 41.69, height: 34.63, sourceX: 163.23, sourceY: 387.24),
            PhotoPiece(x: 58.65, y: 0, width: 66.42, height: 61.48, sourceX: 204.93, sourceY: 387.24),
        ]),
        ShopperTile(title: "Senior\nShoppers", textTop: 38.4, pieces: [
            PhotoPiece(x: 70.66, y: 0, width: 54.41, height: 86.21, sourceX: 345.55, sourceY: 387.24),
        ]),
        ShopperTile(title: "Health\nConcious", textTop: 40, pieces: [
            PhotoPiece(x: 84.09, y: 46.64, width: 40.99, height: 38.87, sourceX: 101.05, sourceY: 525.04),
            PhotoPiece(x: 77.73, y: 26.15, width: 47.35, height: 20.49, sourceX: 94.69, sourceY: 504.54),
            PhotoPiece(x: 67.13, y: 0, width: 57.95, height: 26.15, sourceX: 84.09, sourceY: 478.4),
        ]),
        ShopperTile(title: "Vegetarian &\nVegans", textLeading: 8.1, textTop: 40.5, pieces: [
            PhotoPiece(x: 0, y: 0, width: 58, height: 86, sourceX: 76.32, sourceY: 297.5,
                       rotation: -75.16, center: CGPoint(x: 44.14 + 49, y: -28 + 39.05)),
        ]),
        ShopperTile(title: "Pet\nParents", textLeading: 10, textTop: 40, pieces: [
            PhotoPiece(x: 24.73, y: 0, width: 43.81, height: 26.85, sourceX: 298.91, sourceY: 478.4),
            PhotoPiece(x: 68.54, y: -10.3, width: 56.53, height: 64.3, sourceX: 343.43, sourceY: 478.4),
        ]),
    ]
}

private struct ShopperTileView: View {
    let tile: ShopperTile

    var body: some View {
        ZStack(alignment: .topLeading) {
            Palette.tileFill

            Text(tile.title)
                .font(.app(15.5, .heavy))
                .tracking(-0.35)
                .lineSpacing(0)
                .foregroundStyle(Palette.greenInk)
                .frame(width: 101.8, alignment: .leading)
                .padding(.leading, tile.textLeading)
                .padding(.top, tile.textTop)

            ForEach(Array(tile.pieces.enumerated()), id: \.offset) { _, piece in
                let center = piece.center
                    ?? CGPoint(x: piece.x + piece.width / 2, y: piece.y + piece.height / 2)
                ArtworkCrop.bundles(x: piece.sourceX, y: piece.sourceY, width: piece.width, height: piece.height)
                    .rotationEffect(.degrees(piece.rotation))
                    .position(center)
            }
        }
        .frame(height: 83)
        .clipShape(.rect(cornerRadius: 7))
        .contentShape(.rect(cornerRadius: 7))
    }
}

#Preview {
    NavigationStack { BundlesView() }
        .environment(AppModel())
}
