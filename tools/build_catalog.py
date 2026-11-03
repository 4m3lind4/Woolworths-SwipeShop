"""Builds the Swipe Shop product catalog from Woolworths product search.

Every topic -> category -> bundle -> item below is searched on woolworths.com.au.
Each item keeps up to three *different* products whose names match its keywords,
so a swipe deck never offers an off-topic product or the same product twice.

Outputs:
  Woolworths-SwipeShop/WoolworthsCatalog.swift   (iOS app)
  web/catalog.js                                 (HTML prototype)
  product images in the asset catalog and web/images/products/

Run from the repository root:  python3 tools/build_catalog.py
Search results are cached in tools/.cache so reruns are offline-friendly.
"""

import json
import os
import re
import subprocess
import time
import urllib.parse
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CACHE = os.path.join(ROOT, "tools", ".cache")
ASSETS = os.path.join(ROOT, "Woolworths-SwipeShop", "Assets.xcassets")
WEB_IMAGES = os.path.join(ROOT, "web", "images", "products")
UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_0) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"


def item(name, query, keywords, aisle, exclude=(), codes=None, also=()):
    """`keywords` and `also` are each any-of lists; a product name must match both."""
    return {"name": name, "query": query, "keywords": keywords, "also": list(also), "aisle": aisle,
            "exclude": list(exclude), "codes": codes}


# Topics match the shopper tiles on the Bundles screen. `image` is a stock photo
# asset (see STOCK_CREDITS.md); bundles without one show a collage of their products.
TOPICS = [
    {"id": "new-parents", "title": "New Parents", "categories": [
        {"title": "Feeding", "bundles": [
            {"name": "Bottle Feeding Kit", "image": "stock-bottle-feeding", "items": [
                item("Baby Bottles", "baby bottle", ["bottle"], "BABY", ["brush", "teat", "warmer", "steril", "clean"]),
                item("Bottle Teats", "bottle teats", ["teat"], "BABY"),
                item("Bottle Brush", "bottle brush", ["brush"], "BABY", ["tooth"]),
                item("Steriliser", "milton", ["milton", "sterilis"], "BABY"),
            ]},
            {"name": "Breastfeeding Support", "image": "stock-breastfeeding", "items": [
                item("Nursing Pads", "nursing pads", ["nursing pad", "breast pad"], "BABY"),
                item("Nipple Cream", "nipple cream", ["nipple"], "BABY", ["cover", "shield"]),
                item("Hydration", "hydralyte", ["hydralyte", "electrolyte"], "HEALTH"),
            ]},
            {"name": "Formula Starter", "image": "stock-formula", "items": [
                item("Infant Formula", "infant formula stage 1", ["formula"], "BABY", ["toddler", "stage 2", "stage 3", "stage 4"]),
                item("Baby Bottles", "baby bottle", ["bottle"], "BABY", ["brush", "teat", "warmer", "steril", "clean"]),
                item("Steriliser", "milton", ["milton", "sterilis"], "BABY"),
                item("Bibs", "baby bibs", ["bib"], "BABY"),
            ]},
        ]},
        {"title": "Nappy & Bath", "bundles": [
            {"name": "Nappy Change Essentials", "image": "stock-nappy-change", "items": [
                item("Newborn Nappies", "", [], "BABY", codes=[6007813, 86173, 569376]),
                item("Baby Wipes", "", [], "BABY", codes=[6014355, 961095, 239760]),
                item("Nappy Rash Cream", "", [], "BABY", codes=[140756, 203229, 6024268]),
                item("Baby Powder", "", [], "BABY", codes=[289265, 78867, 333107]),
                item("Baby Moisturiser", "", [], "BABY", codes=[429223, 215573, 353038]),
                item("Nappy Bags", "", [], "BABY", codes=[573517, 156009]),
            ]},
            {"name": "First Bath Set", "image": "stock-bath", "items": [
                item("Baby Bath Wash", "baby bath wash", ["bath", "wash"], "BABY", ["shampoo & conditioner"]),
                item("Baby Shampoo", "baby shampoo", ["shampoo"], "BABY"),
                item("Baby Lotion", "baby lotion", ["lotion"], "BABY", also=["baby"]),
                item("Cotton Buds", "baby cotton buds", ["bud", "tip"], "BABY", ["sock"]),
            ]},
            {"name": "Overnight Nappy Pack", "image": "stock-overnight", "items": [
                item("Infant Nappies", "nappies size 2 infant", ["size 2"], "BABY", ["pants", "years"]),
                item("Sensitive Wipes", "sensitive baby wipes", ["wipe"], "BABY"),
                item("Barrier Cream", "nappy rash cream", ["cream", "ointment"], "BABY"),
            ]},
        ]},
        {"title": "Sleep & Settling", "bundles": [
            {"name": "Sleep & Swaddle Set", "image": "stock-swaddle", "items": [
                item("Dummies", "baby dummy", ["dumm", "soother", "pacifier"], "BABY"),
                item("Baby Oil", "baby oil", ["oil"], "BABY"),
                item("Bedtime Bath", "bedtime baby bath", ["bedtime", "sleep", "calming", "lavender"], "BABY", ["pants", "nappies"], also=["bath", "wash"]),
            ]},
            {"name": "Settling Night Pack", "image": "stock-settling", "items": [
                item("Teething Relief", "teething", ["teething"], "BABY"),
                item("Saline Spray", "baby saline nasal", ["saline"], "HEALTH", ["eucalyptus", "salts"], also=["nasal", "spray", "drop"]),
            ]},
        ]},
        {"title": "For Parents", "bundles": [
            {"name": "Recovery Care Kit", "image": "stock-recovery", "items": [
                item("Maternity Pads", "maternity pads", ["maternity"], "HEALTH"),
                item("Pain Relief", "paracetamol tablets", ["paracetamol"], "HEALTH", ["infant", "children", "kids"]),
                item("Hydration", "hydralyte", ["hydralyte", "electrolyte"], "HEALTH"),
                item("Heat Pack", "heat pack", ["heat"], "HEALTH"),
            ]},
            {"name": "Easy Meals: Week One", "image": "stock-meals", "items": [
                item("Ready Meals", "frozen ready meal", ["chicken", "beef", "pasta", "lasagne", "curry"], "FREEZER"),
                item("Soup", "soup", ["soup"], "PANTRY"),
                item("Frozen Vegetables", "frozen vegetables", ["vegetable", "veg"], "FREEZER"),
                item("Microwave Rice", "microwave rice", ["rice"], "PANTRY"),
            ]},
            {"name": "Coffee & Snacks Pack", "image": "stock-coffee", "items": [
                item("Coffee Pods", "coffee capsules", ["capsule", "pod"], "PANTRY"),
                item("Muesli Bars", "muesli bars", ["bar"], "PANTRY"),
                item("Trail Mix", "trail mix", ["mix", "nut"], "PANTRY"),
            ]},
        ]},
    ]},
    {"id": "expecting-parents", "title": "Expecting Parents", "categories": [
        {"title": "Pregnancy Health", "bundles": [
            {"name": "Pregnancy Essentials", "items": [
                item("Pregnancy Vitamins", "pregnancy multivitamin", ["pregnancy", "prenatal", "conception"], "HEALTH", ["test"]),
                item("Iron Supplement", "iron supplement", ["iron"], "HEALTH"),
                item("Stretch Mark Oil", "stretch mark", ["bio-oil", "stretch", "skin oil", "body oil"], "HEALTH", ["hair", "shampoo", "conditioner"]),
                item("Ginger Tea", "ginger tea", ["ginger"], "PANTRY"),
            ]},
            {"name": "Morning Comfort", "items": [
                item("Hydration", "hydralyte", ["hydralyte", "electrolyte"], "HEALTH"),
                item("Plain Crackers", "rice crackers", ["cracker"], "PANTRY"),
                item("Peppermint Tea", "peppermint tea", ["peppermint"], "PANTRY"),
                item("Heartburn Relief", "gaviscon", ["gaviscon", "antacid", "heartburn"], "HEALTH"),
            ]},
        ]},
        {"title": "Getting Ready", "bundles": [
            {"name": "Hospital Bag", "items": [
                item("Maternity Pads", "maternity pads", ["maternity"], "HEALTH"),
                item("Nursing Pads", "nursing pads", ["nursing pad", "breast pad"], "BABY"),
                item("Newborn Nappies", "newborn nappies", ["newborn"], "BABY", ["pants"]),
                item("Baby Wipes", "baby wipes", ["wipe"], "BABY"),
            ]},
            {"name": "Nursery Prep", "items": [
                item("Sensitive Laundry Liquid", "sensitive laundry liquid", ["laundry"], "CLEANING", also=["sensitive", "baby", "gentle"]),
                item("Baby Bath Wash", "baby bath wash", ["bath", "wash"], "BABY", ["shampoo & conditioner"]),
                item("Baby Lotion", "baby lotion", ["lotion"], "BABY", also=["baby"]),
            ]},
        ]},
    ]},
    {"id": "students", "title": "Students", "categories": [
        {"title": "Study Fuel", "bundles": [
            {"name": "Exam Week Snacks", "items": [
                item("Instant Noodles", "instant noodles", ["noodle"], "PANTRY"),
                item("Instant Coffee", "instant coffee", ["coffee"], "PANTRY", ["capsule", "pod", "milk"]),
                item("Muesli Bars", "muesli bars", ["bar"], "PANTRY"),
                item("Energy Drink", "energy drink", ["energy"], "DRINKS"),
            ]},
            {"name": "Budget Dinners", "items": [
                item("Pasta", "spaghetti pasta", ["spaghetti", "pasta", "penne"], "PANTRY", ["sauce"]),
                item("Pasta Sauce", "pasta sauce", ["sauce"], "PANTRY"),
                item("Tinned Tuna", "tuna tin", ["tuna"], "PANTRY"),
                item("Frozen Vegetables", "frozen vegetables", ["vegetable", "veg"], "FREEZER"),
            ]},
        ]},
        {"title": "Share House", "bundles": [
            {"name": "Share House Basics", "items": [
                item("Laundry Liquid", "laundry liquid", ["laundry"], "CLEANING"),
                item("Dishwashing Liquid", "dishwashing liquid", ["dishwash"], "CLEANING", ["tablet", "capsule"]),
                item("Toilet Paper", "toilet paper", ["toilet"], "CLEANING", ["cleaner", "brush"]),
            ]},
            {"name": "Breakfast on the Go", "items": [
                item("Rolled Oats", "rolled oats", ["oat"], "PANTRY", ["milk", "bar"]),
                item("Breakfast Drink", "up & go", ["up & go", "breakfast"], "DRINKS"),
                item("Peanut Butter", "peanut butter", ["peanut butter"], "PANTRY"),
            ]},
        ]},
    ]},
    {"id": "busy-workers", "title": "Busy Workers", "categories": [
        {"title": "Quick Meals", "bundles": [
            {"name": "Ready in 5", "items": [
                item("Ready Meals", "frozen ready meal", ["chicken", "beef", "pasta", "lasagne", "curry"], "FREEZER"),
                item("Microwave Rice", "microwave rice", ["rice"], "PANTRY"),
                item("Salad Kit", "salad kit", ["salad"], "FRUIT & VEG"),
            ]},
            {"name": "Lunchbox", "items": [
                item("Wraps", "wraps", ["wrap"], "BAKERY"),
                item("Sliced Ham", "sliced ham", ["ham"], "DELI"),
                item("Cheese Slices", "cheese slices", ["slice"], "DAIRY"),
                item("Fruit Snacks", "fruit snack", ["fruit"], "PANTRY"),
            ]},
        ]},
        {"title": "Breakfast & Coffee", "bundles": [
            {"name": "Grab & Go Breakfast", "items": [
                item("Breakfast Drink", "up & go", ["up & go", "breakfast"], "DRINKS"),
                item("Yoghurt Pouches", "yoghurt pouch", ["yoghurt", "yogurt"], "DAIRY"),
                item("Protein Bars", "protein bar", ["protein"], "PANTRY"),
            ]},
            {"name": "Coffee Run", "items": [
                item("Coffee Pods", "coffee capsules", ["capsule", "pod"], "PANTRY"),
                item("Barista Milk", "barista milk", ["barista"], "DAIRY"),
                item("Biscotti", "biscotti", ["biscotti"], "PANTRY"),
            ]},
        ]},
    ]},
    {"id": "remote-workers", "title": "Remote Workers", "categories": [
        {"title": "Desk Fuel", "bundles": [
            {"name": "Desk Snacks", "items": [
                item("Mixed Nuts", "mixed nuts", ["nut"], "PANTRY"),
                item("Crackers", "crackers", ["cracker"], "PANTRY"),
                item("Dark Chocolate", "dark chocolate", ["dark"], "PANTRY"),
            ]},
            {"name": "Afternoon Pick-me-up", "items": [
                item("Green Tea", "green tea", ["green tea"], "PANTRY"),
                item("Coffee Beans", "coffee beans", ["bean"], "PANTRY"),
                item("Kombucha", "kombucha", ["kombucha"], "DRINKS"),
            ]},
        ]},
        {"title": "Lunch at Home", "bundles": [
            {"name": "Home Lunch", "items": [
                item("Soup", "soup", ["soup"], "PANTRY"),
                item("Sourdough", "sourdough bread", ["sourdough"], "BAKERY"),
                item("Eggs", "free range eggs", ["egg"], "DAIRY"),
            ]},
            {"name": "Home Office", "items": [
                item("Copy Paper", "a4 copy paper", ["paper"], "HOME", ["toilet", "towel", "baking", "display"], also=["a4"]),
                item("Sticky Notes", "sticky notes", ["note"], "HOME"),
                item("Tissues", "tissues", ["tissue"], "HOME", ["toilet"]),
            ]},
        ]},
    ]},
    {"id": "senior-shoppers", "title": "Senior Shoppers", "categories": [
        {"title": "Everyday Staples", "bundles": [
            {"name": "Pantry Staples", "items": [
                item("Long Life Milk", "long life milk", ["long life", "uht"], "DAIRY", ["oat", "almond", "soy", "barista"]),
                item("Tea Bags", "tea bags", ["tea"], "PANTRY", ["green"]),
                item("Tinned Soup", "canned soup", ["soup"], "PANTRY"),
            ]},
            {"name": "Healthy Ageing", "items": [
                item("Fish Oil", "fish oil", ["fish oil", "omega"], "HEALTH"),
                item("Calcium", "calcium vitamin d", ["calcium"], "HEALTH"),
                item("High Fibre Cereal", "high fibre cereal", ["bran", "fibre"], "PANTRY"),
            ]},
        ]},
        {"title": "Easy at Home", "bundles": [
            {"name": "Small Meals", "items": [
                item("Single Serve Meals", "frozen meal", ["chicken", "beef", "fish", "lasagne", "pie"], "FREEZER"),
                item("Tinned Salmon", "salmon tin", ["salmon"], "PANTRY"),
                item("Instant Mash", "instant mashed potato", ["mash", "potato"], "PANTRY", ["recipe"]),
            ]},
            {"name": "Home Comfort", "items": [
                item("Heat Pack", "heat pack", ["heat"], "HEALTH"),
                item("Hand Cream", "hand cream", ["hand"], "HEALTH"),
                item("Tissues", "tissues", ["tissue"], "HOME", ["toilet"]),
            ]},
        ]},
    ]},
    {"id": "health-concious", "title": "Health Concious", "categories": [
        {"title": "Nutrition", "bundles": [
            {"name": "High Protein", "items": [
                item("Greek Yoghurt", "greek yoghurt", ["greek"], "DAIRY"),
                item("Protein Powder", "protein powder", ["protein"], "HEALTH", ["bar"]),
                item("Protein Bars", "protein bar", ["protein"], "PANTRY", ["powder"]),
            ]},
            {"name": "Clean Eating", "items": [
                item("Quinoa", "quinoa", ["quinoa"], "PANTRY"),
                item("Chia Seeds", "chia seeds", ["chia"], "PANTRY", ["cracker", "sachet"]),
                item("Almond Milk", "almond milk", ["almond"], "DAIRY"),
            ]},
        ]},
        {"title": "Snacks & Drinks", "bundles": [
            {"name": "Better Snacks", "items": [
                item("Rice Cakes", "rice cakes", ["rice cake", "corn cake", "thin"], "PANTRY"),
                item("Mixed Nuts", "mixed nuts", ["nut"], "PANTRY"),
                item("Popcorn", "popcorn", ["popcorn"], "PANTRY"),
            ]},
            {"name": "Hydration", "items": [
                item("Coconut Water", "coconut water", ["coconut water"], "DRINKS"),
                item("Sparkling Water", "sparkling water", ["sparkling", "mineral"], "DRINKS"),
                item("Electrolytes", "electrolyte drink", ["electrolyte", "hydralyte"], "DRINKS"),
            ]},
        ]},
    ]},
    {"id": "vegetarian-vegans", "title": "Vegetarian & Vegans", "categories": [
        {"title": "Plant Protein", "bundles": [
            {"name": "Protein Pantry", "items": [
                item("Tofu", "firm tofu", ["tofu"], "FRIDGE", ["litter", "cat", "soup", "paste"]),
                item("Chickpeas", "chickpeas", ["chickpea"], "PANTRY"),
                item("Lentils", "lentils", ["lentil"], "PANTRY"),
            ]},
            {"name": "Meat-Free Meals", "items": [
                item("Falafel", "falafel", ["falafel"], "FRIDGE"),
                item("Veggie Burgers", "plant based burger", ["burger", "patt"], "FRIDGE"),
                item("Plant-Based Sausages", "plant based sausages", ["sausage", "snag"], "FRIDGE"),
            ]},
        ]},
        {"title": "Dairy-Free", "bundles": [
            {"name": "Dairy Alternatives", "items": [
                item("Oat Milk", "oat milk", ["oat"], "DAIRY"),
                item("Vegan Cheese", "vegan cheese", ["vegan", "dairy free", "plant"], "DAIRY"),
                item("Coconut Yoghurt", "coconut yoghurt", ["coconut"], "DAIRY"),
            ]},
            {"name": "Vegan Treats", "items": [
                item("Chocolate Oat Milk", "chocolate oat milk", ["oat"], "DRINKS", also=["choc"]),
                item("Dairy-Free Ice Cream", "dairy free ice cream", ["dairy free", "vegan", "non dairy"], "FREEZER"),
                item("Hommus", "hommus dip", ["hommus", "hummus", "houmous"], "FRIDGE"),
            ]},
        ]},
    ]},
    {"id": "pet-parents", "title": "Pet Parents", "categories": [
        {"title": "Dog Care", "bundles": [
            {"name": "Dog Essentials", "items": [
                item("Dry Dog Food", "dry dog food", ["dog"], "PET", ["treat", "cat"]),
                item("Dog Treats", "dog treats", ["dog"], "PET", ["cat"]),
                item("Poo Bags", "dog poo bags", ["bag"], "PET"),
            ]},
            {"name": "Dog Grooming", "items": [
                item("Dog Shampoo", "dog shampoo", ["shampoo"], "PET"),
                item("Dental Sticks", "dog dental sticks", ["dental"], "PET"),
            ]},
        ]},
        {"title": "Cat Care", "bundles": [
            {"name": "Cat Essentials", "items": [
                item("Dry Cat Food", "dry cat food", ["cat"], "PET", ["treat", "litter", "dog"]),
                item("Wet Cat Food", "wet cat food", ["cat"], "PET", ["treat", "litter", "dog", "dry"]),
                item("Cat Litter", "cat litter", ["litter"], "PET"),
            ]},
            {"name": "Cat Treats", "items": [
                item("Cat Treats", "cat treats", ["cat"], "PET", ["dog", "litter"]),
                item("Cat Milk", "cat milk", ["milk"], "PET"),
            ]},
        ]},
    ]},
]


def search(query):
    os.makedirs(CACHE, exist_ok=True)
    path = os.path.join(CACHE, re.sub(r"[^a-z0-9]+", "-", query.lower()) + ".json")
    if os.path.exists(path):
        return json.load(open(path))
    url = "https://www.woolworths.com.au/apis/ui/Search/products?" + urllib.parse.urlencode(
        {"searchTerm": query, "pageSize": 24, "sortType": "TraderRelevance"})
    req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "application/json"})
    data = json.load(urllib.request.urlopen(req, timeout=30))
    rows = [p for group in data.get("Products") or [] for p in group["Products"]]
    json.dump(rows, open(path, "w"))
    time.sleep(0.8)
    return rows


_by_code = {}


def lookup(code):
    if code not in _by_code:
        for row in search(str(code)):
            _by_code[row["Stockcode"]] = row
    return _by_code[code]


def usable(p):
    # Third-party marketplace items (very large stockcodes) block image downloads.
    return p.get("IsAvailable") and p.get("LargeImageFile") and p["Stockcode"] < 100_000_000


def pick(spec):
    if spec["codes"]:
        return [lookup(c) for c in spec["codes"]]
    chosen, brands, names = [], set(), set()
    candidates = [p for p in search(spec["query"]) if usable(p)]
    for p in candidates:
        _by_code[p["Stockcode"]] = p
    for strict in (True, False):  # prefer different brands, then just different products
        for p in candidates:
            name = p["DisplayName"].lower()
            if not any(k in name for k in spec["keywords"]) or any(x in name for x in spec["exclude"]):
                continue
            if spec["also"] and not any(k in name for k in spec["also"]):
                continue
            brand = (p.get("Brand") or name.split()[0]).lower()
            base = re.sub(r"\s+\d+(\.\d+)?\s*(g|kg|ml|l|pack|ea)\b.*$", "", name)
            if p["Stockcode"] in [c["Stockcode"] for c in chosen] or base in names or (strict and brand in brands):
                continue
            chosen.append(p)
            brands.add(brand)
            names.add(base)
            if len(chosen) == 3:
                return chosen
    return chosen


def tag(p):
    t = (p.get("HeaderTag") or {}).get("Content")
    if not t:
        return None
    t = re.sub(r"<[^>]+>", "", t).strip().upper()
    style = "save" if t.startswith("SAVE") else "lowerShelf" if "LOWER" in t else "everydayLow" if "EVERYDAY" in t else "save"
    return {"text": t, "style": style}


def product(p, aisle):
    was = p["WasPrice"] if p.get("WasPrice") and p["WasPrice"] > p["Price"] else None
    return {
        "stockcode": p["Stockcode"], "name": p["DisplayName"].strip(), "price": p["Price"], "wasPrice": was,
        "unitPrice": (p.get("CupString") or "").replace(" / ", " per "), "tag": tag(p),
        "image": f"product-{p['Stockcode']}", "imageURL": p["LargeImageFile"], "category": aisle,
    }


def save_image(prod):
    code = prod["stockcode"]
    name = prod["image"]
    folder = os.path.join(ASSETS, name + ".imageset")
    target = os.path.join(folder, name + ".jpg")
    web = os.path.join(WEB_IMAGES, f"{code}.jpg")
    if not os.path.exists(target):
        os.makedirs(folder, exist_ok=True)
        raw = os.path.join(CACHE, f"{code}.raw.jpg")
        req = urllib.request.Request(prod["imageURL"], headers={"User-Agent": UA})
        data = urllib.request.urlopen(req, timeout=30).read()
        with open(raw, "wb") as f:
            f.write(data)
        subprocess.run(["sips", "-s", "format", "jpeg", "-s", "formatOptions", "75", "-Z", "420", raw, "--out", target],
                       check=True, capture_output=True)
        json.dump({"images": [{"filename": name + ".jpg", "idiom": "universal"}], "info": {"author": "xcode", "version": 1}},
                  open(os.path.join(folder, "Contents.json"), "w"))
    os.makedirs(WEB_IMAGES, exist_ok=True)
    if not os.path.exists(web):
        subprocess.run(["cp", target, web], check=True)


def slug(text):
    return re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")


def build():
    topics = []
    report = []
    for t in TOPICS:
        categories = []
        for c in t["categories"]:
            bundles = []
            for b in c["bundles"]:
                items = []
                for spec in b["items"]:
                    options = [product(p, spec["aisle"]) for p in pick(spec)]
                    if not options:
                        report.append(f"!! no products for {t['title']} / {b['name']} / {spec['name']}")
                        continue
                    for o in options:
                        save_image(o)
                    items.append({"name": spec["name"], "options": options})
                    report.append(f"{t['title'][:16]:16} | {b['name'][:22]:22} | {spec['name'][:18]:18} | "
                                  + " || ".join(o["name"][:48] for o in options))
                bundles.append({"id": slug(t["id"] + "-" + b["name"]), "name": b["name"], "image": b.get("image"), "items": items})
            categories.append({"title": c["title"], "bundles": bundles})
        topics.append({"id": t["id"], "title": t["title"], "categories": categories})
    return topics, report


def swift_literal(value):
    return json.dumps(value)


def swift_product(o):
    tag_code = "nil" if not o["tag"] else f'ProductTag(text: {swift_literal(o["tag"]["text"])}, style: .{o["tag"]["style"]})'
    was = "nil" if o["wasPrice"] is None else repr(o["wasPrice"])
    return (f'ShopProduct(stockcode: {o["stockcode"]}, name: {swift_literal(o["name"])}, price: {o["price"]!r}, '
            f'wasPrice: {was}, unitPrice: {swift_literal(o["unitPrice"])}, tag: {tag_code}, '
            f'image: "{o["image"]}", category: "{o["category"]}")')


def write_swift(topics):
    out = ["//", "//  WoolworthsCatalog.swift", "//  Woolworths-SwipeShop", "//",
           "//  Generated by tools/build_catalog.py from Woolworths product search results.",
           "//  Bundle card photos are openly licensed stock images; see STOCK_CREDITS.md.", "//", "",
           "import Foundation", "", "extension Topic {", "    static let all: [Topic] = ["]
    for t in topics:
        out.append(f'        Topic(id: "{t["id"]}", title: {swift_literal(t["title"])}, categories: [')
        for c in t["categories"]:
            out.append(f'            TopicCategory(title: {swift_literal(c["title"])}, bundles: [')
            for b in c["bundles"]:
                image = "nil" if not b["image"] else f'"{b["image"]}"'
                out.append(f'                ShopBundle(id: "{b["id"]}", name: {swift_literal(b["name"])}, image: {image}, items: [')
                for i in b["items"]:
                    out.append(f'                    BundleItem(name: {swift_literal(i["name"])}, options: [')
                    for o in i["options"]:
                        out.append(f"                        {swift_product(o)},")
                    out.append("                    ]),")
                out.append("                ]),")
            out.append("            ]),")
        out.append("        ]),")
    out += ["    ]", "}", ""]
    with open(os.path.join(ROOT, "Woolworths-SwipeShop", "WoolworthsCatalog.swift"), "w") as f:
        f.write("\n".join(out))


def write_js(topics):
    for t in topics:
        for c in t["categories"]:
            for b in c["bundles"]:
                for i in b["items"]:
                    for o in i["options"]:
                        o.pop("imageURL", None)
    os.makedirs(os.path.join(ROOT, "web"), exist_ok=True)
    with open(os.path.join(ROOT, "web", "catalog.js"), "w") as f:
        f.write("// Generated by tools/build_catalog.py from Woolworths product search results.\n")
        f.write("window.CATALOG = " + json.dumps(topics, indent=1) + ";\n")


def prune(topics):
    keep = {o["stockcode"] for t in topics for c in t["categories"] for b in c["bundles"] for i in b["items"] for o in i["options"]}
    for entry in os.listdir(ASSETS):
        if entry.startswith("product-") and int(entry[8:].split(".")[0]) not in keep:
            subprocess.run(["rm", "-rf", os.path.join(ASSETS, entry)], check=True)
    for entry in os.listdir(WEB_IMAGES):
        if int(entry.split(".")[0]) not in keep:
            os.remove(os.path.join(WEB_IMAGES, entry))


if __name__ == "__main__":
    topics, report = build()
    prune(topics)
    print("\n".join(report))
    write_swift(topics)
    write_js(topics)
    count = sum(len(i["options"]) for t in topics for c in t["categories"] for b in c["bundles"] for i in b["items"])
    print(f"\n{len(topics)} topics, {count} products")
