<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="DriveNow.Default" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>DriveNow — Your Journey, Your DriveNow</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;0,9..40,600;1,9..40,400&display=swap" rel="stylesheet" />
    <style>
        /* =============================================
           DRIVENOW BRAND TOKENS  (Style Guide v1.0)
           ============================================= */
        :root {
            --navy:        #1A2332;   /* dark navy — primary dark bg, headings     */
            --navy-deep:   #0D1520;   /* deeper navy — hero bg, darkest surfaces   */
            --teal:        #0D9488;   /* teal primary — buttons, accents           */
            --teal-light:  #14B8A6;   /* teal light — hover, gradients             */
            --teal-pale:   #F0FDFA;   /* teal pale — badges, highlights            */
            --white:       #FFFFFF;
            --off-white:   #F8FAFB;
            --grey:        #94A3B8;   /* muted text, labels                        */
            --text-dark:   #334155;
            --card-bg:     rgba(26, 35, 50, 0.6);   /* navy at 60%           */
            --card-border: rgba(255,255,255,0.07);
            --font-head:   'Outfit', Arial, sans-serif;
            --font-body:   'DM Sans', Arial, sans-serif;
        }

        /* ====== RESET ====== */
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html { scroll-behavior: smooth; }
        body {
            font-family: var(--font-body);
            background: var(--navy-deep);
            color: var(--white);
            overflow-x: hidden;
            line-height: 1.6;
        }

        /* ====== KEYFRAMES ====== */
        @keyframes slideUp   { from { opacity:0; transform:translateY(28px); } to { opacity:1; transform:none; } }
        @keyframes fadeIn    { from { opacity:0; } to { opacity:1; } }
        @keyframes floatY    { 0%,100%{transform:translateX(-50%) translateY(0);} 50%{transform:translateX(-50%) translateY(-12px);} }
        @keyframes modalIn   { from{opacity:0;transform:translateY(-14px) scale(0.97);}to{opacity:1;transform:none;} }
        @keyframes spin      { to{transform:rotate(360deg);} }
        @keyframes marquee   { 0%{transform:translateX(0);} 100%{transform:translateX(-50%);} }
        @keyframes glowPulse { 0%,100%{opacity:0.3;transform:translateX(-50%) scale(1);} 50%{opacity:0.55;transform:translateX(-50%) scale(1.06);} }

        /* ====== NAVBAR ====== */
        .navbar {
            position: fixed; inset: 0 0 auto 0; z-index: 900;
            padding: 1rem 3rem;
            display: flex; align-items: center; justify-content: space-between;
            backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px);
            background: rgba(13,21,32,0.65);
            border-bottom: 1px solid rgba(255,255,255,0.04);
            transition: background .3s, box-shadow .3s;
        }
        .navbar.scrolled {
            background: rgba(13,21,32,0.97);
            box-shadow: 0 2px 28px rgba(0,0,0,.5);
        }
        /* DN monogram logo */
        .nav-logo {
            display: flex; align-items: center; gap: .55rem;
            text-decoration: none;
        }
        .nav-logo-mark {
            width: 34px; height: 34px;
            display: flex; align-items: center; justify-content: center;
        }
        .nav-logo-mark svg { width:100%; height:100%; }
        .nav-wordmark {
            font-family: var(--font-head);
            font-weight: 700; font-size: 1.2rem;
            letter-spacing: -.02em; color: var(--white);
        }
        .nav-wordmark span { color: var(--teal); }

        .nav-links {
            display: flex; align-items: center; gap: 2rem;
            list-style: none;
        }
        .nav-links a {
            font-family: var(--font-body); font-size: .9rem; font-weight: 500;
            color: var(--grey); text-decoration: none;
            padding-bottom: 2px; position: relative;
            transition: color .2s;
        }
        .nav-links a:hover { color: var(--white); }
        .nav-links a.active { color: var(--white); }
        .nav-links a.active::after {
            content: ''; position: absolute;
            bottom: -2px; left:0; right:0; height:2px;
            background: var(--teal); border-radius:2px;
        }
        .nav-actions { display:flex; align-items:center; gap:.6rem; }

        /* ====== BUTTONS ====== */
        .btn {
            display: inline-flex; align-items:center; justify-content:center;
            padding: .5rem 1.3rem; border-radius: 100px;
            font-family: var(--font-body); font-weight:500; font-size:.88rem;
            cursor:pointer; text-decoration:none; border:none; outline:none;
            white-space:nowrap; transition: all .2s ease;
        }
        .btn-ghost-w  { background:transparent; color:var(--white); border:1.5px solid rgba(255,255,255,.25); }
        .btn-ghost-w:hover { border-color:var(--white); background:rgba(255,255,255,.06); }
        .btn-solid-w  { background:var(--white); color:#000; }
        .btn-solid-w:hover { background:#dde3e9; }
        .btn-teal     { background:var(--teal); color:var(--white); }
        .btn-teal:hover { background:var(--teal-light); box-shadow:0 4px 22px rgba(13,148,136,.42); }
        .btn-teal-outline { background:transparent; color:var(--teal); border:1.5px solid var(--teal); }
        .btn-teal-outline:hover { background:rgba(13,148,136,.1); }
        .btn-lg { padding:.82rem 2.2rem; font-size:.96rem; border-radius:100px; }

        /* ====== HAMBURGER ====== */
        .hamburger {
            display:none; background:none; border:1.5px solid var(--card-border);
            color:var(--white); font-size:1.2rem; padding:.3rem .5rem;
            border-radius:8px; cursor:pointer;
        }

        /* ====== HERO ====== */
        .hero {
            height: 100vh; min-height: 640px;
            position: relative; overflow: hidden;
            display: flex; flex-direction: column;
            align-items: center; text-align: center;
            padding: 140px 2rem 0;
            background: var(--navy-deep);
        }

        /* Slides sit behind content */
        .hero-slides { position:absolute; inset:0; z-index:0; }
        .hero-slide  {
            position:absolute; inset:0;
            opacity:0; transition:opacity .9s ease;
            display:flex; align-items:flex-end; justify-content:center;
        }
        .hero-slide.active { opacity:1; }

        /* Stage spotlight — white radial like Stratos Drive */
        .slide-spot {
            position:absolute; bottom:-60px; left:50%;
            transform:translateX(-50%);
            width:860px; height:560px;
            background: radial-gradient(ellipse at 50% 65%,
                rgba(255,255,255,.065) 0%,
                rgba(255,255,255,.025) 28%,
                transparent 68%);
            pointer-events:none;
        }
        /* Brand teal glow under car */
        .slide-teal {
            position:absolute; bottom:0; left:50%;
            transform:translateX(-50%);
            width:580px; height:240px;
            background: radial-gradient(ellipse at center,
                rgba(13,148,136,.18) 0%,
                transparent 70%);
            pointer-events:none;
            animation: glowPulse 5s ease-in-out infinite;
        }
        /* Car image */
        .slide-car {
            position:absolute; bottom:0; left:50%;
            transform:translateX(-50%);
            width:76%; max-width:940px;
            object-fit:contain;
            -webkit-mask-image: linear-gradient(to bottom, rgba(0,0,0,1) 50%, transparent 94%);
            mask-image: linear-gradient(to bottom, rgba(0,0,0,1) 50%, transparent 94%);
        }

        /* Hero text content — floats above slides */
        .hero-content {
            position:relative; z-index:10;
            animation: slideUp .75s ease both;
        }
        .hero-title {
            font-family: var(--font-head);
            font-size: clamp(2.4rem, 5.5vw, 5rem);
            font-weight: 800;
            letter-spacing: -.04em;
            line-height: 1.06;
            color: var(--white);
            margin-bottom: 1rem;
        }
        .hero-sub {
            font-family: var(--font-body); font-size: clamp(.9rem, 1.4vw, 1.05rem);
            color: var(--grey); line-height:1.72;
            max-width:420px; margin:0 auto 1.9rem;
        }

        /* Carousel controls */
        .c-arrow {
            position:absolute; top:50%; transform:translateY(-50%);
            width:2.8rem; height:2.8rem; border-radius:50%;
            background:rgba(255,255,255,.07);
            border:1px solid rgba(255,255,255,.12);
            color:var(--white); font-size:.95rem;
            cursor:pointer; z-index:20;
            display:flex; align-items:center; justify-content:center;
            transition:background .2s;
        }
        .c-arrow:hover { background:rgba(255,255,255,.15); }
        .c-prev { left:2rem; }
        .c-next { right:2rem; }
        .c-dots {
            position:absolute; bottom:2.2rem; left:50%; transform:translateX(-50%);
            display:flex; gap:.45rem; z-index:20;
        }
        .dot {
            width:2rem; height:3px; border-radius:2px;
            background:rgba(255,255,255,.22); cursor:pointer;
            transition:background .3s;
        }
        .dot.active { background:var(--white); }

        /* ====== BRAND STRIP ====== */
        .brand-strip {
            padding:2rem 0;
            border-top:1px solid rgba(255,255,255,.04);
            border-bottom:1px solid rgba(255,255,255,.04);
            overflow:hidden; position:relative;
            background: rgba(255,255,255,.015);
        }
        .brand-strip::before, .brand-strip::after {
            content:''; position:absolute; top:0; bottom:0; width:100px; z-index:2; pointer-events:none;
        }
        .brand-strip::before { left:0;  background:linear-gradient(to right, var(--navy-deep), transparent); }
        .brand-strip::after  { right:0; background:linear-gradient(to left,  var(--navy-deep), transparent); }
        .brand-track {
            display:flex; align-items:center; gap:3.5rem;
            animation:marquee 22s linear infinite;
            width:max-content;
        }
        .brand-name {
            font-family: var(--font-head);
            font-size:.82rem; font-weight:600;
            letter-spacing:.14em; text-transform:uppercase;
            color:rgba(255,255,255,.2); white-space:nowrap;
        }

        /* ====== SECTION COMMON ====== */
        .section { padding:6.5rem 4rem; }
        .section-inner { max-width:1180px; margin:0 auto; }

        .sec-label {
            display:inline-flex; align-items:center; gap:.4rem;
            font-family:var(--font-body); font-size:.72rem; font-weight:600;
            letter-spacing:.14em; text-transform:uppercase;
            color:var(--grey); margin-bottom:.7rem;
        }
        .sec-label::before { content:'·'; font-size:1.1rem; color:var(--teal-light); }

        .sec-title {
            font-family:var(--font-head);
            font-size:clamp(1.9rem, 3.5vw, 2.8rem);
            font-weight:800; letter-spacing:-.03em; line-height:1.1;
        }

        /* ====== SCROLL REVEAL ====== */
        .reveal {
            opacity:0; transform:translateY(28px);
            transition:opacity .55s ease, transform .55s ease;
        }
        .reveal.visible { opacity:1; transform:none; }

        /* ====== ABOUT SECTION ====== */
        .about-grid {
            display:grid; grid-template-columns:1fr 1fr;
            gap:5rem; align-items:center; margin-top:3.5rem;
        }
        .about-img {
            width:100%; aspect-ratio:4/3;
            object-fit:cover; border-radius:16px;
            filter:brightness(.88);
            border:1px solid var(--card-border);
        }
        .about-text h3 {
            font-family:var(--font-head); font-size:1.5rem; font-weight:800;
            letter-spacing:-.025em; line-height:1.2; margin-bottom:1rem;
        }
        .about-text p {
            font-size:.94rem; color:var(--grey); line-height:1.75;
            margin-bottom:.8rem;
        }

        /* ====== WHY CHOOSE US — ACCORDION ====== */
        .hiw-bg {
            background:rgba(26,35,50,.35);
            border-top:1px solid var(--card-border);
            border-bottom:1px solid var(--card-border);
        }
        .why-grid {
            display:grid; grid-template-columns:1fr 1fr;
            gap:5rem; align-items:start; margin-top:3.5rem;
        }
        .why-left .sec-title { max-width:340px; }
        .why-left p { font-size:.94rem; color:var(--grey); line-height:1.72; margin:1rem 0 2rem; }

        .accordion { display:flex; flex-direction:column; gap:.55rem; }
        .acc-item {
            background:rgba(26,35,50,.5);
            border:1px solid var(--card-border);
            border-radius:12px; overflow:hidden;
            transition:border-color .2s;
        }
        .acc-item.open { border-color:rgba(13,148,136,.32); }
        .acc-header {
            display:flex; align-items:center; gap:.9rem;
            padding:.95rem 1.2rem; cursor:pointer;
        }
        .acc-num {
            min-width:1.7rem; height:1.7rem; border-radius:50%;
            border:1.5px solid rgba(255,255,255,.14);
            display:flex; align-items:center; justify-content:center;
            font-family:var(--font-head); font-size:.75rem; font-weight:700;
            color:var(--grey); transition:all .2s;
        }
        .acc-item.open .acc-num {
            border-color:var(--teal); color:var(--teal);
            background:rgba(13,148,136,.1);
        }
        .acc-title { font-family:var(--font-head); font-size:.95rem; font-weight:700; flex:1; }
        .acc-chevron { color:var(--grey); font-size:.7rem; transition:transform .25s; }
        .acc-item.open .acc-chevron { transform:rotate(180deg); }
        .acc-body { max-height:0; overflow:hidden; transition:max-height .3s ease; }
        .acc-item.open .acc-body { max-height:110px; }
        .acc-body-inner { padding:0 1.2rem 1rem; font-size:.87rem; color:var(--grey); line-height:1.65; }

        /* ====== FLEET ====== */
        .fleet-header {
            display:flex; align-items:flex-end; justify-content:space-between;
            margin-bottom:2.2rem;
        }
        .fleet-nav { display:flex; gap:.45rem; }
        .fleet-nav-btn {
            width:2.3rem; height:2.3rem; border-radius:50%;
            background:rgba(26,35,50,.6); border:1px solid var(--card-border);
            color:var(--grey); cursor:pointer; font-size:.82rem;
            display:flex; align-items:center; justify-content:center;
            transition:all .2s;
        }
        .fleet-nav-btn:hover { background:rgba(255,255,255,.08); color:var(--white); }

        .fleet-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:1.2rem; }
        .fleet-card {
            background:rgba(26,35,50,.55);
            border:1px solid var(--card-border);
            border-radius:16px; overflow:hidden;
            transition:border-color .25s, transform .25s;
        }
        .fleet-card:hover { border-color:rgba(13,148,136,.3); transform:translateY(-4px); }
        /* First card gets white highlight border */
        .fleet-card:first-child { border-color:rgba(255,255,255,.18); }
        .fleet-img { width:100%; aspect-ratio:16/10; object-fit:cover; display:block; }
        .fleet-info { padding:1.2rem; }
        .fleet-name { font-family:var(--font-head); font-size:.97rem; font-weight:700; margin-bottom:.75rem; }
        .fleet-specs { display:flex; gap:.9rem; margin-bottom:1rem; flex-wrap:wrap; }
        .spec {
            display:flex; align-items:center; gap:.28rem;
            font-size:.75rem; color:var(--grey);
        }
        .spec svg { opacity:.55; }
        /* First card gets white "View Details" button */
        .fleet-card:first-child .btn-fleet { background:var(--white); color:#000; border-color:var(--white); }
        .fleet-card:first-child .btn-fleet:hover { background:#dde3e9; }
        .btn-fleet {
            width:100%; padding:.62rem;
            border-radius:8px; border:1px solid var(--card-border);
            background:transparent; color:var(--grey);
            font-family:var(--font-body); font-size:.85rem; font-weight:500;
            cursor:pointer; transition:all .2s; text-align:center;
        }
        .btn-fleet:hover { background:rgba(255,255,255,.06); color:var(--white); }

        /* ====== HOW IT WORKS ====== */
        .steps-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:1.2rem; margin-top:3rem; }
        .step-card {
            background:rgba(26,35,50,.5); border:1px solid var(--card-border);
            border-radius:16px; padding:1.8rem; position:relative; overflow:hidden;
        }
        .step-bg-num {
            position:absolute; top:1rem; right:1.2rem;
            font-family:var(--font-head); font-size:3.8rem; font-weight:900;
            color:rgba(255,255,255,.035); line-height:1; letter-spacing:-.04em;
        }
        .step-icon {
            width:2.8rem; height:2.8rem; border-radius:10px;
            background:rgba(13,148,136,.12); border:1px solid rgba(13,148,136,.2);
            display:flex; align-items:center; justify-content:center;
            font-size:1.2rem; margin-bottom:1.1rem;
        }
        .step-title { font-family:var(--font-head); font-size:1.05rem; font-weight:700; margin-bottom:.45rem; }
        .step-desc  { font-size:.87rem; color:var(--grey); line-height:1.65; }

        /* ====== CTA ====== */
        .cta-section {
            padding:7rem 4rem; text-align:center; position:relative; overflow:hidden;
            background: linear-gradient(135deg, #0b3d3a 0%, #0d2f2c 45%, #0D1520 100%);
        }
        .cta-section::before {
            content:''; position:absolute; top:50%; left:50%;
            transform:translate(-50%,-50%);
            width:600px; height:380px;
            background:radial-gradient(ellipse, rgba(13,148,136,.22) 0%, transparent 70%);
            pointer-events:none;
        }
        .cta-title {
            font-family:var(--font-head);
            font-size:clamp(2rem,4vw,3.2rem); font-weight:800;
            letter-spacing:-.03em; margin-bottom:.85rem;
            position:relative; z-index:1;
        }
        .cta-sub { font-size:1rem; color:var(--grey); margin-bottom:2.2rem; position:relative; z-index:1; }
        .cta-actions { display:flex; justify-content:center; gap:1rem; flex-wrap:wrap; position:relative; z-index:1; }

        /* ====== FOOTER ====== */
        footer {
            padding:2.2rem 4rem;
            background:rgba(0,0,0,.35);
            border-top:1px solid var(--card-border);
            display:flex; align-items:center; justify-content:space-between;
            flex-wrap:wrap; gap:1rem;
        }
        .footer-logo {
            display:flex; align-items:center; gap:.5rem;
        }
        .footer-logo-text {
            font-family:var(--font-head); font-weight:700; font-size:1.1rem;
            letter-spacing:-.02em; color:var(--white);
        }
        .footer-logo-text span { color:var(--teal); }
        .footer-info { font-size:.8rem; color:var(--grey); text-align:center; line-height:1.6; }
        .footer-link { color:var(--teal); text-decoration:none; font-size:.85rem; font-weight:500; transition:color .2s; }
        .footer-link:hover { color:var(--teal-light); }

        /* ====== MODALS ====== */
        .overlay {
            position:fixed; inset:0; z-index:9999;
            background:rgba(0,0,0,.78);
            backdrop-filter:blur(10px); -webkit-backdrop-filter:blur(10px);
            display:flex; align-items:center; justify-content:center;
            opacity:0; pointer-events:none; transition:opacity .25s ease;
        }
        .overlay.open { opacity:1; pointer-events:all; }
        .modal {
            background:#111b27;
            border:1px solid rgba(255,255,255,.09);
            border-radius:20px; padding:2.4rem;
            width:100%; max-width:400px; position:relative;
        }
        .overlay.open .modal { animation:modalIn .28s ease both; }
        .modal-x {
            position:absolute; top:1.1rem; right:1.1rem;
            background:rgba(255,255,255,.04); border:1px solid var(--card-border);
            color:var(--grey); width:2rem; height:2rem; border-radius:8px;
            cursor:pointer; font-size:1.1rem;
            display:flex; align-items:center; justify-content:center; transition:all .2s;
        }
        .modal-x:hover { color:var(--white); background:rgba(255,255,255,.08); }
        .modal-logo {
            font-family:var(--font-head); font-weight:700; font-size:1.3rem;
            margin-bottom:.4rem; color:var(--white);
        }
        .modal-logo span { color:var(--teal); }
        .modal-h { font-family:var(--font-head); font-size:1.18rem; font-weight:700; margin-bottom:.18rem; }
        .modal-p { font-size:.86rem; color:var(--grey); margin-bottom:1.65rem; }
        .field { margin-bottom:1.05rem; }
        .field label { display:block; font-size:.8rem; font-weight:500; color:rgba(255,255,255,.65); margin-bottom:.38rem; }
        .field input {
            width:100%; padding:.68rem .9rem;
            background:rgba(255,255,255,.05);
            border:1px solid rgba(255,255,255,.1); border-radius:8px;
            color:var(--white); font-family:var(--font-body); font-size:.91rem; outline:none;
            transition:border-color .2s, box-shadow .2s;
        }
        .field input::placeholder { color:rgba(255,255,255,.2); }
        .field input:focus { border-color:var(--teal); box-shadow:0 0 0 3px rgba(13,148,136,.15); }
        .form-btn {
            width:100%; padding:.8rem; background:var(--teal); color:var(--white);
            border:none; border-radius:8px;
            font-family:var(--font-body); font-size:.94rem; font-weight:600;
            cursor:pointer; margin-top:.3rem; transition:all .2s;
        }
        .form-btn:hover { background:var(--teal-light); box-shadow:0 4px 20px rgba(13,148,136,.4); }
        .modal-switch { text-align:center; font-size:.83rem; color:var(--grey); margin-top:1.3rem; }
        .modal-switch a { color:var(--teal); cursor:pointer; font-weight:500; }
        .modal-switch a:hover { color:var(--teal-light); }

        /* ====== MOBILE NAV DRAWER ====== */
        .mobile-nav {
            display:none; flex-direction:column;
            position:fixed; top:62px; left:0; right:0;
            background:rgba(13,21,32,.98);
            border-bottom:1px solid var(--card-border);
            z-index:800; padding:1rem 1.5rem;
        }
        .mobile-nav.open { display:flex; }
        .mobile-nav a {
            color:var(--grey); text-decoration:none; font-size:.93rem; font-weight:500;
            padding:.6rem 0; border-bottom:1px solid var(--card-border); transition:color .2s;
        }
        .mobile-nav a:last-child { border:none; }
        .mobile-nav a:hover { color:var(--white); }

        /* ====== STATS STRIP ====== */
        .stats-strip {
            padding:3.5rem 4rem;
            background:rgba(26,35,50,.28);
            border-top:1px solid var(--card-border);
            border-bottom:1px solid var(--card-border);
        }
        .stats-grid {
            display:grid; grid-template-columns:repeat(4,1fr);
            gap:2rem; max-width:860px; margin:0 auto; text-align:center;
        }
        .stat-num {
            font-family:var(--font-head); font-size:2.5rem; font-weight:700;
            color:var(--teal); letter-spacing:-.025em; line-height:1; margin-bottom:.45rem;
        }
        .stat-lbl { font-size:.84rem; color:var(--grey); font-weight:500; letter-spacing:.07em; text-transform:uppercase; }

        /* ====== RESPONSIVE ====== */
        @media (max-width:1060px) {
            .fleet-grid { grid-template-columns:repeat(2,1fr); }
            .steps-grid { grid-template-columns:repeat(2,1fr); }
            .why-grid   { gap:3rem; }
        }
        @media (max-width:780px) {
            .navbar { padding:.9rem 1.5rem; }
            .nav-links { display:none; }
            .hamburger { display:block; }
            .hero { padding-top:85px; }
            .hero-title { font-size:2.2rem; }
            .hero-sub   { font-size:.9rem; }
            .slide-car  { width:100%; }
            .about-grid { grid-template-columns:1fr; gap:2rem; }
            .why-grid   { grid-template-columns:1fr; gap:2rem; }
            .fleet-grid { grid-template-columns:1fr; }
            .steps-grid { grid-template-columns:1fr; }
            .stats-grid { grid-template-columns:repeat(2,1fr); }
            .section    { padding:4rem 1.5rem; }
            .stats-strip{ padding:3rem 1.5rem; }
            .cta-section{ padding:4rem 1.5rem; }
            footer      { flex-direction:column; text-align:center; padding:2rem 1.5rem; }
            .fleet-header{ flex-direction:column; align-items:flex-start; gap:1rem; }
            .c-arrow    { display:none; }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <!-- ==================== NAVBAR ==================== -->
    <nav class="navbar" id="navbar">
        <!-- DN monogram + wordmark -->
        <a href="#" class="nav-logo">
            <div class="nav-logo-mark">
                <svg viewBox="0 0 54 54" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <!-- D shape -->
                    <path d="M4 8h16c8.284 0 15 6.716 15 15v8c0 8.284-6.716 15-15 15H4V8z" fill="#1A2332"/>
                    <path d="M10 14h8c5.523 0 10 4.477 10 10v6c0 5.523-4.477 10-10 10h-8V14z" fill="#0D1520"/>
                    <!-- N shape with teal gradient -->
                    <defs>
                        <linearGradient id="ng" x1="31" y1="8" x2="50" y2="46" gradientUnits="CustomerspaceOnUse">
                            <stop offset="0%" stop-color="#1A2332"/>
                            <stop offset="100%" stop-color="#0D9488"/>
                        </linearGradient>
                    </defs>
                    <path d="M31 8h6l13 22V8h4v38h-6L35 24v22h-4V8z" fill="url(#ng)"/>
                </svg>
            </div>
            <span class="nav-wordmark">Drive<span>Now</span></span>
        </a>

        <ul class="nav-links">
            <li><a href="#home" class="active">Home</a></li>
            <li><a href="#about">About Us</a></li>
            <li><a href="#fleet">Our Fleet</a></li>
            <li><a href="#how-it-works">How It Works</a></li>
            <li><a href="#contact">Contact</a></li>
        </ul>

        <div class="nav-actions">
            <button type="button" class="btn btn-ghost-w" onclick="openModal('m-login')">Log In</button>
            <button type="button" class="btn btn-solid-w" onclick="openModal('m-register')">Sign Up</button>
        </div>
        <button type="button" class="hamburger" onclick="toggleNav()">&#9776;</button>
    </nav>

    <!-- Mobile drawer -->
    <div class="mobile-nav" id="mobile-nav">
        <a href="#home" onclick="toggleNav()">Home</a>
        <a href="#about" onclick="toggleNav()">About Us</a>
        <a href="#fleet" onclick="toggleNav()">Our Fleet</a>
        <a href="#how-it-works" onclick="toggleNav()">How It Works</a>
        <a href="#contact" onclick="toggleNav()">Contact</a>
    </div>

    <!-- ==================== HERO ==================== -->
    <section class="hero" id="home">
        <!-- Carousel slides -->
        <div class="hero-slides">
            <div class="hero-slide active">
                <div class="slide-spot"></div>
                <div class="slide-teal"></div>
                <img class="slide-car" src="https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=1400&q=80" alt="Luxury DriveNow vehicle" />
            </div>
            <div class="hero-slide">
                <div class="slide-spot"></div>
                <div class="slide-teal"></div>
                <img class="slide-car" src="https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1400&q=80" alt="Sports car" />
            </div>
            <div class="hero-slide">
                <div class="slide-spot"></div>
                <div class="slide-teal"></div>
                <img class="slide-car" src="https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=1400&q=80" alt="Executive sedan" />
            </div>
        </div>

        <!-- Headline content -->
        <div class="hero-content">
            <h1 class="hero-title">Your Journey,<br />Your DriveNow</h1>
            <p class="hero-sub">Experience elegance, performance, and style with our handpicked premium vehicle fleet.</p>
            <button type="button" class="btn btn-ghost-w btn-lg" onclick="openModal('m-register')">Pick Your Perfect Drive</button>
        </div>

        <!-- Carousel controls -->
        <button type="button" class="c-arrow c-prev" onclick="prevSlide()">&#8249;</button>
        <button type="button" class="c-arrow c-next" onclick="nextSlide()">&#8250;</button>
        <div class="c-dots">
            <div class="dot active" onclick="goSlide(0)"></div>
            <div class="dot" onclick="goSlide(1)"></div>
            <div class="dot" onclick="goSlide(2)"></div>
        </div>
    </section>

    <!-- ==================== BRAND STRIP ==================== -->
    <div class="brand-strip">
        <div class="brand-track">
            <span class="brand-name">BMW</span>
            <span class="brand-name">Mercedes&#8209;Benz</span>
            <span class="brand-name">Audi</span>
            <span class="brand-name">Volvo</span>
            <span class="brand-name">Tesla</span>
            <span class="brand-name">Lexus</span>
            <span class="brand-name">Porsche</span>
            <span class="brand-name">Land Rover</span>
            <!-- duplicate for seamless loop -->
            <span class="brand-name">BMW</span>
            <span class="brand-name">Mercedes&#8209;Benz</span>
            <span class="brand-name">Audi</span>
            <span class="brand-name">Volvo</span>
            <span class="brand-name">Tesla</span>
            <span class="brand-name">Lexus</span>
            <span class="brand-name">Porsche</span>
            <span class="brand-name">Land Rover</span>
        </div>
    </div>

    <!-- ==================== STATS ==================== -->
    <div class="stats-strip">
        <div class="stats-grid">
            <div class="reveal">
                <div class="stat-num" data-target="500" data-suffix="+">0</div>
                <div class="stat-lbl">Happy Customers</div>
            </div>
            <div class="reveal">
                <div class="stat-num" data-target="50" data-suffix="+">0</div>
                <div class="stat-lbl">Premium Vehicles</div>
            </div>
            <div class="reveal">
                <div class="stat-num" data-target="5" data-suffix="">0</div>
                <div class="stat-lbl">Service Types</div>
            </div>
            <div class="reveal">
                <div class="stat-num" data-target="24" data-suffix="/7">0</div>
                <div class="stat-lbl">Customer Support</div>
            </div>
        </div>
    </div>

    <!-- ==================== ABOUT ==================== -->
    <section class="section" id="about">
        <div class="section-inner">
            <div class="reveal">
                <span class="sec-label">About Us</span>
                <h2 class="sec-title">Elite Car Rentals with Refined<br />Service &amp; Unmatched Class</h2>
            </div>
            <div class="about-grid">
                <div class="reveal">
                    <img class="about-img"
                        src="https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=900&q=80"
                        alt="DriveNow fleet" />
                </div>
                <div class="reveal">
                    <h3>Delivering Sophistication on Every Ride</h3>
                    <p>At DriveNow, we offer more than just vehicles &mdash; we deliver sophistication on wheels. Every hire is a blend of premium quality, precision performance, and white-glove service.</p>
                    <p>We provide more than transport &mdash; we curate refined driving experiences. From first contact to final mile, luxury meets convenience at every turn.</p>
                    <button type="button" class="btn btn-teal-outline btn-lg" style="margin-top:1.2rem;" onclick="openModal('m-register')">Get Started</button>
                </div>
            </div>
        </div>
    </section>

    <!-- ==================== WHY CHOOSE US ==================== -->
    <section class="section hiw-bg" id="why">
        <div class="section-inner">
            <div class="reveal"><span class="sec-label">Why Choose Us</span></div>
            <div class="why-grid">
                <div class="why-left reveal">
                    <h2 class="sec-title">Redefining Luxury Mobility with Distinction</h2>
                    <p>Choosing DriveNow means unlocking unmatched luxury, trusted service, and a flawless driving experience &mdash; down to the finest detail.</p>
                    <button type="button" class="btn btn-teal btn-lg" onclick="openModal('m-register')">Learn More</button>
                </div>
                <div class="why-right reveal">
                    <div class="accordion">
                        <div class="acc-item open">
                            <div class="acc-header" onclick="toggleAcc(this)">
                                <div class="acc-num">1</div>
                                <div class="acc-title">Diverse Fleet of Prestige Vehicles</div>
                                <div class="acc-chevron">&#9650;</div>
                            </div>
                            <div class="acc-body">
                                <div class="acc-body-inner">Our fleet includes an array of high-performance, comfortable, and elegant cars tailored to every preference and occasion.</div>
                            </div>
                        </div>
                        <div class="acc-item">
                            <div class="acc-header" onclick="toggleAcc(this)">
                                <div class="acc-num">2</div>
                                <div class="acc-title">Concierge-Level Service</div>
                                <div class="acc-chevron">&#9650;</div>
                            </div>
                            <div class="acc-body">
                                <div class="acc-body-inner">Enjoy a seamless rental experience, from an easy booking process to prompt delivery at your preferred location.</div>
                            </div>
                        </div>
                        <div class="acc-item">
                            <div class="acc-header" onclick="toggleAcc(this)">
                                <div class="acc-num">3</div>
                                <div class="acc-title">Flexible Lifestyle Plans</div>
                                <div class="acc-chevron">&#9650;</div>
                            </div>
                            <div class="acc-body">
                                <div class="acc-body-inner">We offer daily, weekly, and monthly rental options with convenient payment solutions to fit any budget or lifestyle.</div>
                            </div>
                        </div>
                        <div class="acc-item">
                            <div class="acc-header" onclick="toggleAcc(this)">
                                <div class="acc-num">4</div>
                                <div class="acc-title">Total Peace of Mind</div>
                                <div class="acc-chevron">&#9650;</div>
                            </div>
                            <div class="acc-body">
                                <div class="acc-body-inner">We prioritise top-tier service and exceptional vehicle quality, ensuring a smooth and luxurious driving experience every time.</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ==================== OUR FLEET ==================== -->
    <section class="section" id="fleet">
        <div class="section-inner">
            <div class="fleet-header reveal">
                <div>
                    <span class="sec-label">Our Fleet</span>
                    <h2 class="sec-title">Browse Our Elite Fleet</h2>
                    <p style="color:var(--grey);font-size:.9rem;margin-top:.5rem;">From high-performance sports cars to refined executive sedans.</p>
                </div>
                <div class="fleet-nav">
                    <button type="button" class="fleet-nav-btn">&#8249;</button>
                    <button type="button" class="fleet-nav-btn">&#8250;</button>
                </div>
            </div>
            <div class="fleet-grid">
                <!-- Card 1 — featured (white button) -->
                <div class="fleet-card reveal">
                    <img class="fleet-img" src="https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=700&q=80" alt="Porsche 911 GT3" />
                    <div class="fleet-info">
                        <div class="fleet-name">Porsche 911 GT3 &middot; 2025</div>
                        <div class="fleet-specs">
                            <span class="spec">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="3" width="15" height="13" rx="2"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/></svg>
                                Sports Car
                            </span>
                            <span class="spec">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
                                4 Seater
                            </span>
                            <span class="spec">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M9 21V9"/></svg>
                                2 Door
                            </span>
                            <span class="spec">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M12 1v4M12 19v4M4.22 4.22l2.83 2.83M16.95 16.95l2.83 2.83M1 12h4M19 12h4"/></svg>
                                Automatic
                            </span>
                        </div>
                        <button type="button" class="btn-fleet" onclick="openModal('m-login')">View Details</button>
                    </div>
                </div>
                <!-- Card 2 -->
                <div class="fleet-card reveal">
                    <img class="fleet-img" src="https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=700&q=80" alt="BMW 7 Series" />
                    <div class="fleet-info">
                        <div class="fleet-name">BMW 7 Series &middot; 2025</div>
                        <div class="fleet-specs">
                            <span class="spec">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="3" width="15" height="13" rx="2"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/></svg>
                                Sports Car
                            </span>
                            <span class="spec">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
                                5 Seater
                            </span>
                            <span class="spec">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M9 21V9"/></svg>
                                4 Door
                            </span>
                            <span class="spec">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M12 1v4M12 19v4M4.22 4.22l2.83 2.83M16.95 16.95l2.83 2.83M1 12h4M19 12h4"/></svg>
                                Automatic
                            </span>
                        </div>
                        <button type="button" class="btn-fleet" onclick="openModal('m-login')">View Details</button>
                    </div>
                </div>
                <!-- Card 3 -->
                <div class="fleet-card reveal">
                    <img class="fleet-img" src="https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=700&q=80" alt="Luxury Sedan" />
                    <div class="fleet-info">
                        <div class="fleet-name">Luxury Sedan &middot; 2025</div>
                        <div class="fleet-specs">
                            <span class="spec">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="3" width="15" height="13" rx="2"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/></svg>
                                Luxury Sedan
                            </span>
                            <span class="spec">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
                                5 Seater
                            </span>
                            <span class="spec">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M9 21V9"/></svg>
                                4 Door
                            </span>
                            <span class="spec">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M12 1v4M12 19v4M4.22 4.22l2.83 2.83M16.95 16.95l2.83 2.83M1 12h4M19 12h4"/></svg>
                                Automatic
                            </span>
                        </div>
                        <button type="button" class="btn-fleet" onclick="openModal('m-login')">View Details</button>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ==================== HOW IT WORKS ==================== -->
    <section class="section hiw-bg" id="how-it-works">
        <div class="section-inner">
            <div class="reveal" style="text-align:center;max-width:580px;margin:0 auto 1rem;">
                <span class="sec-label">How It Works</span>
                <h2 class="sec-title">Luxury Rentals Made Effortless</h2>
                <p style="color:var(--grey);font-size:.92rem;margin-top:.7rem;">Getting started is simple. Three steps between you and your perfect drive.</p>
            </div>
            <div class="steps-grid">
                <div class="step-card reveal">
                    <div class="step-bg-num">01</div>
                    <div class="step-icon">&#x1F697;</div>
                    <div class="step-title">Choose Your Vehicle</div>
                    <div class="step-desc">Browse our elite fleet and select the vehicle that matches your style, needs, and budget.</div>
                </div>
                <div class="step-card reveal">
                    <div class="step-bg-num">02</div>
                    <div class="step-icon">&#x1F4C5;</div>
                    <div class="step-title">Book &amp; Confirm</div>
                    <div class="step-desc">Enter your pickup details and receive instant confirmation. No hidden fees, no waiting.</div>
                </div>
                <div class="step-card reveal">
                    <div class="step-bg-num">03</div>
                    <div class="step-icon">&#x2728;</div>
                    <div class="step-title">Enjoy the Ride</div>
                    <div class="step-desc">Your vehicle arrives on time. Sit back and enjoy a premium DriveNow experience.</div>
                </div>
            </div>
        </div>
    </section>

    <!-- ==================== CTA ==================== -->
    <section class="cta-section" id="contact">
        <div class="reveal">
            <h2 class="cta-title">Ready to hit the road?</h2>
            <p class="cta-sub">Join hundreds of satisfied Customers who trust DriveNow for every journey.</p>
            <div class="cta-actions">
                <button type="button" class="btn btn-teal btn-lg" onclick="openModal('m-register')">Create Free Account</button>
                <button type="button" class="btn btn-teal-outline btn-lg" onclick="openModal('m-login')">Sign In</button>
            </div>
        </div>
    </section>

    <!-- ==================== FOOTER ==================== -->
    <footer>
        <div class="footer-logo">
            <svg width="26" height="26" viewBox="0 0 54 54" fill="none">
                <path d="M4 8h16c8.284 0 15 6.716 15 15v8c0 8.284-6.716 15-15 15H4V8z" fill="#1A2332"/>
                <path d="M10 14h8c5.523 0 10 4.477 10 10v6c0 5.523-4.477 10-10 10h-8V14z" fill="#0D1520"/>
                <defs><linearGradient id="ng2" x1="31" y1="8" x2="50" y2="46" gradientUnits="CustomerspaceOnUse"><stop offset="0%" stop-color="#1A2332"/><stop offset="100%" stop-color="#0D9488"/></linearGradient></defs>
                <path d="M31 8h6l13 22V8h4v38h-6L35 24v22h-4V8z" fill="url(#ng2)"/>
            </svg>
            <span class="footer-logo-text">Drive<span>Now</span></span>
        </div>
        <div class="footer-info">
            CTEC2713N &mdash; Agile Development Team Project<br />
            Niels Brock Copenhagen &mdash; 2026
        </div>
        <a href="Login.aspx" class="footer-link">Staff Portal &rarr;</a>
    </footer>

    <!-- ==================== LOGIN MODAL ==================== -->
    <div class="overlay" id="m-login" role="dialog" aria-modal="true" aria-labelledby="lh">
        <div class="modal">
            <button type="button" class="modal-x" onclick="closeModal('m-login')">&times;</button>
            <div class="modal-logo">Drive<span>Now</span></div>
            <h2 class="modal-h" id="lh">Welcome back</h2>
            <p class="modal-p">Sign in to your DriveNow account</p>
            <div class="field">
                <label for="li-email">Email address</label>
                <input type="email" id="li-email" placeholder="you@example.com" autocomplete="email" />
            </div>
            <div class="field">
                <label for="li-pw">Password</label>
                <input type="password" id="li-pw" placeholder="&#x2022;&#x2022;&#x2022;&#x2022;&#x2022;&#x2022;&#x2022;&#x2022;" autocomplete="current-password" />
            </div>
            <button type="button" class="form-btn" onclick="handleLogin()">Sign In</button>
            <p class="modal-switch">No account? <a onclick="switchModal('m-login','m-register')">Create one</a></p>
        </div>
    </div>

    <!-- ==================== REGISTER MODAL ==================== -->
    <div class="overlay" id="m-register" role="dialog" aria-modal="true" aria-labelledby="rh">
        <div class="modal">
            <button type="button" class="modal-x" onclick="closeModal('m-register')">&times;</button>
            <div class="modal-logo">Drive<span>Now</span></div>
            <h2 class="modal-h" id="rh">Create account</h2>
            <p class="modal-p">Join DriveNow and start your journey today</p>
            <div class="field">
                <label for="reg-name">Full name</label>
                <input type="text" id="reg-name" placeholder="Your full name" autocomplete="name" />
            </div>
            <div class="field">
                <label for="reg-email">Email address</label>
                <input type="email" id="reg-email" placeholder="you@example.com" autocomplete="email" />
            </div>
            <div class="field">
                <label for="reg-pw">Password</label>
                <input type="password" id="reg-pw" placeholder="Create a strong password" autocomplete="new-password" />
            </div>
            <button type="button" class="form-btn" onclick="handleRegister()">Create Account</button>
            <p class="modal-switch">Already a member? <a onclick="switchModal('m-register','m-login')">Sign in</a></p>
        </div>
    </div>

</form>

<script>
/* ===== NAVBAR SCROLL ===== */
var navbar = document.getElementById('navbar');
window.addEventListener('scroll', function () {
    navbar.classList.toggle('scrolled', window.scrollY > 50);
});

/* ===== MOBILE NAV ===== */
function toggleNav() {
    document.getElementById('mobile-nav').classList.toggle('open');
}

/* ===== HERO CAROUSEL ===== */
var slides   = document.querySelectorAll('.hero-slide');
var dots     = document.querySelectorAll('.dot');
var cur      = 0;
var autoTmr;

function goSlide(n) {
    slides[cur].classList.remove('active');
    dots[cur].classList.remove('active');
    cur = (n + slides.length) % slides.length;
    slides[cur].classList.add('active');
    dots[cur].classList.add('active');
}
function nextSlide() { clearInterval(autoTmr); goSlide(cur + 1); startAuto(); }
function prevSlide() { clearInterval(autoTmr); goSlide(cur - 1); startAuto(); }
function startAuto() { autoTmr = setInterval(function () { goSlide(cur + 1); }, 5000); }
startAuto();

/* ===== ACCORDION ===== */
function toggleAcc(header) {
    var item   = header.parentElement;
    var isOpen = item.classList.contains('open');
    document.querySelectorAll('.acc-item').forEach(function (el) { el.classList.remove('open'); });
    if (!isOpen) item.classList.add('open');
}

/* ===== MODALS ===== */
function openModal(id)  { document.getElementById(id).classList.add('open'); document.body.style.overflow = 'hidden'; }
function closeModal(id) { document.getElementById(id).classList.remove('open'); document.body.style.overflow = ''; }
function switchModal(a, b) { closeModal(a); setTimeout(function () { openModal(b); }, 220); }

document.querySelectorAll('.overlay').forEach(function (ov) {
    ov.addEventListener('click', function (e) {
        if (e.target === ov) { ov.classList.remove('open'); document.body.style.overflow = ''; }
    });
});
document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
        document.querySelectorAll('.overlay.open').forEach(function (ov) { ov.classList.remove('open'); });
        document.body.style.overflow = '';
    }
});

/* ===== AUTH ===== */
function handleLogin() {
    var email = document.getElementById('li-email').value.trim();
    var pw    = document.getElementById('li-pw').value;
    if (!email || !pw) { alert('Please fill in all fields.'); return; }
    window.location.href = 'MainMenu.aspx';
}
function handleRegister() {
    var name  = document.getElementById('reg-name').value.trim();
    var email = document.getElementById('reg-email').value.trim();
    var pw    = document.getElementById('reg-pw').value;
    if (!name || !email || !pw) { alert('Please fill in all fields.'); return; }
    window.location.href = 'MainMenu.aspx';
}

/* ===== SCROLL REVEAL ===== */
var ro = new IntersectionObserver(function (entries) {
    entries.forEach(function (entry) {
        if (entry.isIntersecting) {
            var d = parseInt(entry.target.dataset.d || '0');
            setTimeout(function () { entry.target.classList.add('visible'); }, d);
            ro.unobserve(entry.target);
        }
    });
}, { threshold: 0.12, rootMargin: '0px 0px -36px 0px' });

document.querySelectorAll('.reveal').forEach(function (el, i) {
    el.dataset.d = (i % 4) * 75;
    ro.observe(el);
});

/* ===== COUNTER ANIMATION ===== */
function animateCount(el) {
    var target = parseInt(el.dataset.target);
    var suffix = el.dataset.suffix || '';
    var dur    = 1800;
    var start  = performance.now();
    function tick(now) {
        var p = Math.min((now - start) / dur, 1);
        var e = 1 - Math.pow(1 - p, 3);
        el.textContent = Math.floor(e * target) + suffix;
        if (p < 1) requestAnimationFrame(tick);
        else el.textContent = target + suffix;
    }
    requestAnimationFrame(tick);
}
var co = new IntersectionObserver(function (entries) {
    entries.forEach(function (entry) {
        if (entry.isIntersecting) { animateCount(entry.target); co.unobserve(entry.target); }
    });
}, { threshold: 0.5 });
document.querySelectorAll('.stat-num').forEach(function (el) { co.observe(el); });
</script>
</body>
</html>
