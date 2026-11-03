//
//  Theme.swift
//  Woolworths-SwipeShop
//

import SwiftUI

/// Colours lifted from the "Woolworths Swipe Shop Features" Figma section.
enum Palette {
    static let green = Color.accentColor                  // #3A8B3E
    static let greenAlt = Color(hex: 0x3E884A)
    static let greenDeep = Color(hex: 0x1D4827)
    static let greenInk = Color(hex: 0x004A18)
    static let ink = Color(hex: 0x1A1A1A)
    static let inkStrong = Color(hex: 0x111111)
    static let muted = Color(hex: 0x6B6B6B)
    static let grey555 = Color(hex: 0x555555)
    static let chipFill = Color(hex: 0xF3F3F3)
    static let cardFill = Color(hex: 0xF4F4F4)
    static let tileFill = Color(hex: 0xF3F4F6)
    static let border = Color(hex: 0xE6E6E6)
    static let rewards = Color(hex: 0xC64D20)
    static let rewardsLogo = Color(hex: 0xF57622)
    static let points = Color(hex: 0xE35205)
    static let success = Color(hex: 0x1E9E5A)
    static let swipeBackground = Color(hex: 0xF2F2F2)
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

extension Font {
    /// The Figma file sets most screens in Inter; this uses the system font at the same metrics.
    static func app(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }
}

/// Shows a region of a full-screen artwork, the same way the Figma frames crop "Original artwork".
struct ArtworkCrop: View {
    let image: String
    let canvas: CGSize
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Image(image)
            .resizable()
            .frame(width: canvas.width, height: canvas.height)
            .offset(x: -x, y: -y)
            .frame(width: width, height: height, alignment: .topLeading)
            .clipped()
            // The clipped-away overflow still hit-tests, so let touches fall through to the card.
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

extension ArtworkCrop {
    static let homeCanvas = CGSize(width: 403.147, height: 874)
    static let bundlesCanvas = CGSize(width: 416.919, height: 904.502)

    static func home(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> ArtworkCrop {
        ArtworkCrop(image: "home-artwork", canvas: homeCanvas, x: x, y: y, width: width, height: height)
    }

    static func bundles(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> ArtworkCrop {
        ArtworkCrop(image: "bundles-photography", canvas: bundlesCanvas, x: x, y: y, width: width, height: height)
    }
}

/// Green cart used in the trailing slot of every pushed screen's toolbar.
struct CartToolbarItem: ToolbarContent {
    @Environment(AppModel.self) private var model

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Image("icon-cart-green")
                .frame(width: 34, height: 34)
                // Drawn inside the button's bounds so the glass background doesn't clip it.
                .overlay(alignment: .topTrailing) {
                    if model.cartCount > 0 {
                        Text("\(model.cartCount)")
                            .font(.app(9, .bold))
                            .foregroundStyle(.white)
                            .frame(minWidth: 14, minHeight: 14)
                            .background(Palette.points, in: .capsule)
                    }
                }
                .accessibilityLabel("Cart, \(model.cartCount) items")
        }
    }
}

/// Centered bold title matching the Figma header (20.5pt bold).
struct ScreenTitle: ToolbarContent {
    let title: String

    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(title)
                .font(.app(20.5, .bold))
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
        }
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.app(18.5, .semibold))
                .foregroundStyle(Palette.ink)
            Spacer()
            Text("See all")
                .font(.app(14.4, .medium))
                .foregroundStyle(Palette.green)
        }
    }
}
