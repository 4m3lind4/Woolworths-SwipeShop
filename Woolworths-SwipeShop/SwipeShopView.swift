//
//  SwipeShopView.swift
//  Woolworths-SwipeShop
//
//  Figma: "4 · Swipe – Nappies". Swipe right to buy, left to remove,
//  up for another product option and down to go back to the previous one.
//

import SwiftUI

private enum SwipeDecision {
    case buy, remove
}

private enum SwapDirection {
    case up, down
}

private struct SwipeStep {
    let itemIndex: Int
    let optionIndex: Int
    let decision: SwipeDecision
}

struct SwipeShopView: View {
    let items: [BundleItem]
    let onFinish: ([ShopProduct]) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var itemIndex = 0
    @State private var optionIndex: [Int]
    @State private var history: [SwipeStep] = []
    @State private var drag: CGSize = .zero
    @State private var swap: SwapDirection?

    init(items: [BundleItem], onFinish: @escaping ([ShopProduct]) -> Void) {
        self.items = items
        self.onFinish = onFinish
        _optionIndex = State(initialValue: Array(repeating: 0, count: items.count))
    }

    private var currentItem: BundleItem? { items.indices.contains(itemIndex) ? items[itemIndex] : nil }
    private var currentProduct: ShopProduct? {
        currentItem.map { $0.options[optionIndex[itemIndex]] }
    }
    private var chosen: [ShopProduct] {
        history.filter { $0.decision == .buy }.map { items[$0.itemIndex].options[$0.optionIndex] }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                circleButton(systemImage: "xmark", label: "Close") { dismiss() }
                Spacer()
                circleButton(systemImage: "arrow.uturn.backward", label: "Undo") { undo() }
                    .disabled(history.isEmpty)
                    .opacity(history.isEmpty ? 0.5 : 1)
            }
            .padding(.horizontal, 16)
            .padding(.top, 2)

            Text("Bundles")
                .font(.app(36, .bold))
                .foregroundStyle(Palette.ink)
                .padding(.top, 12)
                .padding(.horizontal, 20)

            HStack {
                (Text("Current item: ").foregroundStyle(Palette.muted)
                 + Text(currentItem?.name ?? "Done").foregroundStyle(Palette.ink))
                    .font(.app(18, .semibold))
                Spacer()
                Text("\(min(itemIndex + 1, items.count)) of \(items.count)")
                    .font(.app(15, .semibold))
                    .foregroundStyle(Palette.green)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            ProgressView(value: Double(itemIndex), total: Double(max(items.count, 1)))
                .progressViewStyle(SwipeProgressStyle())
                .padding(.horizontal, 20)
                .padding(.top, 10)

            cardStack
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 18)

            actions
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)
        }
        .background(Palette.swipeBackground)
    }

    // MARK: Cards

    private var cardStack: some View {
        ZStack(alignment: .top) {
            if items.count - itemIndex > 2 {
                backCard.frame(width: 290, height: 470).opacity(0.6).offset(y: 30)
            }
            if items.count - itemIndex > 1 {
                backCard.frame(width: 318, height: 470).opacity(0.85).offset(y: 16)
            }
            if let item = currentItem, let product = currentProduct {
                SwipeCard(
                    product: product,
                    option: optionIndex[itemIndex],
                    optionCount: item.options.count,
                    drag: drag
                )
                .id(product.id)
                .offset(drag)
                .rotationEffect(.degrees(Double(drag.width / 20)), anchor: .bottom)
                .gesture(swipeGesture)
                .transition(cardTransition)
            }
        }
        .frame(height: 500, alignment: .top)
    }

    private var cardTransition: AnyTransition {
        switch swap {
        case .up:
            .asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity))
        case .down:
            .asymmetric(insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity))
        case nil:
            .identity
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { drag = $0.translation }
            .onEnded { value in
                let t = value.translation
                if abs(t.width) > abs(t.height) {
                    if t.width > 120 { decide(.buy) } else if t.width < -120 { decide(.remove) } else { resetDrag() }
                } else {
                    if t.height < -90 { swapOption(.up) } else if t.height > 90 { swapOption(.down) } else { resetDrag() }
                }
            }
    }

    private var backCard: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.white)
            .shadow(color: .black.opacity(0.08), radius: 7, y: 4)
    }

    // MARK: Actions

    private var actions: some View {
        HStack(alignment: .top, spacing: 26) {
            actionButton(systemImage: "xmark", title: "Remove", size: 68, tint: Color(hex: 0xE0393E),
                         fill: .white, titleColor: Palette.muted) {
                decide(.remove)
            }
            actionButton(systemImage: "arrow.up.arrow.down", title: "Substitute", size: 54, tint: Palette.green,
                         fill: .white, titleColor: Palette.muted) {
                swapOption(.up)
            }
            .disabled((currentItem?.options.count ?? 0) < 2)
            actionButton(systemImage: "basket.fill", title: "Buy it", size: 68, tint: .white,
                         fill: Palette.green, titleColor: Palette.green) {
                decide(.buy)
            }
        }
        .disabled(currentItem == nil)
    }

    private func circleButton(systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Palette.ink)
                .frame(width: 44, height: 44)
                .background(.white, in: .circle)
                .shadow(color: .black.opacity(0.08), radius: 2.5, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func actionButton(
        systemImage: String, title: String, size: CGFloat, tint: Color, fill: Color, titleColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: size * 0.38, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: size, height: size)
                    .background(fill, in: .circle)
                    .shadow(color: .black.opacity(0.12), radius: 4.5, y: 6)
                Text(title)
                    .font(.app(12, .semibold))
                    .foregroundStyle(titleColor)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: Logic

    private func resetDrag() {
        withAnimation(.spring) { drag = .zero }
    }

    private func decide(_ decision: SwipeDecision) {
        guard currentItem != nil else { return }
        swap = nil
        withAnimation(.easeIn(duration: 0.2)) {
            drag = CGSize(width: decision == .buy ? 600 : -600, height: 40)
        }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(200))
            history.append(SwipeStep(itemIndex: itemIndex, optionIndex: optionIndex[itemIndex], decision: decision))
            drag = .zero
            itemIndex += 1
            if itemIndex >= items.count {
                onFinish(chosen)
            }
        }
    }

    /// Up shows the next product option (wrapping round); down goes back to the previous one.
    private func swapOption(_ direction: SwapDirection) {
        guard let item = currentItem else { return }
        let current = optionIndex[itemIndex]
        let next: Int
        switch direction {
        case .up: next = (current + 1) % item.options.count
        case .down: next = current - 1
        }
        guard next >= 0, next != current else {
            resetDrag()
            return
        }
        swap = direction
        withAnimation(.snappy) {
            drag = .zero
            optionIndex[itemIndex] = next
        }
    }

    private func undo() {
        guard let last = history.popLast() else { return }
        swap = nil
        withAnimation(.snappy) {
            itemIndex = last.itemIndex
            optionIndex[itemIndex] = last.optionIndex
        }
    }
}

private struct SwipeCard: View {
    let product: ShopProduct
    let option: Int
    let optionCount: Int
    let drag: CGSize

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                Image(product.image)
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 40)
                    .padding(.top, 36)
                    .padding(.bottom, 12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if let tag = product.tag {
                    ProductTagView(tag: tag)
                        .padding(14)
                }

                if let percent = product.percentOff {
                    PercentOffRoundel(percent: percent)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                optionDots
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(14)

                stamp("BUY", color: Palette.green, angle: -14)
                    .opacity(Double(max(0, drag.width) / 100))
                    .offset(x: 30, y: 60)
                stamp("NOPE", color: Color(hex: 0xE0393E), angle: 14)
                    .opacity(Double(max(0, -drag.width) / 100))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .offset(x: -30, y: 60)
            }
            .frame(height: 250)
            .clipped()

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.app(17, .semibold))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    ShelfPrice(price: product.price)
                    Text(product.unitPrice)
                        .font(.app(13))
                        .foregroundStyle(Palette.muted)
                }
                if let wasPrice = product.wasPrice {
                    Text("Was \(wasPrice.currency)")
                        .font(.app(14))
                        .foregroundStyle(Palette.specialRed)
                }
                Spacer(minLength: 6)
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.secondary)
                    Text(optionCount > 1
                         ? "Would you put this in your trolley? Swipe up for another option."
                         : "Would you put this in your trolley?")
                        .font(.app(12, .medium))
                        .foregroundStyle(Palette.muted)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .frame(width: 350, height: 470)
        .background(.white)
        .clipShape(.rect(cornerRadius: 24))
        .shadow(color: .black.opacity(0.14), radius: 15, y: 10)
    }

    private var optionDots: some View {
        VStack(spacing: 5) {
            ForEach(0..<optionCount, id: \.self) { index in
                Capsule()
                    .fill(index == option ? Palette.green : Color(.systemGray4))
                    .frame(width: 6, height: index == option ? 16 : 6)
            }
        }
        .animation(.snappy, value: option)
        .accessibilityElement()
        .accessibilityLabel("Option \(option + 1) of \(optionCount)")
    }

    private func stamp(_ text: String, color: Color, angle: Double) -> some View {
        Text(text)
            .font(.app(30, .heavy))
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(.white.opacity(0.85), in: .rect(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(color, lineWidth: 3.5))
            .rotationEffect(.degrees(angle))
    }
}

private struct SwipeProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Color(hex: 0xE2E2E2))
                Capsule().fill(Palette.green)
                    .frame(width: proxy.size.width * (configuration.fractionCompleted ?? 0))
            }
        }
        .frame(height: 8)
        .animation(.snappy, value: configuration.fractionCompleted)
    }
}

#Preview {
    SwipeShopView(items: BundleItem.nappyChangeEssentials) { _ in }
}
