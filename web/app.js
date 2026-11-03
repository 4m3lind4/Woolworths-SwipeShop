// Swipe Shop web prototype. Mirrors the SwiftUI app: Home -> Bundles -> topic -> bundle -> swipe -> custom bundle -> cart.
(function () {
  "use strict";

  const TOPICS = window.CATALOG;
  const bundles = {};
  TOPICS.forEach((t) => t.categories.forEach((c) => c.bundles.forEach((b) => { bundles[b.id] = b; })));

  const state = {
    mode: "Delivery",
    cart: [],
    topicFilter: {},
    selected: {},
    activeBundle: null,
    chosen: [],
    swipe: null,
    showHelp: false,
  };

  const screen = document.getElementById("screen");
  const tabbar = document.getElementById("tabbar");
  const overlay = document.getElementById("overlay");
  const phone = document.getElementById("phone");

  // ---------- helpers ----------

  const esc = (s) => String(s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
  const money = (n) => "$" + n.toFixed(2);
  const productImg = (p) => `images/products/${p.stockcode}.jpg`;
  const cartCount = () => state.cart.reduce((n, l) => n + l.qty, 0);
  const go = (hash) => { location.hash = hash; };

  const ICON = {
    back: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M15 5l-7 7 7 7"/></svg>',
    cart: '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M2 3.5a1 1 0 011-1h1.6a1.5 1.5 0 011.46 1.15L6.4 5H20a1 1 0 01.97 1.24l-1.6 6.4A2 2 0 0117.43 14H8.1l.35 1.5H18a1 1 0 110 2H8.06a1.5 1.5 0 01-1.46-1.16L4.24 4.5H3a1 1 0 01-1-1z"/><circle cx="9" cy="20.2" r="1.7"/><circle cx="17" cy="20.2" r="1.7"/></svg>',
    close: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round"><path d="M6 6l12 12M18 6L6 18"/></svg>',
    undo: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 14L4 9l5-5"/><path d="M4 9h10a6 6 0 010 12h-3"/></svg>',
    swap: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M7 20V4M3 8l4-4 4 4M17 4v16M13 16l4 4 4-4"/></svg>',
    info: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="9.5"/><path d="M12 11v6" stroke-linecap="round"/><circle cx="12" cy="7.6" r="1.2" fill="currentColor" stroke="none"/></svg>',
    infoFill: '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 2a10 10 0 100 20 10 10 0 000-20zm1 15h-2v-6h2zm-1-8.2a1.3 1.3 0 110-2.6 1.3 1.3 0 010 2.6z"/></svg>',
    check: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12.5l4.5 4.5L19 7.5"/></svg>',
    minus: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.8" stroke-linecap="round"><path d="M5 12h14"/></svg>',
    plus: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.8" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>',
    credit: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="9.5"/><path d="M15 9.2a4 4 0 100 5.6" stroke-linecap="round"/></svg>',
    pencil: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 20l4-1 11-11-3-3L5 16z"/></svg>',
    hand: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 12h13M13 7l5 5-5 5"/></svg>',
    tick: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="9.5"/><path d="M8 12.5l3 3 5-6" stroke-linecap="round" stroke-linejoin="round"/></svg>',
  };

  const cartIcon = () => `<span class="cart-icon">${ICON.cart}${cartCount() ? `<span class="badge">${cartCount()}</span>` : ""}</span>`;

  const tagHTML = (tag) => (tag ? `<span class="ptag ${tag.style}">${esc(tag.text)}</span>` : "");

  const percentOff = (p) => {
    if (!p.wasPrice) return null;
    const pct = Math.round(((p.wasPrice - p.price) / p.wasPrice) * 100);
    return pct >= 10 ? pct : null;
  };

  const shelfPrice = (price) => {
    const cents = Math.round(price * 100);
    return `<span class="shelf" aria-label="${money(price)}"><span class="d">$${Math.floor(cents / 100)}</span><sup>${String(cents % 100).padStart(2, "0")}</sup></span>`;
  };

  // A region of a full-screen artwork, like the Figma "Original artwork" crops.
  const crop = (image, canvasW, canvasH, x, y, w, h, extra = "") =>
    `<div class="crop" style="width:${w}px;height:${h}px;background-image:url(images/${image});background-size:${canvasW}px ${canvasH}px;background-position:-${x}px -${y}px;${extra}" aria-hidden="true"></div>`;
  const homeCrop = (x, y, w, h) => crop("home-artwork.jpg", 403.147, 874, x, y, w, h);
  const bundlesCrop = (x, y, w, h, extra) => crop("bundles-photography.jpg", 416.919, 904.502, x, y, w, h, extra);

  const collage = (images, size) => {
    const mid = Math.floor(images.length / 2);
    return `<div class="collage" aria-hidden="true">${images.map((src, i) =>
      `<div class="p" style="width:${size}px;height:${size}px;margin-left:${i ? -size * 0.28 : 0}px;transform:rotate(${(i - mid) * 4}deg);z-index:${images.length - Math.abs(i - mid)}"><img src="${src}" alt=""></div>`).join("")}</div>`;
  };

  const navbar = (title) => `
    <header class="navbar">
      <button class="circle-btn" data-action="back" aria-label="Back">${ICON.back}</button>
      <h1>${esc(title)}</h1>
      <button class="circle-btn" data-action="cart" aria-label="Cart, ${cartCount()} items">${cartIcon()}</button>
    </header>`;

  // ---------- tab bar ----------

  const TABS = [["home", "Home"], ["lists", "Lists"], ["products", "Products"], ["specials", "Specials"], ["more", "More"]];
  function renderTabbar(active) {
    tabbar.innerHTML = TABS.map(([id, label]) =>
      `<button class="tab ${id === active ? "active" : ""}" data-action="tab" data-tab="${id}" ${id === active ? 'aria-current="page"' : ""}>
        <img src="images/icons/tab-${id}.svg" alt=""><span>${label}</span></button>`).join("");
  }

  // ---------- screens ----------

  function homeScreen() {
    const modes = ["Pick up", "Delivery", "In-store"].map((m) =>
      `<button class="mode ${m === state.mode ? "active" : ""}" data-action="mode" data-mode="${m}">${m}<img src="images/icons/chevron-down-grey.svg" alt=""></button>`).join("");
    const cat = (label, art, action) =>
      `<${action ? 'button data-action="go" data-to="#/bundles"' : "div"} class="cat-card"><div class="art">${art}</div><div class="label">${label}</div></${action ? "button" : "div"}>`;
    return `
      <div class="home">
        <div class="home-top">
          <div class="modes">${modes}</div>
          <div class="account"><img src="images/icons/icon-message.svg" alt=""><button data-action="cart" aria-label="Cart, ${cartCount()} items">${cartIcon()}</button></div>
        </div>
        <div class="address">Set a delivery address</div>
        <div class="search-row">
          <div class="search"><img src="images/icons/icon-search.svg" alt=""><span>Search products</span><img src="images/icons/icon-scan-barcode.svg" alt=""></div>
          ${homeCrop(347.5, 185.83, 40.94, 45.14)}
        </div>
        <div class="categories hscroll">
          ${cat("Smart Basket", homeCrop(30.45, 264.57, 65.09, 65.09))}
          ${cat("Weekly\nCatalogue", homeCrop(137.53, 264.57, 65.09, 65.09))}
          ${cat("Half Price\nSpecials", homeCrop(243.57, 264.57, 65.09, 65.09))}
          ${cat("Free Food\nContainers", `<img src="images/icons/bundles-ellipse.svg" alt="" style="position:absolute;left:1px;top:3.4px;width:59px">${crop("home-artwork.jpg", 403.147, 874, 350.65, 264.57, 65.09, 65.09, "position:absolute")}`)}
          ${cat("Personalised\nBundles", `<img src="images/icons/bundles-ellipse.svg" alt="" style="position:absolute;left:3px;top:3px;width:59px"><img src="images/icons/bundles-category-icon.svg" alt="" style="position:absolute;left:11px;top:16px;width:42px">`, true)}
        </div>
        <div class="rewards-row">
          <div class="rewards">
            <div class="top"><span>4 of 12 offers boosted ›</span><span><b>172</b><small> / 2000</small></span></div>
            <div class="track"><i></i></div>
            <div><em>1828</em> more points to collect your reward</div>
          </div>
          <div class="show-card"><div class="r-logo">r</div>Show<br>Card</div>
        </div>
        <div class="promos hscroll">
          <div class="promo">
            ${homeCrop(15.75, 507.08, 343.3, 171.13)}
            <h2>Buy 1 Get 1 Bonus Credit</h2>
            <p>Buy ONE of these participating products in<br>a $20 shop^</p>
            <small>^T&amp;Cs apply. While stocks last.</small>
          </div>
          ${homeCrop(375.85, 507.08, 27.3, 287.66)}
        </div>
        <div class="more-ways"><h3>More ways to save and earn</h3><p>Top Specials and Online Boosts on what you love</p></div>
      </div>`;
  }

  const TILES = [
    { title: "New \nParents", topic: "new-parents", pieces: [{ x: 67.5, y: -2.08, w: 66.42, h: 60.07, sx: 204.93, sy: 478.4 }] },
    { title: "Expecting Parents", topic: "expecting-parents", pieces: [{ x: 23.32, y: 0, w: 47.35, h: 31.8, sx: 169.59, sy: 297.5 }, { x: 70.66, y: 0, w: 54.41, h: 85.5, sx: 216.94, sy: 297.5 }] },
    { title: "Students", topic: "students", left: 6.65, top: 55.1, pieces: [{ w: 68.54, h: 85.5, sx: 331.42, sy: 297.5, rot: -58.37, cx: 88.99, cy: 10 }] },
    { title: "Busy Workers", topic: "busy-workers", pieces: [{ x: 58.65, y: -14, w: 63.6, h: 64.3, sx: 78.44, sy: 387.24 }] },
    { title: "Remote Workers", topic: "remote-workers", top: 40.5, pieces: [{ x: 16.96, y: 0, w: 41.69, h: 34.63, sx: 163.23, sy: 387.24 }, { x: 58.65, y: 0, w: 66.42, h: 61.48, sx: 204.93, sy: 387.24 }] },
    { title: "Senior\nShoppers", topic: "senior-shoppers", top: 38.4, pieces: [{ x: 70.66, y: 0, w: 54.41, h: 86.21, sx: 345.55, sy: 387.24 }] },
    { title: "Health\nConcious", topic: "health-concious", top: 40, pieces: [{ x: 84.09, y: 46.64, w: 40.99, h: 38.87, sx: 101.05, sy: 525.04 }, { x: 77.73, y: 26.15, w: 47.35, h: 20.49, sx: 94.69, sy: 504.54 }, { x: 67.13, y: 0, w: 57.95, h: 26.15, sx: 84.09, sy: 478.4 }] },
    { title: "Vegetarian &\nVegans", topic: "vegetarian-vegans", left: 8.1, top: 40.5, pieces: [{ w: 58, h: 86, sx: 76.32, sy: 297.5, rot: -75.16, cx: 93.14, cy: 11.05 }] },
    { title: "Pet\nParents", topic: "pet-parents", left: 10, top: 40, pieces: [{ x: 24.73, y: 0, w: 43.81, h: 26.85, sx: 298.91, sy: 478.4 }, { x: 68.54, y: -10.3, w: 56.53, h: 64.3, sx: 343.43, sy: 478.4 }] },
  ];

  function bundlesScreen() {
    const tiles = TILES.map((t) => {
      const topic = TOPICS.find((x) => x.id === t.topic);
      const pieces = t.pieces.map((p) => {
        const cx = p.cx ?? p.x + p.w / 2;
        const cy = p.cy ?? p.y + p.h / 2;
        return bundlesCrop(p.sx, p.sy, p.w, p.h, `position:absolute;left:${cx}px;top:${cy}px;transform:translate(-50%,-50%) rotate(${p.rot || 0}deg)`);
      }).join("");
      return `<button class="tile" data-action="go" data-to="#/topic/${t.topic}" aria-label="${esc(topic.title)}">
        <span class="t" style="left:${t.left ?? 7.8}px;top:${t.top ?? 41}px">${esc(t.title)}</span>${pieces}</button>`;
    }).join("");
    const made = ["6014355", "6007813", "140756", "429223"].map((c) => `images/products/${c}.jpg`);
    return `
      ${navbar("Bundles")}
      <div class="page">
        <div class="hero">
          <h2>Personalised Bundles</h2>
          <p>We know <b>how hard life</b> can be tap on the category you fit best</p>
          <p>The just swipe to add the right product</p>
          <div class="logo" aria-hidden="true">
            <span style="left:41px;top:63px;opacity:.25;transform:translate(-50%,-50%) rotate(10deg)"></span>
            <span style="left:57px;top:64px;opacity:.45;transform:translate(-50%,-50%) rotate(2deg)"></span>
            <span style="left:73px;top:64px;transform:translate(-50%,-50%) rotate(-8deg)"></span>
            <img src="images/icons/logo-cart.svg" alt="">
          </div>
        </div>
        <div class="made">${collage(made, 104)}<strong>Made for you</strong></div>
        <div class="tiles">${tiles}</div>
      </div>`;
  }

  function bundleCard(b) {
    const img = b.image
      ? `<img src="images/stock/${b.image}.jpg" alt="">`
      : collage(b.items.slice(0, 3).map((i) => productImg(i.options[0])), 62);
    return `<button class="bundle-card" data-action="go" data-to="#/bundle/${b.id}">
      <div class="img">${img}</div>
      <div class="body"><h3>${esc(b.name)}</h3><p>${b.items.length} items</p></div></button>`;
  }

  function topicScreen(id) {
    const topic = TOPICS.find((t) => t.id === id);
    if (!topic) return placeholder("Not found");
    const filter = state.topicFilter[id] ?? null;
    const chips = [`<button class="chip ${filter === null ? "active" : ""}" data-action="filter" data-topic="${id}" data-value="">All</button>`]
      .concat(topic.categories.map((c) =>
        `<button class="chip ${filter === c.title ? "active" : ""}" data-action="filter" data-topic="${id}" data-value="${esc(c.title)}">${esc(c.title)}</button>`)).join("");
    const sections = topic.categories.filter((c) => filter === null || c.title === filter).map((c) => `
      <div class="section-title"><h2>${esc(c.title)}</h2></div>
      <div class="cards hscroll">${c.bundles.map(bundleCard).join("")}</div>`).join("");
    return `
      ${navbar(topic.title)}
      <div class="chips hscroll">${chips}</div>
      ${sections}
      <div class="note"><img src="images/icons/icon-swap.svg" alt=""><span>Bundles are a starting point. Swap brands or sizes on the next screen.</span></div>`;
  }

  function help() {
    const steps = [
      [ICON.tick, "Tap items to choose which ones to swipe. Leave them all unticked to swipe the whole bundle."],
      [ICON.pencil, "Edit Items ticks or unticks everything at once."],
      [ICON.hand, "Swipe right or tap Buy it to add a product to your bundle."],
      [ICON.close, "Swipe left or tap Remove to skip it."],
      [ICON.swap, "Swipe up for a different product, or down to go back to the previous one."],
    ];
    return `<div class="popover" role="dialog" aria-label="How Swipe shop works"><h3>How Swipe shop works</h3><ul>${steps.map(([i, t]) => `<li>${i}<span>${t}</span></li>`).join("")}</ul></div>`;
  }

  function bundleScreen(id) {
    const b = bundles[id];
    if (!b) return placeholder("Not found");
    const sel = state.selected[id] || (state.selected[id] = new Set());
    const rows = b.items.map((item) => {
      const on = sel.has(item.name);
      return `<button class="row" data-action="toggle" data-bundle="${id}" data-item="${esc(item.name)}" aria-pressed="${on}">
        <span class="check ${on ? "on" : ""}">${on ? ICON.check : ""}</span>
        <img src="${productImg(item.options[0])}" alt="">
        <span class="name">${esc(item.name)}</span>
        <span class="meta">${item.options.length} option${item.options.length === 1 ? "" : "s"}</span></button>`;
    }).join("");
    return `
      ${navbar(b.name)}
      <div class="detail">
        <div class="section-title"><h2>Personalised</h2>
          <button class="info-btn" data-action="help" aria-label="How Swipe shop works" aria-expanded="${state.showHelp}">${ICON.info}</button>
          ${state.showHelp ? help() : ""}
        </div>
        <div class="p-card">
          <div class="banner">${collage(b.items.slice(0, 4).map((i) => productImg(i.options[0])), 96)}</div>
          <div class="rows">${rows}</div>
          <div class="footer">
            <button class="edit-btn" data-action="edit-all" data-bundle="${id}">Edit Items ${ICON.pencil.replace("<svg", '<svg width="11" height="11"')}</button>
            <button class="green-btn" data-action="swipe" data-bundle="${id}">Swipe shop <img src="images/icons/arrow-right-white.svg" alt=""></button>
          </div>
        </div>
      </div>`;
  }

  function customScreen() {
    const b = state.activeBundle;
    if (!b) return placeholder("Swipe through a bundle first.");
    const total = state.chosen.reduce((n, p) => n + p.price, 0);
    const rows = state.chosen.map((p) => `
      <div class="row"><img src="${productImg(p)}" alt=""><span class="name">${esc(p.name)}</span><span class="meta">x1</span><span>${money(p.price)}</span></div>`).join("");
    return `
      ${navbar("Custom Bundle 1")}
      <div class="detail">
        <div class="section-title"><h2>${esc(b.name)}</h2></div>
        <div class="p-card">
          <div class="banner">${collage(state.chosen.slice(0, 5).map(productImg), 96)}</div>
          <div class="rows">
            ${rows || '<p class="meta">You didn\'t keep any items. Tap Edit Items to swipe again.</p>'}
            <div class="total"><span>TOTAL</span><span>${money(total)}</span></div>
          </div>
          <div class="footer">
            <button class="edit-btn" data-action="reswipe">Edit Items ${ICON.pencil.replace("<svg", '<svg width="11" height="11"')}</button>
            <button class="green-btn" data-action="add-bundle" ${state.chosen.length ? "" : "disabled"}>${ICON.plus.replace("<svg", '<svg width="16" height="16"')} Add to Cart</button>
          </div>
        </div>
      </div>`;
  }

  function cartScreen() {
    if (!state.cart.length) {
      return `${navbar("Cart")}<div class="empty">${ICON.cart}<h2>Your cart is empty</h2><p>Add a bundle or swipe shop to fill your trolley.</p></div>`;
    }
    const subtotal = state.cart.reduce((n, l) => n + l.price * l.qty, 0);
    const saving = state.cart.reduce((n, l) => n + ((l.wasPrice || l.price) - l.price) * l.qty, 0);
    const aisles = [...new Set(state.cart.map((l) => l.category))];
    const lines = aisles.map((aisle) => `
      <div class="aisle">${esc(aisle)}</div>
      ${state.cart.filter((l) => l.category === aisle).map((l) => `
        <div class="line">
          <img src="${productImg(l)}" alt="">
          <div class="col">
            ${tagHTML(l.tag)}
            <div class="name">${esc(l.name)}</div>
            <div class="bottom">
              <div class="stepper">
                <button data-action="qty" data-id="${l.stockcode}" data-delta="-1" ${l.qty > 1 ? "" : "disabled"} aria-label="Decrease quantity">${ICON.minus}</button>
                <span>${l.qty}</span>
                <button data-action="qty" data-id="${l.stockcode}" data-delta="1" aria-label="Increase quantity">${ICON.plus}</button>
              </div>
              <div class="amt">${money(l.price * l.qty)}${l.wasPrice ? `<s>Was ${money(l.wasPrice * l.qty)}</s>` : ""}</div>
            </div>
          </div>
          <button class="x" data-action="remove-line" data-id="${l.stockcode}" aria-label="Remove ${esc(l.name)}">${ICON.close}</button>
        </div>`).join("")}`).join("");
    return `
      ${navbar("")}
      <div class="cart-head"><h1>Cart</h1><p>${cartCount()} ${cartCount() === 1 ? "item" : "items"}</p></div>
      <div class="cart-row"><span class="r">r</span><span>Collect ${Math.floor(subtotal)} pts</span></div>
      <div class="cart-row">${ICON.credit}<span class="grow">Earn 1 credit</span>${ICON.info.replace("<svg", '<svg style="color:#8a8a8e"')}</div>
      ${lines}
      <div class="cart-footer">
        <div class="sub"><span>Subtotal</span><b>${money(subtotal)}</b></div>
        <div class="fees"><span>Excl. service, bag &amp; collection fees</span>${saving > 0 ? `<span class="saving">🎉 SAVING ${money(saving)}</span>` : ""}</div>
        <button class="checkout" data-action="checkout">Checkout</button>
      </div>`;
  }

  const placeholder = (text) => `<div class="placeholder">${esc(text)}</div>`;

  // ---------- swipe deck ----------

  function openSwipe(items, onFinish) {
    state.swipe = { items, index: 0, option: items.map(() => 0), history: [], onFinish, enter: null };
    overlay.hidden = false;
    renderSwipe();
  }

  function closeSwipe() {
    state.swipe = null;
    overlay.hidden = true;
    overlay.innerHTML = "";
  }

  function renderSwipe() {
    const s = state.swipe;
    const item = s.items[s.index];
    const remaining = s.items.length - s.index;
    let card = "";
    if (item) {
      const opt = s.option[s.index];
      const p = item.options[opt];
      const pct = percentOff(p);
      const hint = opt + 1 < item.options.length ? " Swipe up for another option." : opt > 0 ? " Swipe down for the previous option." : "";
      card = `
        <div class="card ${s.enter ? "enter-" + s.enter : ""}" id="card" role="group" aria-label="${esc(p.name)}">
          <div class="shot">
            <img src="${productImg(p)}" alt="">
            ${p.tag ? `<span class="tag">${tagHTML(p.tag)}</span>` : ""}
            ${pct ? `<span class="roundel"><b>${pct}%</b><small>Off</small></span>` : ""}
            <div class="dots" aria-label="Option ${opt + 1} of ${item.options.length}">${item.options.map((_, i) => `<i class="${i === opt ? "on" : ""}"></i>`).join("")}</div>
            <span class="stamp buy" id="stamp-buy">BUY</span>
            <span class="stamp nope" id="stamp-nope">NOPE</span>
          </div>
          <div class="info">
            <h2>${esc(p.name)}</h2>
            <div class="price-row">${shelfPrice(p.price)}<span class="unit">${esc(p.unitPrice)}</span></div>
            ${p.wasPrice ? `<div class="was">Was ${money(p.wasPrice)}</div>` : ""}
            <div class="hint">${ICON.infoFill}<span>Would you put this in your trolley?${hint}</span></div>
          </div>
        </div>`;
    }
    const hasNext = item && s.option[s.index] + 1 < item.options.length;
    overlay.innerHTML = `
      <div class="swipe" style="display:contents">
        <div class="swipe-top">
          <button class="circle-btn" data-action="swipe-close" aria-label="Close">${ICON.close}</button>
          <button class="circle-btn" data-action="swipe-undo" aria-label="Undo" ${s.history.length ? "" : "disabled"}>${ICON.undo}</button>
        </div>
        <h1>Bundles</h1>
        <div class="current"><div>Current item: <b>${item ? esc(item.name) : "Done"}</b></div><span>${Math.min(s.index + 1, s.items.length)} of ${s.items.length}</span></div>
        <div class="progress"><i style="width:${(s.index / Math.max(s.items.length, 1)) * 100}%"></i></div>
        <div class="stack">
          ${remaining > 2 ? '<div class="back" style="width:290px;transform:translateY(30px);opacity:.6"></div>' : ""}
          ${remaining > 1 ? '<div class="back" style="width:318px;transform:translateY(16px);opacity:.85"></div>' : ""}
          ${card}
        </div>
        <div class="actions">
          <button class="action remove" data-action="decide" data-decision="remove" ${item ? "" : "disabled"}><span>${ICON.close}</span>Remove</button>
          <button class="action sub" data-action="swap" data-dir="up" ${hasNext ? "" : "disabled"}><span>${ICON.swap}</span>Substitute</button>
          <button class="action buy" data-action="decide" data-decision="buy" ${item ? "" : "disabled"}><span>${ICON.cart}</span>Buy it</button>
        </div>
      </div>`;
    s.enter = null;
    attachDrag();
  }

  function setCard(dx, dy, cls) {
    const card = document.getElementById("card");
    if (!card) return;
    card.classList.remove("anim", "settle");
    if (cls) card.classList.add(cls);
    card.style.transform = `translate(${dx}px, ${dy}px) rotate(${dx / 20}deg)`;
    document.getElementById("stamp-buy").style.opacity = Math.max(0, Math.min(1, dx / 100));
    document.getElementById("stamp-nope").style.opacity = Math.max(0, Math.min(1, -dx / 100));
  }

  function attachDrag() {
    const card = document.getElementById("card");
    if (!card) return;
    let start = null;
    card.addEventListener("pointerdown", (e) => {
      start = { x: e.clientX, y: e.clientY };
      card.setPointerCapture(e.pointerId);
      card.classList.add("dragging");
    });
    card.addEventListener("pointermove", (e) => {
      if (!start) return;
      setCard(e.clientX - start.x, e.clientY - start.y);
    });
    const end = (e) => {
      if (!start) return;
      const dx = e.clientX - start.x;
      const dy = e.clientY - start.y;
      start = null;
      card.classList.remove("dragging");
      if (Math.abs(dx) > Math.abs(dy)) {
        if (dx > 120) return decide("buy");
        if (dx < -120) return decide("remove");
      } else {
        if (dy < -90) return swap("up");
        if (dy > 90) return swap("down");
      }
      setCard(0, 0, "settle");
    };
    card.addEventListener("pointerup", end);
    card.addEventListener("pointercancel", end);
  }

  function decide(decision) {
    const s = state.swipe;
    if (!s || !s.items[s.index]) return;
    setCard(decision === "buy" ? 600 : -600, 40, "anim");
    setTimeout(() => {
      s.history.push({ index: s.index, option: s.option[s.index], decision });
      s.index += 1;
      if (s.index >= s.items.length) {
        const chosen = s.history.filter((h) => h.decision === "buy").map((h) => s.items[h.index].options[h.option]);
        const done = s.onFinish;
        closeSwipe();
        done(chosen);
      } else {
        renderSwipe();
      }
    }, 200);
  }

  // Up shows the next option, down the previous one; there's no wrap-around, so options never repeat.
  function swap(dir) {
    const s = state.swipe;
    const item = s && s.items[s.index];
    if (!item) return;
    const next = s.option[s.index] + (dir === "up" ? 1 : -1);
    if (next < 0 || next >= item.options.length) return setCard(0, 0, "settle");
    s.option[s.index] = next;
    s.enter = dir;
    renderSwipe();
  }

  function undo() {
    const s = state.swipe;
    const last = s && s.history.pop();
    if (!last) return;
    s.index = last.index;
    s.option[s.index] = last.option;
    renderSwipe();
  }

  // ---------- cart ----------

  function addToCart(p) {
    const line = state.cart.find((l) => l.stockcode === p.stockcode);
    if (line) line.qty += 1;
    else state.cart.push({ ...p, qty: 1 });
  }

  function alertBox(title, message, onDone) {
    const scrim = document.createElement("div");
    scrim.className = "alert-scrim";
    scrim.innerHTML = `<div class="alert" role="alertdialog" aria-labelledby="alert-title"><h2 id="alert-title">${esc(title)}</h2><p>${esc(message)}</p><button>Done</button></div>`;
    phone.appendChild(scrim);
    const btn = scrim.querySelector("button");
    btn.focus();
    btn.addEventListener("click", () => { scrim.remove(); onDone(); });
  }

  // ---------- routing and events ----------

  function render() {
    const [name, arg] = (location.hash.replace(/^#\/?/, "") || "home").split("/");
    const tab = ["lists", "products", "specials", "more"].includes(name) ? name : "home";
    let html;
    switch (name) {
      case "bundles": html = bundlesScreen(); break;
      case "topic": html = topicScreen(arg); break;
      case "bundle": html = bundleScreen(arg); break;
      case "custom": html = customScreen(); break;
      case "cart": html = cartScreen(); break;
      case "lists": case "products": case "specials": case "more":
        html = placeholder(`${name[0].toUpperCase() + name.slice(1)} isn't part of this prototype.`); break;
      default: html = homeScreen();
    }
    const scrollKey = location.hash;
    const keepScroll = render.last === scrollKey ? screen.scrollTop : 0;
    screen.innerHTML = html;
    screen.scrollTop = keepScroll;
    render.last = scrollKey;
    screen.classList.toggle("no-tabbar", name === "cart");
    tabbar.hidden = name === "cart";
    renderTabbar(tab);
  }

  document.addEventListener("click", (e) => {
    const el = e.target.closest("[data-action]");
    if (!el || el.disabled) {
      if (state.showHelp && !e.target.closest(".popover")) { state.showHelp = false; render(); }
      return;
    }
    const d = el.dataset;
    switch (d.action) {
      case "go": go(d.to); break;
      case "back": history.length > 1 ? history.back() : go("#/home"); break;
      case "cart": if (!location.hash.startsWith("#/cart")) go("#/cart"); break;
      case "tab": go("#/" + d.tab); break;
      case "mode": state.mode = d.mode; render(); break;
      case "filter": state.topicFilter[d.topic] = d.value || null; render(); break;
      case "help": state.showHelp = !state.showHelp; render(); break;
      case "toggle": {
        const sel = state.selected[d.bundle];
        sel.has(d.item) ? sel.delete(d.item) : sel.add(d.item);
        render();
        break;
      }
      case "edit-all": {
        const b = bundles[d.bundle];
        const sel = state.selected[d.bundle];
        state.selected[d.bundle] = sel.size === b.items.length ? new Set() : new Set(b.items.map((i) => i.name));
        render();
        break;
      }
      case "swipe": {
        const b = bundles[d.bundle];
        const sel = state.selected[d.bundle];
        const deck = sel.size ? b.items.filter((i) => sel.has(i.name)) : b.items;
        openSwipe(deck, (chosen) => { state.activeBundle = b; state.chosen = chosen; go("#/custom"); });
        break;
      }
      case "reswipe":
        openSwipe(state.activeBundle.items, (chosen) => { state.chosen = chosen; render(); });
        break;
      case "add-bundle": state.chosen.forEach(addToCart); go("#/cart"); break;
      case "qty": {
        const line = state.cart.find((l) => String(l.stockcode) === d.id);
        line.qty = Math.max(1, line.qty + Number(d.delta));
        render();
        break;
      }
      case "remove-line": state.cart = state.cart.filter((l) => String(l.stockcode) !== d.id); render(); break;
      case "checkout": {
        const total = state.cart.reduce((n, l) => n + l.price * l.qty, 0);
        alertBox("Order placed", `Thanks for shopping with Swipe Shop. Your ${money(total)} order is on its way.`, () => { state.cart = []; go("#/home"); });
        break;
      }
      case "swipe-close": closeSwipe(); break;
      case "swipe-undo": undo(); break;
      case "decide": decide(d.decision); break;
      case "swap": swap(d.dir); break;
    }
  });

  document.addEventListener("keydown", (e) => {
    if (!state.swipe) return;
    if (e.key === "ArrowRight") decide("buy");
    else if (e.key === "ArrowLeft") decide("remove");
    else if (e.key === "ArrowUp") { e.preventDefault(); swap("up"); }
    else if (e.key === "ArrowDown") { e.preventDefault(); swap("down"); }
    else if (e.key === "Escape") closeSwipe();
  });

  window.addEventListener("hashchange", () => { state.showHelp = false; render(); });
  render();
})();
