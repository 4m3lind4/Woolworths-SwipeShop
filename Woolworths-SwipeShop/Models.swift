//
//  Models.swift
//  Woolworths-SwipeShop
//

import SwiftUI

enum Route: Hashable {
    case bundles
    case newParents
    case bundleDetail
    case customBundle
    case cart
}

@Observable
final class AppModel {
    var path: [Route] = []
    var cart: [CartLine] = []
    /// Products the shopper chose to buy in the last swipe session.
    var customBundle: [ShopProduct] = []

    var cartCount: Int { cart.reduce(0) { $0 + $1.quantity } }

    func finishSwiping(with chosen: [ShopProduct]) {
        customBundle = chosen
        path.append(.customBundle)
    }

    func add(_ product: ShopProduct, quantity: Int = 1) {
        addLine(CartLine(product: product), quantity: quantity)
    }

    func add(_ bundle: ParentBundle) {
        addLine(CartLine(bundle: bundle), quantity: 1)
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

    init(bundle: ParentBundle) {
        self.init(
            id: "bundle-\(bundle.name)", name: "\(bundle.name) bundle (\(bundle.itemCount) items)",
            image: bundle.image ?? "", price: bundle.price, wasPrice: nil, tag: nil, category: "BUNDLES"
        )
    }
}

// MARK: - New Parents bundles

struct ParentBundle: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let itemCount: Int
    let price: Double
    var opensDetail = false

    var image: String? { BundleImages.byName[name] }
}

struct BundleCategory: Identifiable {
    let id: String
    let title: String
    let bundles: [ParentBundle]
}

enum NewParentsFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case newborn = "Newborn 0–3m"
    case feeding = "Feeding"
    case nappyBath = "Nappy & Bath"
    case sleep = "Sleep"
    case forParents = "For Parents"

    var id: Self { self }

    var categoryID: String? {
        switch self {
        case .all, .newborn: nil
        case .feeding: "feeding"
        case .nappyBath: "nappy"
        case .sleep: "sleep"
        case .forParents: "parents"
        }
    }
}

extension BundleCategory {
    static let newParents: [BundleCategory] = [
        BundleCategory(id: "feeding", title: "Feeding", bundles: [
            ParentBundle(name: "Bottle Feeding Kit", itemCount: 9, price: 64),
            ParentBundle(name: "Breastfeeding Support", itemCount: 7, price: 52.5),
            ParentBundle(name: "Formula Starter", itemCount: 5, price: 48),
        ]),
        BundleCategory(id: "nappy", title: "Nappy & Bath", bundles: [
            ParentBundle(name: "Nappy Change Essentials", itemCount: 6, price: 58, opensDetail: true),
            ParentBundle(name: "First Bath Set", itemCount: 8, price: 41.5),
            ParentBundle(name: "Overnight Nappy Pack", itemCount: 4, price: 39),
        ]),
        BundleCategory(id: "sleep", title: "Sleep & Settling", bundles: [
            ParentBundle(name: "Sleep & Swaddle Set", itemCount: 6, price: 72),
            ParentBundle(name: "Settling Night Pack", itemCount: 5, price: 44),
        ]),
        BundleCategory(id: "parents", title: "For Parents", bundles: [
            ParentBundle(name: "Recovery Care Kit", itemCount: 10, price: 45),
            ParentBundle(name: "Easy Meals: Week One", itemCount: 12, price: 68),
            ParentBundle(name: "Coffee & Snacks Pack", itemCount: 8, price: 29.5),
        ]),
    ]
}

extension Double {
    var currency: String { formatted(.currency(code: "AUD").presentation(.narrow)) }
}
