//
//  CartView.swift
//  Woolworths-SwipeShop
//
//  Cart modelled on the Woolworths app: rewards rows, items grouped by aisle,
//  quantity steppers and a subtotal / saving / checkout footer.
//

import SwiftUI

struct CartView: View {
    @Environment(AppModel.self) private var model
    @State private var showingCheckout = false

    private var subtotal: Double { model.cart.reduce(0) { $0 + $1.total } }
    private var saving: Double { model.cart.reduce(0) { $0 + $1.saving } }

    /// Aisles in the order their first item was added.
    private var categories: [String] {
        model.cart.reduce(into: [String]()) { result, line in
            if !result.contains(line.category) { result.append(line.category) }
        }
    }

    var body: some View {
        Group {
            if model.cart.isEmpty {
                ContentUnavailableView {
                    Label("Your cart is empty", systemImage: "cart")
                } description: {
                    Text("Add a bundle or swipe shop to fill your trolley.")
                }
            } else {
                list
            }
        }
        .background(.white)
        // The Woolworths cart shows a large "Cart / N items" header in the list, so the bar title
        // is only needed for the empty state.
        .navigationTitle(model.cart.isEmpty ? "Cart" : "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom) {
            if !model.cart.isEmpty { footer }
        }
        .alert("Order placed", isPresented: $showingCheckout) {
            Button("Done") {
                model.cart.removeAll()
                model.path.removeAll()
            }
        } message: {
            Text("Thanks for shopping with Swipe Shop. Your \(subtotal.currency) order is on its way.")
        }
    }

    private var list: some View {
        List {
            VStack(alignment: .leading, spacing: 2) {
                Text("Cart")
                    .font(.largeTitle.bold())
                Text("\(model.cartCount) \(model.cartCount == 1 ? "item" : "items")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .listRowSeparator(.hidden)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)

            Section {
                HStack(spacing: 10) {
                    Text("r")
                        .font(.system(size: 14, weight: .black).italic())
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(Palette.rewardsLogo, in: .circle)
                    Text("Collect \(Int(subtotal)) pts")
                        .font(.subheadline)
                }
                HStack(spacing: 10) {
                    Image(systemName: "c.circle")
                        .font(.system(size: 22))
                        .foregroundStyle(Palette.rewardsLogo)
                    Text("Earn 1 credit")
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                }
            }

            ForEach(categories, id: \.self) { category in
                Section {
                    ForEach(model.cart.filter { $0.category == category }) { line in
                        CartRow(line: line)
                    }
                } header: {
                    Text(category)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.plain)
    }

    private var footer: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Subtotal")
                    .font(.title3)
                Spacer()
                Text(subtotal.currency)
                    .font(.title3.weight(.semibold))
            }
            HStack {
                Text("Excl. service, bag & collection fees")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if saving > 0 {
                    Label("SAVING \(saving.currency)", systemImage: "party.popper.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Palette.saveYellow, in: .rect(cornerRadius: 2))
                }
            }
            Button {
                showingCheckout = true
            } label: {
                Text("Checkout")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 6))
            .tint(Palette.checkoutGreen)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 8)
        .background(.white)
        .overlay(alignment: .top) { Divider() }
    }
}

private struct CartRow: View {
    @Environment(AppModel.self) private var model
    let line: CartLine

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(line.image)
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 80)

            VStack(alignment: .leading, spacing: 8) {
                if let tag = line.tag {
                    ProductTagView(tag: tag)
                }
                Text(line.name)
                    .font(.subheadline)
                    .foregroundStyle(Palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.trailing, 24)
                HStack(alignment: .bottom) {
                    QuantityStepper(quantity: line.quantity) { model.setQuantity($0, for: line) }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(line.total.currency)
                            .font(.title3.weight(.semibold))
                        if let wasTotal = line.wasTotal {
                            Text("Was \(wasTotal.currency)")
                                .font(.caption)
                                .strikethrough()
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 6)
        .overlay(alignment: .topTrailing) {
            Button {
                withAnimation { model.remove(line) }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color(.systemGray3))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove \(line.name)")
        }
        .swipeActions {
            Button("Remove", role: .destructive) { model.remove(line) }
        }
    }
}

/// Woolworths-style − 1 + stepper; the minus greys out at one (use ⓧ to remove).
private struct QuantityStepper: View {
    let quantity: Int
    let onChange: (Int) -> Void

    var body: some View {
        HStack(spacing: 0) {
            stepButton("minus", enabled: quantity > 1) { onChange(quantity - 1) }
                .accessibilityLabel("Decrease quantity")
            Text("\(quantity)")
                .font(.body)
                .frame(width: 44, height: 36)
                .background(Color(.systemGray6))
            stepButton("plus", enabled: true) { onChange(quantity + 1) }
                .accessibilityLabel("Increase quantity")
        }
        .clipShape(.rect(cornerRadius: 4))
    }

    private func stepButton(_ symbol: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(enabled ? Palette.checkoutGreen : Color(.systemGray3))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

#Preview {
    let model = AppModel()
    Topic.all[0].categories[1].bundles[0].items.prefix(3).forEach { model.add($0.options[0]) }
    return NavigationStack { CartView() }
        .environment(model)
}
