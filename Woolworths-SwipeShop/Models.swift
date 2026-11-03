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
}

@Observable
final class AppModel {
    var path: [Route] = []
    var cartCount = 0
    /// Products the shopper loved in the last swipe session.
    var customBundle: [SwipeProduct] = []

    func finishSwiping(with loved: [SwipeProduct]) {
        customBundle = loved
        path.append(.customBundle)
    }

    func addCustomBundleToCart() {
        cartCount += customBundle.count
        path.removeAll()
    }
}

// MARK: - New Parents bundles

struct ParentBundle: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let itemCount: Int
    let price: Double
    var opensDetail = false
}

struct BundleCategory: Identifiable {
    let id: String
    let title: String
    let tint: Color
    let icon: String
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
        BundleCategory(id: "feeding", title: "Feeding", tint: Color(hex: 0xE3F0FA), icon: "icon-bottle", bundles: [
            ParentBundle(name: "Bottle Feeding Kit", itemCount: 9, price: 64),
            ParentBundle(name: "Breastfeeding Support", itemCount: 7, price: 52.5),
            ParentBundle(name: "Formula Starter", itemCount: 5, price: 48),
        ]),
        BundleCategory(id: "nappy", title: "Nappy & Bath", tint: Color(hex: 0xEAF4EA), icon: "icon-nappy", bundles: [
            ParentBundle(name: "Nappy Change Essentials", itemCount: 6, price: 58, opensDetail: true),
            ParentBundle(name: "First Bath Set", itemCount: 8, price: 41.5),
            ParentBundle(name: "Overnight Nappy Pack", itemCount: 4, price: 39),
        ]),
        BundleCategory(id: "sleep", title: "Sleep & Settling", tint: Color(hex: 0xFFF6D9), icon: "icon-moon", bundles: [
            ParentBundle(name: "Sleep & Swaddle Set", itemCount: 6, price: 72),
            ParentBundle(name: "Settling Night Pack", itemCount: 5, price: 44),
        ]),
        BundleCategory(id: "parents", title: "For Parents", tint: Color(hex: 0xFDE8EE), icon: "icon-heart-pink", bundles: [
            ParentBundle(name: "Recovery Care Kit", itemCount: 10, price: 45),
            ParentBundle(name: "Easy Meals: Week One", itemCount: 12, price: 68),
            ParentBundle(name: "Coffee & Snacks Pack", itemCount: 8, price: 29.5),
        ]),
    ]
}

// MARK: - Swipe shop

enum TraitStyle {
    case green, blue, purple, pink

    var foreground: Color {
        switch self {
        case .green: Color(hex: 0x1E9E5A)
        case .blue: Color(hex: 0x2C6E9B)
        case .purple: Color(hex: 0x6B4FB3)
        case .pink: Color(hex: 0xB4446C)
        }
    }

    var background: Color {
        switch self {
        case .green: Color(hex: 0xE6F5EC)
        case .blue: Color(hex: 0xE8F2FB)
        case .purple: Color(hex: 0xF3EEFB)
        case .pink: Color(hex: 0xFDE8EE)
        }
    }
}

struct Trait: Hashable {
    let label: String
    let style: TraitStyle

    static func == (lhs: Trait, rhs: Trait) -> Bool { lhs.label == rhs.label }
    func hash(into hasher: inout Hasher) { hasher.combine(label) }
}

struct SwipeProduct: Identifiable, Hashable {
    var id: String { name }
    /// Row on the bundle screen this product fulfils.
    let bundleItem: String
    /// Short label shown as "Current item: …".
    let itemLabel: String
    let name: String
    let detail: String
    let price: Double
    let unitPrice: String
    let traits: [Trait]
    var badge: String? = nil
    let points: Int
    let icon: String
    var alternatives: [SwipeProduct] = []
}

extension SwipeProduct {
    static let bundleItems = [
        "Newborn Nappies", "Baby Wipes", "Healing Cream",
        "Rash Cream", "Baby Moisturiser", "Macro Ready Meal",
    ]

    static let nappyChangeEssentials: [SwipeProduct] = [
        SwipeProduct(
            bundleItem: "Newborn Nappies", itemLabel: "Newborn Nappies",
            name: "Woolworths Little Ones Newborn Nappies", detail: "Newborn · Up to 5 kg · 54 pack",
            price: 16, unitPrice: "$0.30 per nappy",
            traits: [Trait(label: "Value", style: .green), Trait(label: "Soft", style: .blue)],
            points: 80, icon: "icon-nappy-large",
            alternatives: [SwipeProduct(
                bundleItem: "Newborn Nappies", itemLabel: "Newborn Nappies",
                name: "Huggies Ultimate Newborn Nappies", detail: "Size 1 · Up to 5 kg · 54 pack",
                price: 27, unitPrice: "$0.50 per nappy",
                traits: [Trait(label: "Premium", style: .purple), Trait(label: "Cute prints", style: .pink)],
                points: 120, icon: "icon-nappy-large")]
        ),
        SwipeProduct(
            bundleItem: "Baby Wipes", itemLabel: "Baby Wipes",
            name: "Little Ones Fragrance-Free Baby Wipes", detail: "80 wipes · 99% water",
            price: 4.5, unitPrice: "$0.06 per wipe",
            traits: [Trait(label: "Fragrance-free", style: .blue), Trait(label: "Sensitive", style: .purple)],
            points: 30, icon: "icon-bath",
            alternatives: [SwipeProduct(
                bundleItem: "Baby Wipes", itemLabel: "Baby Wipes",
                name: "WaterWipes Sensitive Baby Wipes", detail: "60 wipes · 99.9% water",
                price: 6, unitPrice: "$0.10 per wipe",
                traits: [Trait(label: "Fragrance-free", style: .blue), Trait(label: "Premium", style: .purple)],
                points: 40, icon: "icon-bath")]
        ),
        SwipeProduct(
            bundleItem: "Newborn Nappies", itemLabel: "Nappies",
            name: "Eco Bamboo Nappies", detail: "Size 1 · 2–5 kg · 54 pack",
            price: 25.9, unitPrice: "$0.48 per nappy",
            traits: [
                Trait(label: "Eco", style: .green), Trait(label: "Fragrance-free", style: .blue),
                Trait(label: "Premium", style: .purple), Trait(label: "Cute prints", style: .pink),
            ],
            badge: "Plastic-free", points: 120, icon: "icon-nappy-large",
            alternatives: [SwipeProduct(
                bundleItem: "Newborn Nappies", itemLabel: "Nappies",
                name: "Tooshies Pure Nappies", detail: "Size 1 · 2–5 kg · 50 pack",
                price: 24, unitPrice: "$0.48 per nappy",
                traits: [Trait(label: "Eco", style: .green), Trait(label: "Fragrance-free", style: .blue)],
                badge: "Plastic-free", points: 110, icon: "icon-nappy-large")]
        ),
        SwipeProduct(
            bundleItem: "Healing Cream", itemLabel: "Healing Cream",
            name: "Sudocrem Healing Cream", detail: "125 g tub",
            price: 11, unitPrice: "$8.80 per 100 g",
            traits: [Trait(label: "Trusted", style: .purple), Trait(label: "Soothing", style: .green)],
            points: 50, icon: "icon-bath",
            alternatives: [SwipeProduct(
                bundleItem: "Healing Cream", itemLabel: "Healing Cream",
                name: "Bepanthen Nappy Rash Ointment", detail: "100 g tube",
                price: 16, unitPrice: "$16.00 per 100 g",
                traits: [Trait(label: "Premium", style: .purple)],
                points: 60, icon: "icon-bath")]
        ),
        SwipeProduct(
            bundleItem: "Rash Cream", itemLabel: "Rash Cream",
            name: "Curash Medicated Nappy Rash Cream", detail: "100 g tube",
            price: 9.5, unitPrice: "$9.50 per 100 g",
            traits: [Trait(label: "Medicated", style: .blue)],
            points: 40, icon: "icon-bath",
            alternatives: [SwipeProduct(
                bundleItem: "Rash Cream", itemLabel: "Rash Cream",
                name: "Little Ones Zinc Rash Cream", detail: "100 g tube",
                price: 6, unitPrice: "$6.00 per 100 g",
                traits: [Trait(label: "Value", style: .green)],
                points: 25, icon: "icon-bath")]
        ),
        SwipeProduct(
            bundleItem: "Baby Moisturiser", itemLabel: "Baby Moisturiser",
            name: "GAIA Skin Naturals Baby Moisturiser", detail: "250 ml pump",
            price: 14, unitPrice: "$5.60 per 100 ml",
            traits: [Trait(label: "Natural", style: .green), Trait(label: "Fragrance-free", style: .blue)],
            points: 60, icon: "icon-bath",
            alternatives: [SwipeProduct(
                bundleItem: "Baby Moisturiser", itemLabel: "Baby Moisturiser",
                name: "QV Baby Moisturising Cream", detail: "250 g tube",
                price: 12, unitPrice: "$4.80 per 100 g",
                traits: [Trait(label: "Sensitive", style: .purple)],
                points: 50, icon: "icon-bath")]
        ),
        SwipeProduct(
            bundleItem: "Macro Ready Meal", itemLabel: "Ready Meal",
            name: "Macro Ready Meal", detail: "Chicken & veg · 350 g",
            price: 9, unitPrice: "$2.57 per 100 g",
            traits: [Trait(label: "Quick", style: .purple), Trait(label: "Healthy", style: .green)],
            points: 40, icon: "icon-heart-pink",
            alternatives: [SwipeProduct(
                bundleItem: "Macro Ready Meal", itemLabel: "Ready Meal",
                name: "Macro Beef Lasagne", detail: "Ready meal · 375 g",
                price: 9, unitPrice: "$2.40 per 100 g",
                traits: [Trait(label: "Quick", style: .purple)],
                points: 40, icon: "icon-heart-pink")]
        ),
    ]
}

extension Double {
    var currency: String { formatted(.currency(code: "AUD").presentation(.narrow)) }
}
