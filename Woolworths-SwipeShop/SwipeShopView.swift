//
//  SwipeShopView.swift
//  Woolworths-SwipeShop
//
//  Figma: "4 · Swipe – Nappies" — swipe right to keep, left to remove, or substitute.
//

import SwiftUI

private enum SwipeDecision {
    case love, remove
}

private struct SwipeStep {
    let index: Int
    let decision: SwipeDecision
    let product: SwipeProduct
}

struct SwipeShopView: View {
    let products: [SwipeProduct]
    let onFinish: ([SwipeProduct]) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var deck: [SwipeProduct]
    @State private var index = 0
    @State private var history: [SwipeStep] = []
    @State private var drag: CGSize = .zero

    init(products: [SwipeProduct], onFinish: @escaping ([SwipeProduct]) -> Void) {
        self.products = products
        self.onFinish = onFinish
        _deck = State(initialValue: products)
    }

    private var current: SwipeProduct? { deck.indices.contains(index) ? deck[index] : nil }
    private var loved: [SwipeProduct] {
        history.filter { $0.decision == .love }.map(\.product)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                circleButton("icon-close", label: "Close") { dismiss() }
                Spacer()
                circleButton("icon-undo", label: "Undo") { undo() }
                    .disabled(history.isEmpty)
                    .opacity(history.isEmpty ? 0.5 : 1)
            }
            .padding(.horizontal, 16)
            .padding(.top, 2)

            Text("Bundles")
                .font(.app(36, .bold))
                .foregroundStyle(Palette.ink)
                .padding(.top, 16)
                .padding(.horizontal, 20)

            HStack {
                (Text("Current item: ").foregroundStyle(Palette.muted)
                 + Text(current?.itemLabel ?? "Done").foregroundStyle(Palette.ink))
                    .font(.app(18, .semibold))
                Spacer()
                Text("\(min(index + 1, deck.count)) of \(deck.count)")
                    .font(.app(15, .semibold))
                    .foregroundStyle(Palette.green)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            ProgressView(value: Double(index), total: Double(max(deck.count, 1)))
                .progressViewStyle(SwipeProgressStyle())
                .padding(.horizontal, 20)
                .padding(.top, 10)

            cardStack
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 24)

            actions
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)
        }
        .background(Palette.swipeBackground)
    }

    // MARK: Cards

    private var cardStack: some View {
        ZStack(alignment: .top) {
            if deck.count - index > 2 {
                backCard.frame(width: 290, height: 470).opacity(0.6).offset(y: 36)
            }
            if deck.count - index > 1 {
                backCard.frame(width: 318, height: 470).opacity(0.85).offset(y: 20)
            }
            if let product = current {
                SwipeCard(product: product, drag: drag)
                    .id(product.id)
                    .offset(x: drag.width, y: drag.height * 0.2)
                    .rotationEffect(.degrees(Double(drag.width / 20)), anchor: .bottom)
                    .gesture(
                        DragGesture()
                            .onChanged { drag = $0.translation }
                            .onEnded { value in
                                if value.translation.width > 120 {
                                    decide(.love)
                                } else if value.translation.width < -120 {
                                    decide(.remove)
                                } else {
                                    withAnimation(.spring) { drag = .zero }
                                }
                            }
                    )
                    .transition(.identity)
            }
        }
        .frame(height: 506, alignment: .top)
    }

    private var backCard: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.white)
            .shadow(color: .black.opacity(0.08), radius: 7, y: 4)
    }

    // MARK: Actions

    private var actions: some View {
        HStack(alignment: .top, spacing: 26) {
            actionButton("icon-close-red", title: "Remove", size: 68, fill: .white, titleColor: Palette.muted) {
                decide(.remove)
            }
            actionButton("icon-substitute", title: "Substitute", size: 54, fill: .white, titleColor: Palette.muted) {
                substitute()
            }
            .disabled(current?.alternatives.isEmpty ?? true)
            actionButton("icon-heart-white", title: "Love it", size: 68, fill: Palette.green, titleColor: Palette.green) {
                decide(.love)
            }
        }
        .disabled(current == nil)
    }

    private func circleButton(_ image: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(image)
                .frame(width: 44, height: 44)
                .background(.white, in: .circle)
                .shadow(color: .black.opacity(0.08), radius: 2.5, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func actionButton(
        _ image: String, title: String, size: CGFloat, fill: Color, titleColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(image)
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

    private func decide(_ decision: SwipeDecision) {
        guard let product = current else { return }
        withAnimation(.easeIn(duration: 0.2)) {
            drag = CGSize(width: decision == .love ? 600 : -600, height: 40)
        }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(200))
            history.append(SwipeStep(index: index, decision: decision, product: product))
            drag = .zero
            index += 1
            if index >= deck.count {
                onFinish(loved)
            }
        }
    }

    private func substitute() {
        guard let product = current, let next = product.alternatives.first else { return }
        var swapped = next
        swapped.alternatives = [product]
        withAnimation(.snappy) { deck[index] = swapped }
    }

    private func undo() {
        guard let last = history.popLast() else { return }
        withAnimation(.snappy) {
            index = last.index
            deck[index] = last.product
        }
    }
}

private struct SwipeCard: View {
    let product: SwipeProduct
    let drag: CGSize

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                LinearGradient(
                    colors: [Color(hex: 0xEAF4FB), Color(hex: 0xD6EAF8)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                Image(product.icon)
                    .offset(x: 100, y: 46)

                HStack {
                    if let badge = product.badge {
                        HStack(spacing: 5) {
                            Image("icon-leaf")
                            Text(badge)
                                .font(.app(12, .semibold))
                                .foregroundStyle(Palette.success)
                        }
                        .padding(.leading, 10)
                        .padding(.trailing, 12)
                        .padding(.vertical, 6)
                        .background(.white, in: .capsule)
                    }
                    Spacer()
                    Text("+\(product.points) pts")
                        .font(.app(12, .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Palette.points, in: .capsule)
                }
                .padding(14)

                stamp("YES", color: Palette.success, angle: -14)
                    .opacity(Double(max(0, drag.width) / 100))
                    .offset(x: 34, y: 20)
                stamp("NOPE", color: Color(hex: 0xE0393E), angle: 14)
                    .opacity(Double(max(0, -drag.width) / 100))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .offset(x: -34, y: 20)
            }
            .frame(height: 240)
            .clipped()

            VStack(alignment: .leading, spacing: 8) {
                Text(product.name)
                    .font(.app(24, .bold))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(2)
                Text(product.detail)
                    .font(.app(14))
                    .foregroundStyle(Palette.muted)
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(product.price.currency)
                        .font(.app(22, .bold))
                        .foregroundStyle(Palette.ink)
                    Text(product.unitPrice)
                        .font(.app(13))
                        .foregroundStyle(Palette.muted)
                }
                HStack(spacing: 6) {
                    ForEach(product.traits, id: \.self) { trait in
                        Text(trait.label)
                            .font(.app(12, .semibold))
                            .foregroundStyle(trait.style.foreground)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(trait.style.background, in: .capsule)
                    }
                }
                HStack(spacing: 6) {
                    Image("icon-info")
                    Text("Would you put this in your trolley?")
                        .font(.app(13, .medium))
                        .foregroundStyle(Palette.muted)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Spacer(minLength: 0)
        }
        .frame(width: 350, height: 470)
        .background(.white)
        .clipShape(.rect(cornerRadius: 24))
        .shadow(color: .black.opacity(0.14), radius: 15, y: 10)
    }

    private func stamp(_ text: String, color: Color, angle: Double) -> some View {
        Text(text)
            .font(.app(30, .heavy))
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
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
    SwipeShopView(products: SwipeProduct.nappyChangeEssentials) { _ in }
}
