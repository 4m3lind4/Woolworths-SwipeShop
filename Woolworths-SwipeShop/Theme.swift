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
    // Woolworths app promotion colours (from the product search tags).
    static let saveYellow = Color(hex: 0xFFDD00)
    static let specialRed = Color(hex: 0xC20016)
    static let checkoutGreen = Color(hex: 0x178841)
    static let sectionFill = Color(hex: 0xF2F2F2)
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

/// Filled green trolley with the Woolworths-style count badge (white disc, green outline).
struct CartIcon: View {
    let count: Int

    var body: some View {
        Image(systemName: "cart.fill")
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(Palette.green)
            .frame(width: 34, height: 34)
            // Drawn inside the frame so a glass toolbar background doesn't clip it.
            .overlay(alignment: .topTrailing) {
                if count > 0 {
                    Text("\(count)")
                        .font(.app(9, .bold))
                        .foregroundStyle(Palette.green)
                        .padding(.horizontal, 3)
                        .frame(minWidth: 15, minHeight: 15)
                        .background(.white, in: .capsule)
                        .overlay(Capsule().stroke(Palette.green, lineWidth: 1.2))
                }
            }
            .accessibilityElement()
            .accessibilityLabel("Cart, \(count) items")
    }
}

/// Cart button in the trailing slot of every pushed screen's toolbar.
struct CartToolbarItem: ToolbarContent {
    @Environment(AppModel.self) private var model

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                model.openCart()
            } label: {
                CartIcon(count: model.cartCount)
            }
        }
    }
}

/// "SAVE $6.80" / "LOWER SHELF PRICE" / "EVERYDAY LOW PRICE" label, coloured as in the Woolworths app.
struct ProductTagView: View {
    let tag: ProductTag

    var body: some View {
        Text(tag.text)
            .font(.app(12, .medium))
            .foregroundStyle(foreground)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(background, in: .rect(cornerRadius: 2))
            .overlay(RoundedRectangle(cornerRadius: 2).stroke(border, lineWidth: 1))
    }

    private var foreground: Color {
        switch tag.style {
        case .save: .black
        case .lowerShelf: Palette.specialRed
        case .everydayLow: .white
        }
    }

    private var background: Color {
        switch tag.style {
        case .save: Palette.saveYellow
        case .lowerShelf: .white
        case .everydayLow: Palette.specialRed
        }
    }

    private var border: Color {
        tag.style == .save ? Palette.saveYellow : Palette.specialRed
    }
}

/// Price with superscript cents, e.g. $9⁰⁰.
struct ShelfPrice: View {
    let price: Double
    var size: CGFloat = 34

    var body: some View {
        let cents = Int((price * 100).rounded())
        HStack(alignment: .top, spacing: 1) {
            Text("$\(cents / 100)")
                .font(.app(size, .bold))
            Text(String(format: "%02d", cents % 100))
                .font(.app(size * 0.45, .bold))
                .padding(.top, size * 0.14)
        }
        .foregroundStyle(Palette.ink)
        .accessibilityElement()
        .accessibilityLabel(price.currency)
    }
}

/// Green "40% Off" roundel.
struct PercentOffRoundel: View {
    let percent: Int
    var size: CGFloat = 52

    var body: some View {
        VStack(spacing: -2) {
            Text("\(percent)%")
                .font(.app(size * 0.32, .heavy))
            Text("Off")
                .font(.app(size * 0.2, .bold))
        }
        .foregroundStyle(.black)
        .frame(width: size, height: size)
        .background(.white, in: .circle)
        .overlay(Circle().stroke(Palette.green, lineWidth: size * 0.07))
    }
}

/// Overlapping packshots used where the lo-fi design had "ADD IMAGE" placeholders.
struct ProductCollage: View {
    let images: [String]
    var size: CGFloat = 96

    var body: some View {
        HStack(spacing: -size * 0.28) {
            ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .frame(width: size, height: size)
                    .background(.white, in: .rect(cornerRadius: 14))
                    .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
                    .rotationEffect(.degrees(Double(index - images.count / 2) * 4))
                    .zIndex(Double(images.count - abs(index - images.count / 2)))
            }
        }
        .accessibilityHidden(true)
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

struct SectionHeader<Accessory: View>: View {
    let title: String
    @ViewBuilder var accessory: Accessory

    var body: some View {
        HStack {
            Text(title)
                .font(.app(18.5, .semibold))
                .foregroundStyle(Palette.ink)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            accessory
        }
    }
}

extension SectionHeader where Accessory == EmptyView {
    init(title: String) {
        self.init(title: title) { EmptyView() }
    }
}
