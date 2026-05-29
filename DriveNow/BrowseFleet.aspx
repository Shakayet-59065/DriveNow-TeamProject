<%-- DriveNow — Browse Fleet Page (BrowseFleet.aspx)
     This is the public page where customers can browse all available vehicles.
     Features:
       - A live search bar to filter by make, model, or registration
       - Filter buttons (All, Saloon, SUV, Electric, Premium, etc.)
       - Vehicle cards showing image, name, seats, and daily rate
       - Currency selector to view prices in GBP, EUR, or USD
       - A booking prompt banner at the top
     Vehicles are loaded from the database by BrowseFleet.aspx.cs using VehicleManager.
     Photos are provided by the CarImages helper class using Unsplash CDN.
     Module: CTEC2713N | Developer: Ushna --%>
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BrowseFleet.aspx.cs" Inherits="DriveNow.BrowseFleet" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Browse Our Fleet — DriveNow</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;800&family=DM+Sans:opsz,wght@9..40,400;9..40,500&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <style>
        :root {
            --navy: #1A2332; --navy-deep: #0D1520; --teal: #006b5f;
            --teal-light: #4fdbc8; --white: #FFFFFF; --grey: #94A3B8;
            --font-head: 'Outfit', Arial, sans-serif; --font-body: 'DM Sans', Arial, sans-serif;
            /* Stitch tokens */
            --st-surface: #f4fbf8; --st-surface-container: #e9efec;
            --st-outline-var: #bbcac6; --st-text-dark: #1a2421; --st-text-mid: #6c7a77;
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: var(--font-body); background: var(--st-surface); color: var(--st-text-dark); min-height: 100vh; }

        /* NAV */
        nav { display: flex; align-items: center; justify-content: space-between; padding: 1rem 2rem; background: #fff; backdrop-filter: blur(12px); position: sticky; top: 0; z-index: 100; border-bottom: 1px solid var(--st-outline-var); box-shadow: 0 1px 8px rgba(0,0,0,.06); }
        .nav-logo { font-family: var(--font-head); font-size: 1.4rem; font-weight: 800; color: var(--st-text-dark); text-decoration: none; }
        .nav-logo span { color: var(--teal); }
        .nav-links { display: flex; gap: 1.5rem; align-items: center; }
        .nav-links a { color: var(--st-text-mid); text-decoration: none; font-size: .93rem; transition: color .2s; }
        .nav-links a:hover { color: var(--teal); }
        .btn { display: inline-flex; align-items: center; gap: .4rem; padding: .6rem 1.4rem; border-radius: 8px; font-family: var(--font-head); font-weight: 600; font-size: .88rem; text-decoration: none; border: none; cursor: pointer; transition: all .2s; }
        .btn-teal { background: var(--teal); color: #fff; }
        .btn-teal:hover { background: #005048; }
        .btn-ghost { background: transparent; color: var(--st-text-dark); border: 1.5px solid var(--st-outline-var); }
        .btn-ghost:hover { border-color: var(--teal); color: var(--teal); }

        /* HEADER */
        .page-header { padding: 4rem 2rem 2.5rem; text-align: center; background: var(--st-surface); }
        .page-header .label { font-family: var(--font-head); font-size: .78rem; font-weight: 700; letter-spacing: .12em; text-transform: uppercase; color: var(--teal); margin-bottom: .8rem; }
        .page-header h1 { font-family: var(--font-head); font-size: clamp(2rem, 5vw, 3rem); font-weight: 800; margin-bottom: .8rem; color: var(--st-text-dark); }
        .page-header p { color: var(--st-text-mid); max-width: 520px; margin: 0 auto; }

        /* FILTER BAR */
        .filter-section { padding: 0 2rem 2rem; max-width: 900px; margin: 0 auto; }
        .filter-row { display: flex; gap: .6rem; justify-content: center; flex-wrap: wrap; margin-bottom: .75rem; }
        .filter-row-label { text-align: center; font-size: .72rem; font-weight: 700; letter-spacing: .1em; text-transform: uppercase; color: var(--st-text-mid); margin-bottom: .5rem; }
        .filter-btn { padding: .45rem 1.1rem; border-radius: 99px; font-family: var(--font-head); font-size: .82rem; font-weight: 600; border: 1.5px solid var(--st-outline-var); background: #fff; color: var(--st-text-mid); cursor: pointer; transition: all .2s; white-space: nowrap; }
        .filter-btn:hover { border-color: var(--teal); color: var(--teal); }
        .filter-btn.active { border-color: var(--teal); background: var(--teal); color: #fff; }
        .filter-divider { width: 1px; height: 28px; background: var(--st-outline-var); margin: 0 .5rem; align-self: center; }
        .no-results { text-align: center; padding: 3rem 1rem; color: var(--st-text-mid); display: none; }
        .no-results p { margin-top: .4rem; font-size: .9rem; }

        /* GRID */
        .fleet-section { max-width: 1200px; margin: 0 auto; padding: 0 2rem 5rem; }
        .fleet-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 1.5rem; }
        .car-card { background: #fff; border: 1px solid var(--st-outline-var); border-radius: 14px; overflow: hidden; transition: transform .25s, border-color .25s, box-shadow .25s; }
        .car-card:hover { transform: translateY(-5px); border-color: var(--teal); box-shadow: 0 12px 32px rgba(0,107,95,.12); }
        .car-img { width: 100%; aspect-ratio: 16/10; object-fit: cover; display: block; transition: transform .3s ease; }
        .car-card:hover .car-img { transform: scale(1.04); }
        .car-body { padding: 1.3rem; }
        .car-badge { display: inline-block; font-size: .72rem; font-weight: 700; letter-spacing: .08em; text-transform: uppercase; padding: .2rem .65rem; border-radius: 99px; background: rgba(0,107,95,.08); color: var(--teal); margin-bottom: .85rem; border: 1px solid rgba(0,107,95,.2); }
        .car-name { font-family: var(--font-head); font-size: 1.12rem; font-weight: 700; margin-bottom: .5rem; color: var(--st-text-dark); }
        .car-reg { font-size: .8rem; color: var(--st-text-mid); margin-bottom: 1rem; }
        .car-specs { display: flex; gap: 1rem; margin-bottom: 1.2rem; flex-wrap: wrap; }
        .spec { display: flex; align-items: center; gap: .35rem; font-size: .82rem; color: var(--st-text-mid); }
        .spec-icon { font-size: .95rem; }
        .car-footer { display: flex; align-items: center; justify-content: space-between; padding-top: 1rem; border-top: 1px solid var(--st-outline-var); }
        .car-rate { font-family: var(--font-head); font-size: 1.25rem; font-weight: 800; color: var(--teal); }
        .car-rate span { font-size: .78rem; font-weight: 400; color: var(--st-text-mid); }
        .btn-book { padding: .52rem 1.2rem; border-radius: 8px; font-family: var(--font-head); font-size: .85rem; font-weight: 600; background: var(--teal); color: #fff; text-decoration: none; border: none; cursor: pointer; transition: background .2s; }
        .btn-book:hover { background: #005048; }

        /* EMPTY / ERROR */
        .empty-state { text-align: center; padding: 5rem 1rem; color: var(--st-text-mid); }
        .empty-state h3 { font-family: var(--font-head); font-size: 1.3rem; margin-bottom: .5rem; color: var(--st-text-dark); }

        /* TOAST */
        .toast { display: none; position: fixed; bottom: 2rem; left: 50%; transform: translateX(-50%); background: #fff; border: 1px solid var(--teal); color: var(--st-text-dark); padding: .9rem 2rem; border-radius: 10px; font-size: .9rem; z-index: 999; box-shadow: 0 8px 30px rgba(0,0,0,.15); }
        .toast.show { display: block; animation: fadeIn .3s ease; }
        @keyframes fadeIn { from { opacity:0; transform: translateX(-50%) translateY(10px); } to { opacity:1; transform: translateX(-50%) translateY(0); } }

        /* CURRENCY SELECT */
        select option { background: #fff; color: var(--st-text-dark); }

        /* FOOTER */
        footer { text-align: center; padding: 2rem; color: var(--st-text-mid); font-size: .83rem; border-top: 1px solid var(--st-outline-var); background: var(--st-surface-container); }

        /* ── Tablet: 640–899px ── */
        @media (max-width: 899px) {
            .fleet-grid { grid-template-columns: repeat(2, 1fr); gap: 1rem; }
            .fleet-section { padding: 0 1.2rem 3rem; }
            .filter-section { padding: 0 1.2rem 1.5rem; }
            .page-header { padding: 2.5rem 1.2rem 1.5rem; }
            .page-header h1 { font-size: clamp(1.6rem, 4vw, 2.4rem); }
        }

        /* ── Phone: up to 639px ── */
        @media (max-width: 639px) {
            nav { padding: .75rem 1rem; }
            .nav-links .hide-mob { display: none; }
            .fleet-grid { grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 1rem; }
            .fleet-section { padding: 0 1rem 2.5rem; }
            .filter-section { padding: 0 1rem 1.2rem; }
            .page-header { padding: 2rem 1rem 1.2rem; }
            .page-header h1 { font-size: 1.6rem; }
            .filter-row { gap: .4rem; }
            .filter-btn { padding: .35rem .8rem; font-size: .78rem; }
            footer { padding: 1.5rem 1rem; }
            /* Booking banner stacks on mobile */
            .fleet-section > div:first-child { flex-direction: column; }
            .filter-row { flex-direction: column; align-items: stretch; gap: .6rem; }
            .filter-row > * { width: 100%; }
            .page-header { padding: 3rem 1rem 1.5rem; }
        }

        /* ── Very small phones: up to 380px ── */
        @media (max-width: 380px) {
            .page-header h1 { font-size: 1.4rem; }
            .car-name { font-size: 1rem; }
            .car-rate { font-size: 1.1rem; }
            .fleet-grid {
                grid-template-columns: 1fr !important;
            }
        }

        /* ══════════════════════════════════════════════════════════════════
           DARK THEME — applied when JS sets data-theme="dark" on the html element
           (JS IIFE reads localStorage['dn-theme'], default = dark)
           ══════════════════════════════════════════════════════════════════ */
        html[data-theme="dark"] {
            --st-surface: #0D1520;
            --st-surface-container: #162521;
            --st-outline-var: rgba(255,255,255,.10);
            --st-text-dark: #e8f0ee;
            --st-text-mid: #8baaa5;
        }
        html[data-theme="dark"] body { background: #0D1520; color: #e8f0ee; }

        /* Nav */
        html[data-theme="dark"] nav { background: #1a2332; border-bottom-color: rgba(255,255,255,.08); box-shadow: 0 1px 8px rgba(0,0,0,.28); }
        html[data-theme="dark"] .nav-logo { color: #e8f0ee; }
        html[data-theme="dark"] .nav-links a { color: #8baaa5; }
        html[data-theme="dark"] .nav-links a:hover { color: var(--teal-light); }
        html[data-theme="dark"] .btn-ghost { color: #c8d8d5; border-color: rgba(255,255,255,.20); }
        html[data-theme="dark"] .btn-ghost:hover { color: var(--teal-light); border-color: var(--teal-light); background: rgba(79,219,200,.06); }
        html[data-theme="dark"] .theme-toggle-btn { background: rgba(255,255,255,.07); border: 1px solid rgba(255,255,255,.14); color: #e8f0ee; }
        html[data-theme="dark"] .theme-toggle-btn:hover { background: rgba(255,255,255,.13); }

        /* Page header */
        html[data-theme="dark"] .page-header { background: #0D1520; }
        html[data-theme="dark"] .page-header h1 { color: #e8f0ee; }
        html[data-theme="dark"] .page-header p { color: #8baaa5; }

        /* Filter section */
        html[data-theme="dark"] .filter-row-label { color: #8baaa5; }
        html[data-theme="dark"] .filter-btn { background: #1a2332; border-color: rgba(255,255,255,.10); color: #8baaa5; }
        html[data-theme="dark"] .filter-btn:hover { background: #1e3330; border-color: var(--teal-light); color: var(--teal-light); }
        html[data-theme="dark"] .filter-btn.active { background: var(--teal); border-color: var(--teal); color: #fff; }

        /* Car cards */
        html[data-theme="dark"] .car-card { background: #1e3330; border-color: rgba(255,255,255,.09); }
        html[data-theme="dark"] .car-card:hover { border-color: var(--teal-light); box-shadow: 0 12px 32px rgba(0,0,0,.35); }
        html[data-theme="dark"] .car-name { color: #e8f0ee; }
        html[data-theme="dark"] .car-footer { border-top-color: rgba(255,255,255,.09); }
        html[data-theme="dark"] .empty-state h3 { color: #e8f0ee; }
        html[data-theme="dark"] .no-results h3 { color: #e8f0ee !important; }
        html[data-theme="dark"] .no-results p { color: #8baaa5 !important; }

        /* Toast */
        html[data-theme="dark"] .toast { background: #1e3330; color: #e8f0ee; border-color: var(--teal-light); }

        /* Footer */
        html[data-theme="dark"] footer { background: #162521; border-top-color: rgba(255,255,255,.08); }

        /* Currency selector (has inline style="background:#fff") */
        html[data-theme="dark"] #fleetCurrency { background: #1e3330 !important; color: #e8f0ee !important; border-color: rgba(79,219,200,.45) !important; }
        html[data-theme="dark"] select option { background: #1e3330; color: #e8f0ee; }

        /* Search bar wrapper (has inline style="...background:#fff...border-radius:50px...") */
        html[data-theme="dark"] div[style*="border-radius:50px"][style*="background:#fff"] { background: #1e3330 !important; border-color: rgba(255,255,255,.12) !important; box-shadow: 0 4px 16px rgba(0,0,0,.35) !important; }
        html[data-theme="dark"] div[style*="border-radius:50px"] input { color: #e8f0ee !important; }
        html[data-theme="dark"] div[style*="border-radius:50px"] input::placeholder { color: rgba(255,255,255,.28) !important; }

        /* Booking banner (has inline style="background:#fff...border-radius:12px...") */
        html[data-theme="dark"] div[style*="border-radius:12px"][style*="background:#fff"] { background: #1a2332 !important; border-color: rgba(79,219,200,.35) !important; box-shadow: 0 4px 16px rgba(0,0,0,.28) !important; }

        /* KBD hint (inline background:var(--st-surface-container)) */
        html[data-theme="dark"] kbd { background: #1e3330 !important; border-color: rgba(255,255,255,.14) !important; color: #8baaa5 !important; }

        /* Theme toggle button (light mode — default page is light) */
        .theme-toggle-btn { display: inline-flex; align-items: center; gap: .35rem; padding: .38rem .85rem; border-radius: 22px; font-family: var(--font-body); font-size: .8rem; cursor: pointer; transition: background .2s, color .2s, border-color .2s; background: rgba(0,0,0,.06); border: 1px solid rgba(0,0,0,.14); color: #334155; }
        .theme-toggle-btn:hover { background: rgba(0,0,0,.10); }
    </style>
    <script>
        /* ── Theme IIFE — runs before body paints to prevent FOUC ── */
        (function () {
            var t = localStorage.getItem('dn-theme') || 'dark';
            if (t === 'dark') document.documentElement.setAttribute('data-theme', 'dark');
        })();
    </script>
</head>
<body>
    <form id="form1" runat="server">

    <nav>
        <a href="Default.aspx" class="nav-logo">Drive<span>Now</span></a>
        <div class="nav-links">
            <a href="Default.aspx" class="hide-mob">Home</a>
            <a href="Default.aspx#about" class="hide-mob">About</a>
            <button type="button" class="theme-toggle-btn" onclick="toggleTheme()" id="themeToggleBtn" title="Switch theme">
                <span class="material-symbols-outlined" style="font-size:16px;">dark_mode</span>
                <span id="themeLabel">Dark</span>
            </button>
            <asp:PlaceHolder ID="phGuest" runat="server">
                <a href="Login.aspx?type=Customer" class="btn btn-ghost">Log In</a>
                <a href="Default.aspx" class="btn btn-teal">Sign Up</a>
            </asp:PlaceHolder>
            <asp:PlaceHolder ID="phLoggedIn" runat="server" Visible="false">
                <a href="CustomerPortal.aspx" class="btn btn-teal">My Portal</a>
            </asp:PlaceHolder>
        </div>
    </nav>

    <!-- Pre-booking context banner (shown when arriving from hero booking form) -->
    <asp:Panel ID="pnlBookingBanner" runat="server" Visible="false">
        <div style="background:#fff;border:1px solid var(--teal);border-radius:12px;padding:1rem 1.4rem;margin:5.5rem auto 0;max-width:900px;display:flex;align-items:center;gap:1rem;flex-wrap:wrap;box-shadow:0 4px 16px rgba(0,107,95,.1);">
            <div style="flex:1;">
                <div style="font-weight:700;color:var(--teal);font-size:.92rem;">Your trip details are saved &mdash; now choose a vehicle</div>
                <div style="font-size:.83rem;color:var(--st-text-mid);margin-top:.15rem;">Your pickup and drop-off info from the booking form has been carried over<asp:Label ID="lblBannerDetail" runat="server" />. Select any car below to continue.</div>
            </div>
            <a href="Default.aspx" style="font-size:.8rem;color:var(--st-text-mid);text-decoration:none;white-space:nowrap;">&#8592; Change details</a>
        </div>
    </asp:Panel>

    <div class="page-header">
        <div class="label">Our Fleet</div>
        <h1>Browse Our Elite Fleet</h1>
        <p>Choose from our handpicked selection of premium vehicles. Transparent pricing, no hidden fees.</p>
        <div style="margin-top:1rem;display:flex;align-items:center;justify-content:center;gap:.75rem;font-size:.85rem;color:var(--st-text-mid);">
            <span>Display prices in:</span>
            <select id="fleetCurrency" onchange="updateFleetPrices(this.value)"
                    style="background:#fff;border:1.5px solid var(--teal);border-radius:7px;padding:.4rem .95rem .4rem .75rem;color:var(--st-text-dark);font-size:.85rem;font-weight:600;cursor:pointer;outline:none;box-shadow:0 1px 4px rgba(0,107,95,.10);appearance:auto;">
                <option value="GBP">GBP £</option>
                <option value="EUR">EUR €</option>
                <option value="USD">USD $</option>
                <option value="DKK">DKK kr</option>
                <option value="SEK">SEK kr</option>
                <option value="NOK">NOK kr</option>
                <option value="AUD">AUD $</option>
            </select>
        </div>
        <!-- Search bar — filters cards by make, model, or registration client-side -->
        <div style="display:flex;justify-content:center;margin:1.4rem 0 0;">
            <div style="display:flex;background:#fff;border:1.5px solid var(--st-outline-var);border-radius:50px;overflow:hidden;width:100%;max-width:560px;box-shadow:0 4px 16px rgba(0,0,0,.08);">
                <span style="display:flex;align-items:center;padding:0 .8rem 0 1.2rem;color:var(--teal);font-size:.82rem;font-weight:700;letter-spacing:.04em;"><span class="material-symbols-outlined" style="font-size:18px;">search</span></span>
                <input type="text" id="fleetSearch" placeholder="Search by make, model or reg (e.g. BMW, Tesla, AB12 CDE)…"
                    style="flex:1;background:transparent;border:none;padding:.8rem .5rem;color:var(--st-text-dark);font-size:.92rem;outline:none;"
                    oninput="applyAllFilters()"
                    onkeydown="if(event.key==='Escape'){this.value='';applyAllFilters();}" />
                <button type="button" onclick="document.getElementById('fleetSearch').value='';applyAllFilters();"
                    title="Clear search"
                    style="background:transparent;border:none;color:var(--st-text-mid);padding:.8rem 1.1rem;cursor:pointer;font-size:.95rem;transition:color .2s;"
                    onmouseover="this.style.color=var(--teal)" onmouseout="this.style.color=var(--st-text-mid)">&#10005;</button>
            </div>
        </div>
        <div style="text-align:center;font-size:.78rem;color:var(--st-text-mid);margin:.5rem 0 0;">
            Press <kbd style="background:var(--st-surface-container);border:1px solid var(--st-outline-var);border-radius:4px;padding:.1rem .4rem;font-size:.78rem;">Esc</kbd> to clear
        </div>
    </div>

    <div class="filter-section">
        <div class="filter-row-label">Filter by price</div>
        <div class="filter-row" id="priceFilters">
            <button type="button" class="filter-btn active" data-filter="price" data-value="all"     onclick="applyFilter('price','all',this)">All Prices</button>
            <button type="button" class="filter-btn"        data-filter="price" data-value="budget"  onclick="applyFilter('price','budget',this)">Budget — under <span class="f-sym">£</span><span class="f-thres" data-gbp="60">60</span></button>
            <button type="button" class="filter-btn"        data-filter="price" data-value="mid"     onclick="applyFilter('price','mid',this)">Mid-Range — <span class="f-sym">£</span><span class="f-thres" data-gbp="60">60</span>-<span class="f-thres" data-gbp="100">100</span></button>
            <button type="button" class="filter-btn"        data-filter="price" data-value="premium" onclick="applyFilter('price','premium',this)">Premium — over <span class="f-sym">£</span><span class="f-thres" data-gbp="100">100</span></button>
        </div>
        <div class="filter-row-label" style="margin-top:.5rem;">Filter by seats</div>
        <div class="filter-row" id="seatFilters">
            <button type="button" class="filter-btn active" data-filter="seats" data-value="all" onclick="applyFilter('seats','all',this)">All Seats</button>
            <button type="button" class="filter-btn"        data-filter="seats" data-value="2"   onclick="applyFilter('seats','2',this)">2 Seats</button>
            <button type="button" class="filter-btn"        data-filter="seats" data-value="4"   onclick="applyFilter('seats','4',this)">4 Seats</button>
            <button type="button" class="filter-btn"        data-filter="seats" data-value="5"   onclick="applyFilter('seats','5',this)">5 Seats</button>
            <button type="button" class="filter-btn"        data-filter="seats" data-value="7"   onclick="applyFilter('seats','7',this)">7 Seats</button>
            <button type="button" class="filter-btn"        data-filter="seats" data-value="8"   onclick="applyFilter('seats','8',this)">8+ Seats</button>
        </div>
    </div>

    <div class="fleet-section">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:.8rem;padding:0 .25rem;">
            <span id="resultCount" style="font-size:.82rem;color:var(--st-text-mid);"></span>
            <span style="font-size:.78rem;color:var(--st-text-mid);">Prices shown in GBP — use the selector above to convert</span>
        </div>
        <asp:Repeater ID="rptVehicles" runat="server">
            <HeaderTemplate><div class="fleet-grid" id="fleetGrid"></HeaderTemplate>
            <ItemTemplate>
                <div class="car-card"
                     data-rate="<%# Convert.ToDecimal(Eval("DailyRate")).ToString("F2", System.Globalization.CultureInfo.InvariantCulture) %>"
                     data-seats="<%# Eval("Seats") %>"
                     data-make="<%# Eval("Make").ToString().ToLower() %>"
                     data-model="<%# Eval("Model").ToString().ToLower() %>"
                     data-reg="<%# Eval("RegistrationNo").ToString().ToLower() %>">
                    <img class="car-img" src="<%# GetCarImage(Eval("Make").ToString(), Eval("Model").ToString(), Eval("PhotoUrl")) %>" alt="<%# Eval("Make") %> <%# Eval("Model") %>" loading="lazy" />
                    <div class="car-body">
                        <div class="car-badge"><%# Eval("Make") %></div>
                        <div class="car-name"><%# Eval("Make") %> <%# Eval("Model") %></div>
                        <div class="car-reg">Reg: <%# Eval("RegistrationNo") %></div>
                        <div class="car-specs">
                            <div class="spec"><%# Eval("Seats") %> Seats</div>
                            <div class="spec">Available Now</div>
                        </div>
                        <div class="car-footer">
                            <div class="car-rate fleet-price" data-gbp="<%# Convert.ToDecimal(Eval("DailyRate")).ToString("N2") %>">
                                <span class="price-sym">£</span><span class="price-val"><%# Convert.ToDecimal(Eval("DailyRate")).ToString("N2") %></span> <span>/ day</span>
                            </div>
                            <div style="display:flex;gap:.5rem;align-items:center;">
                                <a href='<%# "VehicleDetail.aspx?vid=" + Eval("VehicleID") %>' class="btn-book" style="background:transparent;border:1.5px solid var(--st-outline-var);color:var(--st-text-mid);">Details</a>
                                <asp:PlaceHolder ID="phBookBtn" runat="server" Visible="false">
                                    <a href="BookTrip.aspx?vid=<%# Eval("VehicleID") %>" class="btn-book">Book Now</a>
                                </asp:PlaceHolder>
                                <asp:PlaceHolder ID="phLoginBtn" runat="server">
                                    <a href='<%# GetBookingLoginUrl(Eval("VehicleID")) %>' class="btn-book">Book Now</a>
                                </asp:PlaceHolder>
                            </div>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
            <FooterTemplate></div></FooterTemplate>
        </asp:Repeater>

        <asp:Label ID="lblEmpty" runat="server" Visible="false">
            <div class="empty-state">
                <h3>No vehicles available right now</h3>
                <p>Please check back soon — our fleet is updated regularly.</p>
            </div>
        </asp:Label>
        <div class="no-results" id="noResults">
            <div style="margin-bottom:.8rem;"></div>
            <h3 style="font-family:var(--font-head);font-size:1.15rem;color:var(--st-text-dark);margin-bottom:.5rem;">No vehicles match your search</h3>
            <p style="color:var(--st-text-mid);font-size:.88rem;">Try a different make, model, price range or seat count.<br/>
               Clear the search box or click "All Prices" / "All Seats" to reset filters.</p>
            <button type="button" onclick="document.getElementById('fleetSearch').value='';activePrice='all';activeSeats='all';document.querySelectorAll('.filter-btn').forEach(function(b){b.classList.remove('active');});document.querySelector('[data-value=\'all\'][data-filter=\'price\']').classList.add('active');document.querySelector('[data-value=\'all\'][data-filter=\'seats\']').classList.add('active');applyAllFilters();"
                style="margin-top:1rem;background:var(--teal);border:1px solid var(--teal);color:#fff;padding:.55rem 1.3rem;border-radius:30px;cursor:pointer;font-size:.85rem;">
                &#10003; Clear all filters
            </button>
        </div>
    </div>

    <div class="toast" id="toast"> Please <a href="Login.aspx?type=Customer" style="color:var(--teal);">sign in</a> or <a href="Default.aspx" style="color:var(--teal);">create an account</a> to book a vehicle.</div>

    <footer>
        © 2026 DriveNow — <a href="Default.aspx" style="color:var(--teal);text-decoration:none;">Back to Home</a>
    </footer>

    </form>
    <script>
        var FLEET_RATES   = { GBP:1, EUR:1.18, USD:1.27, DKK:8.72, SEK:13.5, NOK:13.9, AUD:1.98 };
        var FLEET_SYMBOLS = { GBP:'£', EUR:'€', USD:'$', DKK:'kr ', SEK:'kr ', NOK:'kr ', AUD:'A$' };

        // Active filter state — always compare against GBP base prices
        var activePrice = 'all';
        var activeSeats = 'all';

        function updateFleetPrices(code) {
            document.querySelectorAll('.fleet-price').forEach(function(el) {
                var base = parseFloat(el.getAttribute('data-gbp'));
                el.querySelector('.price-sym').innerHTML = FLEET_SYMBOLS[code];
                el.querySelector('.price-val').textContent = (base * FLEET_RATES[code]).toFixed(2);
            });
            document.querySelectorAll('.f-sym').forEach(function(el) {
                el.innerHTML = FLEET_SYMBOLS[code];
            });
            document.querySelectorAll('.f-thres').forEach(function(el) {
                var base = parseFloat(el.getAttribute('data-gbp'));
                el.textContent = Math.round(base * FLEET_RATES[code]);
            });
        }

        function applyFilter(group, value, btn) {
            document.querySelectorAll('[data-filter="' + group + '"]').forEach(function(b) {
                b.classList.remove('active');
            });
            btn.classList.add('active');
            if (group === 'price') activePrice = value;
            else                   activeSeats = value;
            applyAllFilters();
        }

        // Single unified filter — search + price + seats all applied together
        function applyAllFilters() {
            var q     = (document.getElementById('fleetSearch').value || '').trim().toLowerCase();
            var visible = 0;
            document.querySelectorAll('.car-card').forEach(function(card) {
                var rate  = parseFloat(card.dataset.rate);
                var seats = parseInt(card.dataset.seats, 10);
                var make  = (card.dataset.make  || '');
                var model = (card.dataset.model || '');
                var reg   = (card.dataset.reg   || '');
                var name  = ((card.querySelector('.car-name')  || {}).textContent || '').toLowerCase();

                // Search: make, model, full name, or registration plate
                var searchOk = !q
                    || name.indexOf(q)  !== -1
                    || make.indexOf(q)  !== -1
                    || model.indexOf(q) !== -1
                    || reg.indexOf(q)   !== -1;

                var priceOk = activePrice === 'all'
                    || (activePrice === 'budget'  && rate < 60)
                    || (activePrice === 'mid'     && rate >= 60 && rate <= 100)
                    || (activePrice === 'premium' && rate > 100);

                var seatsOk = activeSeats === 'all'
                    || (activeSeats === '2' && seats <= 2)
                    || (activeSeats === '5' && seats >= 4 && seats <= 5)
                    || (activeSeats === '7' && seats === 7)
                    || (activeSeats === '8' && seats >= 8);

                var show = searchOk && priceOk && seatsOk;
                card.style.display = show ? '' : 'none';
                if (show) visible++;
            });
            var noEl = document.getElementById('noResults');
            if (noEl) noEl.style.display = visible === 0 ? 'block' : 'none';

            // Update result count label
            var countEl = document.getElementById('resultCount');
            if (countEl) countEl.textContent = visible + ' vehicle' + (visible !== 1 ? 's' : '') + ' found';
        }

        // Backward-compat aliases
        function runFilter()        { applyAllFilters(); }
        function filterBySearch()   { applyAllFilters(); }

        function showToast() {
            var t = document.getElementById('toast');
            t.classList.add('show');
            setTimeout(function() { t.classList.remove('show'); }, 4000);
        }

        // ── Theme toggle ────────────────────────────────────────────────
        function syncThemeBtn() {
            var dark = document.documentElement.getAttribute('data-theme') === 'dark';
            var btn   = document.getElementById('themeToggleBtn');
            var label = document.getElementById('themeLabel');
            var icon  = btn ? btn.querySelector('.material-symbols-outlined') : null;
            if (label) label.textContent = dark ? 'Light' : 'Dark';
            if (icon)  icon.textContent  = dark ? 'light_mode' : 'dark_mode';
        }
        function toggleTheme() {
            var dark = document.documentElement.getAttribute('data-theme') === 'dark';
            if (dark) {
                document.documentElement.removeAttribute('data-theme');
                localStorage.setItem('dn-theme', 'light');
            } else {
                document.documentElement.setAttribute('data-theme', 'dark');
                localStorage.setItem('dn-theme', 'dark');
            }
            syncThemeBtn();
        }

        // On load: init count + apply any ?search= query string
        window.addEventListener('DOMContentLoaded', function() {
            var params = new URLSearchParams(window.location.search);
            var s = params.get('search') || '';
            if (s) {
                var inp = document.getElementById('fleetSearch');
                if (inp) inp.value = s;
            }
            applyAllFilters();
            syncThemeBtn(); // sync button label to current theme on load
        });
    </script>
</body>
</html>

