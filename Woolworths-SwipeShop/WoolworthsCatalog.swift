//
//  WoolworthsCatalog.swift
//  Woolworths-SwipeShop
//
//  Generated from Woolworths product search results (names, prices, tags, packshots).
//  Bundle card photos are openly licensed stock images; see STOCK_CREDITS.md.
//

import Foundation

extension BundleItem {
    static let nappyChangeEssentials: [BundleItem] = [
        BundleItem(name: "Newborn Nappies", options: [
            ShopProduct(stockcode: 6007813, name: "Millie Moon Luxury Nappies Size 1 Newborn (3-5kg) 54 pack", price: 12.5, wasPrice: 17.5, unitPrice: "$0.23 per 1EA", tag: ProductTag(text: "SAVE $5.00", style: .save), image: "product-6007813", category: "BABY"),
            ShopProduct(stockcode: 86173, name: "Little One's Ultra Dry Nappies Size 1 Newborn (5+kg) 30 pack", price: 5.35, wasPrice: nil, unitPrice: "$0.18 per 1EA", tag: ProductTag(text: "EVERYDAY LOW PRICE", style: .everydayLow), image: "product-86173", category: "BABY"),
            ShopProduct(stockcode: 569376, name: "Huggies Skin Protect Newborn Nappies Size 1 (Up to 5kg) 54 pack", price: 24, wasPrice: nil, unitPrice: "$0.44 per 1EA", tag: nil, image: "product-569376", category: "BABY"),
        ]),
        BundleItem(name: "Baby Wipes", options: [
            ShopProduct(stockcode: 6014355, name: "Millie Moon 99% Pure Water Baby Wipes 216 pack", price: 10, wasPrice: nil, unitPrice: "$4.63 per 100EA", tag: ProductTag(text: "LOWER SHELF PRICE", style: .lowerShelf), image: "product-6014355", category: "BABY"),
            ShopProduct(stockcode: 961095, name: "Little One's Baby Wipes 80 pack", price: 2, wasPrice: nil, unitPrice: "$2.50 per 100EA", tag: ProductTag(text: "EVERYDAY LOW PRICE", style: .everydayLow), image: "product-961095", category: "BABY"),
            ShopProduct(stockcode: 239760, name: "Curash Baby Wipes Fragrance Free 80 pack", price: 5.5, wasPrice: nil, unitPrice: "$6.88 per 100EA", tag: nil, image: "product-239760", category: "BABY"),
        ]),
        BundleItem(name: "Nappy Rash Cream", options: [
            ShopProduct(stockcode: 140756, name: "Sudocrem Nappy Rash Cream 125g", price: 15.45, wasPrice: nil, unitPrice: "$12.36 per 100G", tag: nil, image: "product-140756", category: "BABY"),
            ShopProduct(stockcode: 203229, name: "Bepanthen Nappy Rash Ointment 100g", price: 10.85, wasPrice: 15.5, unitPrice: "$10.85 per 100G", tag: ProductTag(text: "SAVE $4.65", style: .save), image: "product-203229", category: "BABY"),
            ShopProduct(stockcode: 6024268, name: "Bunjie Baby Nappy Barrier Cream Sensitive & Fragrance Free 250g", price: 25, wasPrice: nil, unitPrice: "$10.00 per 100G", tag: nil, image: "product-6024268", category: "BABY"),
        ]),
        BundleItem(name: "Baby Powder", options: [
            ShopProduct(stockcode: 289265, name: "Curash Baby Rash Powder With Cornstarch 100g", price: 7.2, wasPrice: 8.5, unitPrice: "$7.20 per 100G", tag: ProductTag(text: "SAVE $1.30", style: .save), image: "product-289265", category: "BABY"),
            ShopProduct(stockcode: 78867, name: "Johnson's Baby Powder 400g", price: 8, wasPrice: nil, unitPrice: "$2.00 per 100G", tag: ProductTag(text: "EVERYDAY LOW PRICE", style: .everydayLow), image: "product-78867", category: "BABY"),
            ShopProduct(stockcode: 333107, name: "Gaia Talc Free Natural Baby Powder 100g", price: 9, wasPrice: nil, unitPrice: "$9.00 per 100G", tag: nil, image: "product-333107", category: "BABY"),
        ]),
        BundleItem(name: "Baby Moisturiser", options: [
            ShopProduct(stockcode: 429223, name: "Aveeno Baby Dermexa Eczema Fragrance Free Moisturising Cream 206g", price: 12.25, wasPrice: 24.5, unitPrice: "$5.95 per 100G", tag: ProductTag(text: "SAVE $12.25", style: .save), image: "product-429223", category: "BABY"),
            ShopProduct(stockcode: 215573, name: "Gaia Natural Baby Moisturiser 500mL", price: 17, wasPrice: nil, unitPrice: "$3.40 per 100ML", tag: nil, image: "product-215573", category: "BABY"),
            ShopProduct(stockcode: 353038, name: "QV Baby Moisturising Cream 500g", price: 26.5, wasPrice: nil, unitPrice: "$5.30 per 100G", tag: nil, image: "product-353038", category: "BABY"),
        ]),
        BundleItem(name: "Nappy Bags", options: [
            ShopProduct(stockcode: 573517, name: "Little One's Nappy Bags Odour Neutralising 200 pack", price: 3.2, wasPrice: nil, unitPrice: "$1.60 per 100EA", tag: ProductTag(text: "EVERYDAY LOW PRICE", style: .everydayLow), image: "product-573517", category: "BABY"),
            ShopProduct(stockcode: 156009, name: "Gaia Natural Baby Biodegradable Nappy Bags 50 pack", price: 7, wasPrice: nil, unitPrice: "$14.00 per 100EA", tag: nil, image: "product-156009", category: "BABY"),
        ]),
    ]
}

enum BundleImages {
    static let byName: [String: String] = [
        "Bottle Feeding Kit": "stock-bottle-feeding",
        "Breastfeeding Support": "stock-breastfeeding",
        "Formula Starter": "stock-formula",
        "Nappy Change Essentials": "stock-nappy-change",
        "First Bath Set": "stock-bath",
        "Overnight Nappy Pack": "stock-overnight",
        "Sleep & Swaddle Set": "stock-swaddle",
        "Settling Night Pack": "stock-settling",
        "Recovery Care Kit": "stock-recovery",
        "Easy Meals: Week One": "stock-meals",
        "Coffee & Snacks Pack": "stock-coffee",
    ]
}
