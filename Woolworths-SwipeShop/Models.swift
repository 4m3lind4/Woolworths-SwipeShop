//
//  Models.swift
//  Woolworths-SwipeShop
//

import SwiftUI

enum Route: Hashable {
    case bundles
    case topic(Topic.ID)
    case bundleDetail(ShopBundle.ID)
    case customBundle
    case cart
}

@Observable
final class AppModel {
    var path: [Route] = []
    var cart: [CartLine] = []
    /// The bundle the shopper last swiped through, and the products they chose to buy.
    var activeBundle: ShopBundle?
    var customBundle: [ShopProduct] = []

    var cartCount: Int { cart.reduce(0) { $0 + $1.quantity } }

    func finishSwiping(_ bundle: ShopBundle, with chosen: [ShopProduct]) {
        activeBundle = bundle
        customBundle = chosen
        path.append(.customBundle)
    }

    func add(_ product: ShopProduct, quantity: Int = 1) {
        addLine(CartLine(product: product), quantity: quantity)
    }

    func addCustomBundleToCart() {
        customBundle.forEach { add($0) }
        path.append(.cart)
    }

    func openCart() {
        guard path.last != .cart else { return }
        path.append(.cart)
    }

    func setQuantity(_ quantity: Int, for line: CartLine) {
        guard let index = cart.firstIndex(where: { $0.id == line.id }) else { return }
        if quantity <= 0 {
            cart.remove(at: index)
        } else {
            cart[index].quantity = quantity
        }
    }

    func remove(_ line: CartLine) {
        cart.removeAll { $0.id == line.id }
    }

    private func addLine(_ line: CartLine, quantity: Int) {
        if let index = cart.firstIndex(where: { $0.id == line.id }) {
            cart[index].quantity += quantity
        } else {
            var line = line
            line.quantity = quantity
            cart.append(line)
        }
    }
}

// MARK: - Products

enum ProductTagStyle {
    /// Yellow "SAVE $x" label.
    case save
    /// Red-outlined "LOWER SHELF PRICE" label.
    case lowerShelf
    /// Solid red "EVERYDAY LOW PRICE" label.
    case everydayLow
}

struct ProductTag: Hashable {
    let text: String
    let style: ProductTagStyle
}

/// A Woolworths product as returned by the product search (name, pricing, tag and packshot).
struct ShopProduct: Identifiable, Hashable {
    var id: Int { stockcode }
    let stockcode: Int
    let name: String
    let price: Double
    let wasPrice: Double?
    let unitPrice: String
    let tag: ProductTag?
    let image: String
    /// Aisle the product is grouped under in the cart.
    let category: String

    var saving: Double { (wasPrice ?? price) - price }

    /// Whole-number percentage off, shown in the green roundel when it's a real discount.
    var percentOff: Int? {
        guard let wasPrice, wasPrice > 0 else { return nil }
        let percent = Int(((wasPrice - price) / wasPrice * 100).rounded())
        return percent >= 10 ? percent : nil
    }
}

/// One row of a bundle; the shopper swipes up and down through its product options.
struct BundleItem: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let options: [ShopProduct]
}

// MARK: - Cart

struct CartLine: Identifiable, Hashable {
    let id: String
    let name: String
    let image: String
    let price: Double
    let wasPrice: Double?
    let tag: ProductTag?
    let category: String
    var quantity = 1

    var total: Double { price * Double(quantity) }
    var wasTotal: Double? { wasPrice.map { $0 * Double(quantity) } }
    var saving: Double { ((wasPrice ?? price) - price) * Double(quantity) }
}

extension CartLine {
    init(product: ShopProduct) {
        self.init(
            id: "product-\(product.stockcode)", name: product.name, image: product.image,
            price: product.price, wasPrice: product.wasPrice, tag: product.tag, category: product.category
        )
    }
}

// MARK: - Topics and bundles

/// A shopper type from the Bundles grid (New Parents, Students, Pet Parents…).
struct Topic: Identifiable, Hashable {
    let id: String
    let title: String
    let categories: [TopicCategory]

    static func find(_ id: ID) -> Topic? { all.first { $0.id == id } }
}

/// A chip on a topic screen, grouping related bundles.
struct TopicCategory: Identifiable, Hashable {
    var id: String { title }
    let title: String
    let bundles: [ShopBundle]
}

/// A bundle of items the shopper swipes through.
struct ShopBundle: Identifiable, Hashable {
    let id: String
    let name: String
    /// Stock photo for the bundle card; bundles without one show their products instead.
    let image: String?
    let items: [BundleItem]

    var previewImages: [String] { items.map { $0.options[0].image } }

    static func find(_ id: ID) -> ShopBundle? {
        for topic in Topic.all {
            for category in topic.categories {
                if let bundle = category.bundles.first(where: { $0.id == id }) { return bundle }
            }
        }
        return nil
    }
}

extension Double {
    var currency: String { formatted(.currency(code: "AUD").presentation(.narrow)) }
}
