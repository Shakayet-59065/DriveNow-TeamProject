<%-- DriveNow — Customer-Facing Homepage (Default.aspx)
     This is the main public website that customers see when they visit DriveNow.
     It includes:
       - A hero section with a car slideshow and booking form
       - An "About Us" section
       - A "Why DriveNow?" accordion section
       - A featured fleet section showing available vehicles
       - A "How It Works" steps section
       - A stat strip with live numbers
       - A "Rent a Car" booking form section
       - A footer with contact and social links
     The page uses a dark/light alternating theme for visual variety.
     Logic (slideshow, modals, booking) runs in Default.aspx.cs and JavaScript in the page.
     Module: CTEC2713N --%>
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="DriveNow.Default" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>DriveNow - Your Journey, Your DriveNow</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;0,9..40,600;1,9..40,400&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <style>
        :root {
            --navy: #1A2332;
            --navy-deep: #0D1520;
            --teal: #006b5f;
            --teal-light: #4fdbc8;
            --teal-pale: #F0FDFA;
            --white: #FFFFFF;
            --off-white: #F8FAFB;
            --grey: #94A3B8;
            --text-dark: #334155;
            --card-bg: rgba(26, 35, 50, 0.6);
            --card-border: rgba(255, 255, 255, 0.07);
            --font-head: 'Outfit', Arial, sans-serif;
            --font-body: 'DM Sans', Arial, sans-serif;
            /* Stitch tokens */
            --st-primary: #006b5f;
            --st-inverse-primary: #4fdbc8;
            --st-surface: #f4fbf8;
            --st-surface-container: #e9efec;
            --st-outline-var: #bbcac6;
            --st-dark: #2b3230;
            --st-text-dark: #1a2421;
            --st-text-mid: #6c7a77;
        }

        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html { scroll-behavior: smooth; }
        body {
            font-family: var(--font-body);
            background: var(--navy-deep);
            color: var(--white);
            overflow-x: hidden;
            line-height: 1.6;
        }

        @keyframes slideUp { from { opacity: 0; transform: translateY(28px); } to { opacity: 1; transform: none; } }
        @keyframes modalIn { from { opacity: 0; transform: translateY(-14px) scale(0.97); } to { opacity: 1; transform: none; } }
        @keyframes marquee { 0% { transform: translateX(0); } 100% { transform: translateX(-50%); } }
        @keyframes glowPulse {
            0%, 100% { opacity: .3; transform: translateX(-50%) scale(1); }
            50% { opacity: .55; transform: translateX(-50%) scale(1.06); }
        }

        .navbar {
            position: fixed;
            inset: 0 0 auto 0;
            z-index: 900;
            padding: 1rem 3rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            background: rgba(13, 21, 32, .65);
            border-bottom: 1px solid rgba(255, 255, 255, .04);
            transition: background .3s, box-shadow .3s;
        }

        .navbar.scrolled {
            background: rgba(13, 21, 32, .97);
            box-shadow: 0 2px 28px rgba(0, 0, 0, .5);
        }

        .nav-logo {
            display: flex;
            align-items: center;
            gap: .55rem;
            text-decoration: none;
        }

        .nav-logo-mark {
            width: 34px;
            height: 34px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .nav-logo-mark svg { width: 100%; height: 100%; }

        .nav-wordmark {
            font-family: var(--font-head);
            font-weight: 700;
            font-size: 1.2rem;
            letter-spacing: 0;
            color: var(--white);
        }

        .nav-wordmark span { color: var(--teal); }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 2rem;
            list-style: none;
        }

        .nav-links a {
            font-size: .9rem;
            font-weight: 500;
            color: var(--grey);
            text-decoration: none;
            padding-bottom: 2px;
            position: relative;
            transition: color .2s;
        }

        .nav-links a:hover,
        .nav-links a.active { color: var(--white); }

        .nav-links a.active::after {
            content: '';
            position: absolute;
            bottom: -2px;
            left: 0;
            right: 0;
            height: 2px;
            background: var(--teal);
            border-radius: 2px;
        }

        .nav-actions { display: flex; align-items: center; gap: .6rem; }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: .5rem 1.3rem;
            border-radius: 100px;
            font-family: var(--font-body);
            font-weight: 500;
            font-size: .88rem;
            cursor: pointer;
            text-decoration: none;
            border: none;
            outline: none;
            white-space: nowrap;
            transition: all .2s ease;
        }

        .btn-ghost-w { background: transparent; color: var(--white); border: 1.5px solid rgba(255, 255, 255, .25); }
        .btn-ghost-w:hover { border-color: var(--white); background: rgba(255, 255, 255, .06); }
        .btn-solid-w { background: var(--white); color: #000; }
        .btn-solid-w:hover { background: #dde3e9; }
        .btn-teal { background: var(--teal); color: var(--white); border-radius: 8px; }
        .btn-teal:hover { background: #005048; box-shadow: 0 4px 22px rgba(0, 107, 95, .38); }
        .btn-teal-outline { background: transparent; color: var(--teal); border: 1.5px solid var(--teal); }
        .btn-teal-outline:hover { background: rgba(0, 107, 95, .08); }
        .btn-lg { padding: .82rem 2.2rem; font-size: .96rem; }

        .hamburger {
            display: none;
            background: none;
            border: 1.5px solid var(--card-border);
            color: var(--white);
            font-size: 1.2rem;
            padding: .3rem .5rem;
            border-radius: 8px;
            cursor: pointer;
        }

        /* ── Navbar pill buttons (theme / lang / help) ──
           Styled here so light/dark mode can override without fighting inline styles. */
        .nav-pill-btn {
            background:    rgba(255,255,255,.08);
            border:        1px solid rgba(255,255,255,.15);
            color:         var(--white);
            padding:       .35rem .75rem;
            border-radius: 22px;
            font-size:     .8rem;
            font-family:   var(--font-body);
            cursor:        pointer;
            display:       flex;
            align-items:   center;
            gap:           .35rem;
            transition:    background .2s, color .2s, border-color .2s;
        }
        .nav-pill-btn:hover { background: rgba(255,255,255,.16); }

        /* ── HERO: split-screen layout ── */
        .hero {
            min-height: 100vh;
            position: relative;
            overflow: hidden;
            display: grid;
            grid-template-columns: 1fr 1fr;
            align-items: center;
            background: var(--navy-deep);
            padding: 80px 0 4rem;
        }

        /* Dark vignette on right so form text stays readable */
        .hero::after {
            content: '';
            position: absolute;
            top: 0; bottom: 0; right: 0;
            width: 60%;
            background: linear-gradient(to right, transparent, rgba(13,21,32,.75) 35%);
            z-index: 1;
            pointer-events: none;
        }

        /* Slideshow full-bleed — cars show through the glass booking box */
        .hero-slides {
            position: absolute;
            inset: 0;
            z-index: 0;
        }

        .hero-slide {
            position: absolute;
            inset: 0;
            opacity: 0;
            transition: opacity .9s ease;
            display: flex;
            align-items: flex-end;
            justify-content: center;
        }

        .hero-slide.active { opacity: 1; }

        .slide-spot {
            position: absolute;
            bottom: -60px;
            left: 50%;
            transform: translateX(-50%);
            width: 700px;
            height: 480px;
            background: radial-gradient(ellipse at 50% 65%, rgba(255,255,255,.065) 0%, rgba(255,255,255,.025) 28%, transparent 68%);
            pointer-events: none;
        }

        .slide-teal {
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 440px;
            height: 200px;
            background: radial-gradient(ellipse at center, rgba(13,148,136,.22) 0%, transparent 70%);
            pointer-events: none;
            animation: glowPulse 5s ease-in-out infinite;
        }

        /* Car sits left-of-centre so it's clearly visible on the left half */
        .slide-car {
            position: absolute;
            bottom: 0;
            left: 38%;
            transform: translateX(-50%);
            width: 72%;
            max-width: 900px;
            object-fit: contain;
            -webkit-mask-image: linear-gradient(to bottom, rgba(0,0,0,1) 50%, transparent 94%);
            mask-image: linear-gradient(to bottom, rgba(0,0,0,1) 50%, transparent 94%);
        }

        /* Right column: booking form — above the gradient overlay */
        .hero-content {
            grid-column: 2;
            position: relative;
            z-index: 10;
            animation: slideUp .75s ease both;
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            text-align: left;
            padding: 2rem 3.5rem 2rem 1rem;
        }

        .hero-eyebrow {
            display: inline-block;
            font-size: .75rem;
            font-weight: 700;
            letter-spacing: .14em;
            text-transform: uppercase;
            color: var(--teal-light);
            margin-bottom: .65rem;
        }

        .hero-title {
            font-family: var(--font-head);
            font-size: clamp(1.4rem, 2.4vw, 2.2rem);
            font-weight: 800;
            letter-spacing: 0;
            line-height: 1.15;
            color: var(--white);
            margin-bottom: 1.4rem;
        }

        .hero-sub {
            display: none;
        }

        /* ── Booking card — white card so it pops over the dark slideshow ── */
        .hero-booking-card {
            width: 100%;
            background: #fff;
            border: 1px solid var(--st-outline-var);
            border-radius: 16px;
            padding: 1.6rem 1.8rem 1.4rem;
            box-shadow: 0 20px 60px rgba(0,0,0,.28);
            text-align: left;
        }

        .hero-booking-card .card-header {
            display: flex;
            align-items: baseline;
            gap: .75rem;
            margin-bottom: 1.4rem;
            border-bottom: 1px solid var(--st-outline-var);
            padding-bottom: 1rem;
        }

        .hero-booking-card .card-title {
            font-family: var(--font-head);
            font-size: 1.15rem;
            font-weight: 700;
            color: var(--st-text-dark);
            margin: 0;
        }

        .hero-booking-card .card-badge {
            font-size: .7rem;
            font-weight: 600;
            letter-spacing: .1em;
            text-transform: uppercase;
            color: var(--st-primary);
            background: rgba(0,107,95,.08);
            border: 1px solid rgba(0,107,95,.2);
            border-radius: 20px;
            padding: .2rem .65rem;
        }

        .c-arrow {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            width: 2.4rem;
            height: 2.4rem;
            border-radius: 50%;
            background: rgba(255,255,255,.07);
            border: 1px solid rgba(255,255,255,.12);
            color: var(--white);
            font-size: .9rem;
            cursor: pointer;
            z-index: 20;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background .2s;
        }

        .c-arrow:hover { background: rgba(255,255,255,.18); }
        /* Arrows within the left (car) half only */
        .c-prev { left: 1.2rem; }
        .c-next { left: calc(50% - 4rem); }

        .c-dots {
            position: absolute;
            bottom: 2rem;
            left: 25%;
            transform: translateX(-50%);
            display: flex;
            gap: .45rem;
            z-index: 20;
        }

        .dot {
            width: 2rem;
            height: 4px;
            border-radius: 2px;
            background: rgba(255,255,255,.22);
            cursor: pointer;
            transition: background .3s;
            border: 0;
            padding: 0;
        }

        .dot.active { background: var(--white); }

        .brand-strip {
            padding: 2rem 0;
            border-top: 1px solid var(--st-outline-var);
            border-bottom: 1px solid var(--st-outline-var);
            overflow: hidden;
            position: relative;
            background: var(--st-surface-container);
        }

        .brand-strip::before,
        .brand-strip::after {
            content: '';
            position: absolute;
            top: 0;
            bottom: 0;
            width: 100px;
            z-index: 2;
            pointer-events: none;
        }

        .brand-strip::before { left: 0; background: linear-gradient(to right, var(--st-surface-container), transparent); }
        .brand-strip::after { right: 0; background: linear-gradient(to left, var(--st-surface-container), transparent); }

        .brand-track {
            display: flex;
            align-items: center;
            gap: 3.5rem;
            animation: marquee 22s linear infinite;
            width: max-content;
        }

        .brand-name {
            font-family: var(--font-head);
            font-size: .82rem;
            font-weight: 600;
            letter-spacing: .12em;
            text-transform: uppercase;
            color: var(--st-text-mid);
            white-space: nowrap;
        }

        .section { padding: 6.5rem 4rem; }
        .section-inner { max-width: 1180px; margin: 0 auto; }

        .sec-label {
            display: inline-flex;
            align-items: center;
            gap: .4rem;
            font-size: .72rem;
            font-weight: 600;
            letter-spacing: .12em;
            text-transform: uppercase;
            color: var(--grey);
            margin-bottom: .7rem;
        }

        .sec-label::before { content: '.'; font-size: 1.1rem; color: var(--teal-light); }

        .sec-title {
            font-family: var(--font-head);
            font-size: clamp(1.9rem, 3.5vw, 2.8rem);
            font-weight: 800;
            letter-spacing: 0;
            line-height: 1.1;
        }

        .reveal {
            opacity: 0;
            transform: translateY(28px);
            transition: opacity .55s ease, transform .55s ease;
        }

        .reveal.visible { opacity: 1; transform: none; }

        .stats-strip {
            padding: 3.5rem 4rem;
            background: var(--st-dark);
            border-top: none;
            border-bottom: none;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 2rem;
            max-width: 860px;
            margin: 0 auto;
            text-align: center;
        }

        .stat-num {
            font-family: var(--font-head);
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--teal-light);
            letter-spacing: 0;
            line-height: 1;
            margin-bottom: .45rem;
        }

        .stat-lbl {
            font-size: .84rem;
            color: rgba(255,255,255,.55);
            font-weight: 500;
            letter-spacing: .07em;
            text-transform: uppercase;
        }

        .about-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 5rem;
            align-items: center;
            margin-top: 3.5rem;
        }

        .about-img {
            width: 100%;
            aspect-ratio: 4 / 3;
            object-fit: cover;
            border-radius: 8px;
            filter: brightness(.88);
            border: 1px solid var(--card-border);
        }

        .about-text h3 {
            font-family: var(--font-head);
            font-size: 1.5rem;
            font-weight: 800;
            letter-spacing: 0;
            line-height: 1.2;
            margin-bottom: 1rem;
        }

        .about-text p {
            font-size: .94rem;
            color: var(--grey);
            line-height: 1.75;
            margin-bottom: .8rem;
        }

        .hiw-bg {
            background: var(--st-surface-container);
            border-top: 1px solid var(--st-outline-var);
            border-bottom: 1px solid var(--st-outline-var);
        }

        .hiw-bg .sec-label { color: var(--st-primary); }
        .hiw-bg .sec-title { color: var(--st-text-dark); }
        .hiw-bg .why-left p { color: var(--st-text-mid); }

        /* Featured fleet section on light background */
        #featured-fleet .sec-label,
        #featured-fleet .sec-label::before { color: var(--st-primary); }
        #featured-fleet .sec-title { color: var(--st-text-dark); }
        #featured-fleet p { color: var(--st-text-mid); }

        /* Rent section on light background */
        .rent-section .sec-label,
        .rent-section .sec-label::before { color: var(--st-primary); }
        .rent-section .sec-title,
        .rent-section h2 { color: var(--st-text-dark); }

        .why-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 5rem;
            align-items: start;
            margin-top: 3.5rem;
        }

        .why-left .sec-title { max-width: 340px; }
        .why-left p { font-size: .94rem; color: var(--grey); line-height: 1.72; margin: 1rem 0 2rem; }

        .accordion { display: flex; flex-direction: column; gap: .55rem; }

        .acc-item {
            background: #fff;
            border: 1px solid var(--st-outline-var);
            border-radius: 8px;
            overflow: hidden;
            transition: border-color .2s, box-shadow .2s;
        }

        .acc-item.open { border-color: var(--st-primary); box-shadow: 0 4px 16px rgba(0,107,95,.08); }

        .acc-header {
            width: 100%;
            display: flex;
            align-items: center;
            gap: .9rem;
            padding: .95rem 1.2rem;
            cursor: pointer;
            color: var(--st-text-dark);
            background: transparent;
            border: 0;
            text-align: left;
            font-family: var(--font-body);
        }

        .acc-num {
            min-width: 1.7rem;
            height: 1.7rem;
            border-radius: 50%;
            border: 1.5px solid var(--st-outline-var);
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: var(--font-head);
            font-size: .75rem;
            font-weight: 700;
            color: var(--st-text-mid);
            transition: all .2s;
        }

        .acc-item.open .acc-num {
            border-color: var(--st-primary);
            color: #fff;
            background: var(--st-primary);
        }

        .acc-title { font-family: var(--font-head); font-size: .95rem; font-weight: 700; flex: 1; color: var(--st-text-dark); }
        .acc-chevron { color: var(--st-text-mid); font-size: .7rem; transition: transform .25s; }
        .acc-item.open .acc-chevron { transform: rotate(180deg); }
        .acc-body { max-height: 0; overflow: hidden; transition: max-height .3s ease; }
        .acc-item.open .acc-body { max-height: 130px; }
        .acc-body-inner { padding: 0 1.2rem 1rem; font-size: .87rem; color: var(--st-text-mid); line-height: 1.65; }

        .fleet-header {
            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            margin-bottom: 2.2rem;
        }

        .fleet-nav { display: flex; gap: .45rem; }

        .fleet-nav-btn {
            width: 2.3rem;
            height: 2.3rem;
            border-radius: 50%;
            background: #fff;
            border: 1px solid var(--st-outline-var);
            color: var(--st-text-mid);
            cursor: pointer;
            font-size: .82rem;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all .2s;
        }

        .fleet-nav-btn:hover { background: var(--st-surface-container); border-color: var(--teal); color: var(--teal); }

        .fleet-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1.2rem;
        }

        .fleet-card {
            background: #fff;
            border: 1px solid var(--st-outline-var);
            border-radius: 12px;
            overflow: hidden;
            transition: border-color .25s, transform .25s, box-shadow .25s;
        }

        .fleet-card:hover { border-color: var(--teal); transform: translateY(-4px); box-shadow: 0 12px 32px rgba(0,107,95,.12); }
        .fleet-card:first-child { border-color: var(--st-outline-var); }
        .fleet-img { width: 100%; aspect-ratio: 16 / 10; object-fit: cover; display: block; transition: transform .3s ease; }
        .fleet-card:hover .fleet-img { transform: scale(1.04); }
        .fleet-info { padding: 1.2rem; }
        .fleet-name { font-family: var(--font-head); font-size: .97rem; font-weight: 700; margin-bottom: .75rem; color: var(--st-text-dark); }
        .fleet-specs { display: flex; gap: .9rem; margin-bottom: 1rem; flex-wrap: wrap; }
        .spec { display: flex; align-items: center; gap: .28rem; font-size: .75rem; color: var(--st-text-mid); }
        .spec svg { opacity: .55; }
        /* fleet-card first-child button override removed */
        /* hover override removed */

        .btn-fleet {
            display: block;
            width: 100%;
            padding: .62rem;
            border-radius: 8px;
            border: 1px solid var(--st-outline-var);
            background: transparent;
            color: var(--st-text-mid);
            font-family: var(--font-body);
            font-size: .85rem;
            font-weight: 500;
            cursor: pointer;
            transition: all .2s;
            text-align: center;
            text-decoration: none;
        }

        .btn-fleet:hover { background: var(--st-surface-container); color: var(--st-text-dark); border-color: var(--teal); }
        .btn-fleet-book { background: var(--teal); border-color: var(--teal); color: var(--white); margin-top: .5rem; }
        .btn-fleet-book:hover { background: #005048; border-color: #005048; color: var(--white); }

        .steps-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1.2rem;
            margin-top: 3rem;
        }

        .rent-section {
            background: var(--st-surface);
            border-top: 1px solid var(--st-outline-var);
        }

        .rent-layout {
            display: grid;
            grid-template-columns: minmax(0, .8fr) minmax(0, 1.2fr);
            gap: 3rem;
            align-items: start;
        }

        .rent-copy p {
            color: var(--st-text-mid);
            font-size: .94rem;
            line-height: 1.75;
            margin-top: 1rem;
            max-width: 430px;
        }

        .rent-form {
            background: #fff;
            border: 1px solid var(--st-outline-var);
            border-radius: 12px;
            padding: 1.4rem;
            box-shadow: 0 4px 20px rgba(0,0,0,.05);
        }

        .rent-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 1rem;
        }

        .rent-field label {
            display: block;
            color: var(--st-text-mid);
            font-size: .8rem;
            font-weight: 500;
            margin-bottom: .38rem;
        }

        .rent-field input,
        .rent-field select {
            width: 100%;
            min-height: 44px;
            padding: .68rem .85rem;
            background: var(--st-surface);
            border: 1px solid var(--st-outline-var);
            border-radius: 8px;
            color: var(--st-text-dark);
            font-family: var(--font-body);
            font-size: .9rem;
            outline: none;
        }

        .rent-field select option {
            color: var(--st-text-dark);
        }

        .rent-field input:focus,
        .rent-field select:focus {
            border-color: var(--teal);
            box-shadow: 0 0 0 3px rgba(0,107,95,.15);
        }

        .rent-wide {
            grid-column: 1 / -1;
        }

        .rent-message {
            display: block;
            color: #fca5a5;
            font-size: .84rem;
            margin-bottom: 1rem;
        }

        .rent-message.success {
            color: #86efac;
        }

        .rent-submit {
            margin-top: 1rem;
            width: 100%;
        }

        .step-card {
            background: #fff;
            border: 1px solid var(--st-outline-var);
            border-radius: 12px;
            padding: 1.8rem;
            position: relative;
            overflow: hidden;
            transition: box-shadow .2s, transform .2s;
        }

        .step-card:hover { transform: translateY(-4px); box-shadow: 0 12px 32px rgba(0,107,95,.1); border-color: var(--st-primary); }

        .step-bg-num {
            position: absolute;
            top: 1rem;
            right: 1.2rem;
            font-family: var(--font-head);
            font-size: 3.8rem;
            font-weight: 900;
            color: rgba(0,107,95,.06);
            line-height: 1;
            letter-spacing: 0;
        }

        .step-icon {
            width: 2.8rem;
            height: 2.8rem;
            border-radius: 8px;
            background: rgba(0,107,95,.08);
            border: 1px solid rgba(0,107,95,.18);
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 1.1rem;
            color: var(--st-primary);
        }

        .step-title { font-family: var(--font-head); font-size: 1.05rem; font-weight: 700; margin-bottom: .45rem; color: var(--st-text-dark); }
        .step-desc { font-size: .87rem; color: var(--st-text-mid); line-height: 1.65; }

        .cta-section {
            padding: 7rem 4rem;
            text-align: center;
            position: relative;
            overflow: hidden;
            background: linear-gradient(135deg, #0b3d3a 0%, #0d2f2c 45%, #0D1520 100%);
        }

        .cta-section::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 600px;
            height: 380px;
            background: radial-gradient(ellipse, rgba(13,148,136,.22) 0%, transparent 70%);
            pointer-events: none;
        }

        .cta-title {
            font-family: var(--font-head);
            font-size: clamp(2rem, 4vw, 3.2rem);
            font-weight: 800;
            letter-spacing: 0;
            margin-bottom: .85rem;
            position: relative;
            z-index: 1;
            color: var(--white); /* always white — cta-section bg is always dark */
        }

        /* cta-sub always white text — background is always a dark gradient */
        .cta-sub { font-size: 1rem; color: rgba(255,255,255,.68); margin-bottom: 2.2rem; position: relative; z-index: 1; }
        .cta-actions { display: flex; justify-content: center; gap: 1rem; flex-wrap: wrap; position: relative; z-index: 1; }

        footer {
            padding: 2.2rem 4rem;
            background: rgba(0,0,0,.35);
            border-top: 1px solid var(--card-border);
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 1rem;
        }

        .footer-logo { display: flex; align-items: center; gap: .5rem; }
        .footer-logo-text { font-family: var(--font-head); font-weight: 700; font-size: 1.1rem; letter-spacing: 0; color: var(--white); }
        .footer-logo-text span { color: var(--teal); }
        .footer-info { font-size: .8rem; color: var(--grey); text-align: center; line-height: 1.6; }
        .footer-link { color: var(--teal); text-decoration: none; font-size: .85rem; font-weight: 500; transition: color .2s; }
        .footer-link:hover { color: var(--teal-light); }

        .overlay {
            position: fixed;
            inset: 0;
            z-index: 9999;
            background: rgba(0,0,0,.78);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 0;
            pointer-events: none;
            transition: opacity .25s ease;
            padding: 1rem;
        }

        .overlay.open { opacity: 1; pointer-events: all; }

        .modal {
            background: #111b27;
            border: 1px solid rgba(255,255,255,.09);
            border-radius: 12px;
            padding: 2.4rem;
            width: 100%;
            max-width: 420px;
            position: relative;
        }

        .overlay.open .modal { animation: modalIn .28s ease both; }

        .modal-x {
            position: absolute;
            top: 1.1rem;
            right: 1.1rem;
            background: rgba(255,255,255,.04);
            border: 1px solid var(--card-border);
            color: var(--grey);
            width: 2rem;
            height: 2rem;
            border-radius: 8px;
            cursor: pointer;
            font-size: 1.1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all .2s;
        }

        .modal-x:hover { color: var(--white); background: rgba(255,255,255,.08); }
        .modal-logo { font-family: var(--font-head); font-weight: 700; font-size: 1.3rem; margin-bottom: .4rem; color: var(--white); }
        .modal-logo span { color: var(--teal); }
        .modal-h { font-family: var(--font-head); font-size: 1.18rem; font-weight: 700; margin-bottom: .18rem; }
        .modal-p { font-size: .86rem; color: var(--grey); margin-bottom: 1.2rem; }
        .field { margin-bottom: 1.05rem; }

        .field label {
            display: block;
            font-size: .8rem;
            font-weight: 500;
            color: rgba(255,255,255,.65);
            margin-bottom: .38rem;
        }

        .field input {
            width: 100%;
            padding: .68rem .9rem;
            background: rgba(255,255,255,.05);
            border: 1px solid rgba(255,255,255,.1);
            border-radius: 8px;
            color: var(--white);
            font-family: var(--font-body);
            font-size: .91rem;
            outline: none;
            transition: border-color .2s, box-shadow .2s;
        }

        .field input::placeholder { color: rgba(255,255,255,.2); }
        .field input:focus { border-color: var(--teal); box-shadow: 0 0 0 3px rgba(13,148,136,.15); }

        .form-btn {
            width: 100%;
            padding: .8rem;
            background: var(--teal);
            color: var(--white);
            border: none;
            border-radius: 8px;
            font-family: var(--font-body);
            font-size: .94rem;
            font-weight: 600;
            cursor: pointer;
            margin-top: .3rem;
            transition: all .2s;
        }

        .form-btn:hover { background: #005048; box-shadow: 0 4px 20px rgba(0,107,95,.35); }
        .modal-switch { text-align: center; font-size: .83rem; color: var(--grey); margin-top: 1.3rem; }
        .modal-switch a { color: var(--teal); cursor: pointer; font-weight: 500; }
        .modal-switch a:hover { color: var(--teal-light); }

        .consent-text {
            color: var(--grey);
            font-size: .86rem;
            line-height: 1.65;
            margin: 1rem 0;
        }

        .consent-list {
            color: var(--grey);
            font-size: .84rem;
            line-height: 1.6;
            margin: 0 0 1rem 1.1rem;
        }

        .consent-check {
            display: flex;
            align-items: flex-start;
            gap: .55rem;
            color: rgba(255,255,255,.78);
            font-size: .84rem;
            line-height: 1.5;
            margin: 1rem 0;
        }

        .consent-check input {
            margin-top: .22rem;
        }

        .consent-actions {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: .75rem;
        }

        .validation-summary,
        .validation-msg,
        .form-message {
            color: #fca5a5;
            font-size: .8rem;
        }

        .validation-summary {
            background: rgba(239, 68, 68, .08);
            border: 1px solid rgba(239, 68, 68, .2);
            border-radius: 8px;
            padding: .75rem .9rem;
            margin-bottom: 1rem;
        }

        .validation-summary ul { margin-left: 1rem; }
        .validation-msg { display: block; margin-top: .28rem; }
        .form-message { display: block; margin-bottom: 1rem; }
        .form-message.success { color: #86efac; }

        .dn-label { display: block; font-size: .8rem; font-weight: 500; color: var(--st-text-mid); margin-bottom: .38rem; }
        .dn-input { width: 100%; padding: .68rem .9rem; background: var(--st-surface); border: 1px solid var(--st-outline-var); border-radius: 8px; color: var(--st-text-dark); font-family: var(--font-body); font-size: .91rem; outline: none; transition: border-color .2s, box-shadow .2s; }
        .dn-input::placeholder { color: var(--st-text-mid); }
        .dn-input:focus { border-color: var(--teal); box-shadow: 0 0 0 3px rgba(0,107,95,.15); }

        .mobile-nav {
            display: none;
            flex-direction: column;
            position: fixed;
            top: 62px;
            left: 0;
            right: 0;
            background: rgba(13,21,32,.98);
            border-bottom: 1px solid var(--card-border);
            z-index: 800;
            padding: 1rem 1.5rem;
        }

        .mobile-nav.open { display: flex; }

        .mobile-nav a {
            color: var(--grey);
            text-decoration: none;
            font-size: .93rem;
            font-weight: 500;
            padding: .6rem 0;
            border-bottom: 1px solid var(--card-border);
            transition: color .2s;
        }

        .mobile-nav a:last-child { border: none; }
        .mobile-nav a:hover { color: var(--white); }

        /* ═══════════════════════════════════════════════════
           RESPONSIVE — full overhaul for all screen sizes
           ═══════════════════════════════════════════════════ */

        /* ── Scroll-margin so fixed navbar doesn't hide anchor targets ── */
        #about, #why, #fleet, #featured-fleet, #contact, #home {
            scroll-margin-top: 72px;
        }

        /* ── Small desktop / iPad landscape 900–1199px ── */
        @media (max-width: 1199px) and (min-width: 900px) {
            .fleet-grid   { grid-template-columns: repeat(2, 1fr); }
            .steps-grid   { grid-template-columns: repeat(2, 1fr); }
            .why-grid     { gap: 3rem; }
            .hero-content { padding: 2rem 2rem 2rem .5rem; }
            .hero-title   { font-size: clamp(1.3rem, 2.2vw, 2rem); }
            /* Booking card fields → single col on tighter widths */
            .rent-grid    { grid-template-columns: 1fr; gap: .7rem; }
            .rent-wide    { grid-column: 1; }
        }

        /* ── Tablet portrait & large phones: up to 899px ────
           HERO RESTRUCTURE: car slides block on top, form docked below */
        @media (max-width: 899px) {
            /* Navbar */
            .navbar   { padding: .8rem 1.4rem; }
            .nav-links  { display: none; }
            .nav-actions { display: none; }
            .hamburger  { display: block; }

            /* Hero: becomes a flex column so slides and form stack cleanly */
            .hero {
                display: flex;
                flex-direction: column;
                grid-template-columns: unset;
                align-items: stretch;
                min-height: 100vh;
                min-height: 100svh;
                padding: 64px 0 0;   /* fixed navbar height */
                overflow: hidden;    /* clip children so slides never bleed onto next sections */
            }

            /* Slides: change from absolute fill to a sized flex block */
            .hero-slides {
                position: relative;
                height: 46vh;
                height: 46svh;
                min-height: 200px;
                flex-shrink: 0;
                z-index: 0;
                overflow: hidden;
            }

            /* Gradient: fade the car image downward into the form dock */
            .hero::after {
                position: absolute;
                top: 64px;
                left: 0; right: 0; bottom: auto;
                width: 100%;
                height: 46vh;
                height: 46svh;
                background: linear-gradient(
                    to bottom,
                    transparent 20%,
                    rgba(13,21,32,.6) 65%,
                    rgba(13,21,32,.92) 90%
                );
            }

            /* Form dock: solid dark background, sits cleanly below car */
            .hero-content {
                position: relative;
                grid-column: unset;
                margin-top: 0;
                flex: 1;
                z-index: 10;
                animation: none;
                padding: 1.6rem 1.5rem 2rem;
                align-items: center;
                text-align: center;
                background: var(--navy-deep);
                border-top: 1px solid rgba(255,255,255,.06);
            }

            .hero-booking-card { text-align: left; width: 100%; max-width: 520px; }

            /* Car image: centered within the slides block */
            .slide-car {
                left: 50%;
                transform: translateX(-50%);
                width: 82%;
                bottom: 0;
            }

            /* Carousel arrows: vertically centered inside slides area */
            .c-prev { left: 1rem;  top: calc(64px + 20svh); transform: translateY(-50%); }
            .c-next { left: auto; right: 1rem; top: calc(64px + 20svh); transform: translateY(-50%); }

            /* Dots: near bottom of slides block */
            .c-dots {
                bottom: auto;
                top: calc(64px + 40svh);
                left: 50%;
                transform: translateX(-50%);
            }

            /* Hide decorative fleet label — no room on mobile */
            .hero-slide-badge { display: none; }

            /* ── All sections ── */
            .about-grid   { grid-template-columns: 1fr; gap: 2rem; }
            .why-grid     { grid-template-columns: 1fr; gap: 2rem; }
            .fleet-grid   { grid-template-columns: repeat(2, 1fr); gap: 1rem; }
            .steps-grid   { grid-template-columns: repeat(2, 1fr); }
            .rent-layout  { grid-template-columns: 1fr; gap: 2rem; }
            .rent-grid    { grid-template-columns: 1fr; gap: .75rem; }
            .rent-wide    { grid-column: 1; }
            .stats-grid   { grid-template-columns: repeat(2, 1fr); }
            .section      { padding: 4rem 1.5rem; }
            .stats-strip  { padding: 3rem 1.5rem; }
            .cta-section  { padding: 4rem 1.5rem; }
            footer        { flex-direction: column; text-align: center; padding: 2rem 1.5rem; }
            .fleet-header { flex-direction: column; align-items: flex-start; gap: 1rem; }
        }

        /* ── Phones: up to 599px ── */
        @media (max-width: 599px) {
            .navbar { padding: .75rem 1rem; }

            .hero { padding-top: 58px; }

            .hero-slides {
                height: 42vh;
                height: 42svh;
            }

            .hero::after {
                top: 58px;
                height: 42vh;
                height: 42svh;
                background: linear-gradient(
                    to bottom,
                    transparent 15%,
                    rgba(13,21,32,.65) 55%,
                    rgba(13,21,32,.95) 88%
                );
            }

            .hero-content  { padding: 1.3rem 1rem 1.8rem; }
            .hero-title    { font-size: 1.35rem; line-height: 1.2; }
            .hero-eyebrow  { font-size: .68rem; }

            .hero-booking-card {
                padding: 1.1rem 1rem .9rem;
                border-radius: 12px;
                max-width: 100%;
            }
            .hero-booking-card .card-header { margin-bottom: .9rem; padding-bottom: .7rem; }
            .hero-booking-card .card-title  { font-size: 1rem; }

            .slide-car { width: 92%; }
            .c-arrow   { display: none; }
            .c-dots    {
                top: calc(58px + 37svh);
                left: 50%;
                transform: translateX(-50%);
            }

            .fleet-grid   { grid-template-columns: 1fr; }
            .steps-grid   { grid-template-columns: 1fr; }
            .stats-grid   { grid-template-columns: repeat(2, 1fr); gap: 1.2rem; }
            .stat-num     { font-size: 2rem; }
            .section      { padding: 3rem 1rem; }
            .stats-strip  { padding: 2.5rem 1rem; }
            .cta-section  { padding: 3rem 1rem; }
            footer        { padding: 1.5rem 1rem; }
        }

        /* ── Very small phones: up to 380px ── */
        @media (max-width: 380px) {
            .hero { padding-top: 56px; }
            .hero-slides { height: 38vh; height: 38svh; }
            .hero::after { top: 56px; height: 38vh; height: 38svh; }
            .c-dots { top: calc(56px + 33svh); }

            .hero-content { padding: 1rem .85rem 1.5rem; }
            .hero-title   { font-size: 1.15rem; }
            .hero-booking-card { padding: .9rem .8rem; }
            .hero-booking-card .card-title { font-size: .95rem; }

            .stats-grid { grid-template-columns: 1fr; }
            .stat-num   { font-size: 2.2rem; }
            .section    { padding: 2.5rem .85rem; }
            .cta-section { padding: 2.5rem .85rem; }
        }

        /* ══════════════════════════════════════════════════════════
           LIGHT THEME — toggled via data-theme="light" on <html>
           Dark theme is the default (no attribute needed).
           Only the body, navbar, and section backgrounds flip;
           the hero stays dark so the car slideshow stays readable.
           ══════════════════════════════════════════════════════════ */
        html[data-theme="light"] {
            /* All sections go bright white — no grey or pale-blue tint */
            --navy-deep:         #ffffff;
            --navy:              #f4f6f8;
            --grey:              #475569;
            --card-bg:           rgba(255,255,255,0.98);
            --card-border:       rgba(0,0,0,0.07);
            /* Light versions of Stitch tokens */
            --st-surface:            #f8fafb;
            --st-surface-container:  #ecf2f0;
            --st-outline-var:        #c4d4d1;
        }

        /* Body — pure white, near-black text */
        html[data-theme="light"] body {
            background: #ffffff;
            color: #1a2332;
        }

        /* Hero — keep full dark so the car slideshow text stays readable */
        html[data-theme="light"] .hero {
            background: #0D1520;
        }

        /* Navbar — clean white pill on light background */
        html[data-theme="light"] .navbar {
            background: rgba(255,255,255,.94);
            border-bottom: 1px solid rgba(0,0,0,.09);
        }
        html[data-theme="light"] .navbar.scrolled {
            background: rgba(255,255,255,.99);
            box-shadow: 0 2px 20px rgba(0,0,0,.10);
        }
        html[data-theme="light"] .nav-wordmark        { color: #1a2332; }
        html[data-theme="light"] .nav-wordmark span   { color: var(--teal); }
        html[data-theme="light"] .nav-links a         { color: #334155; }
        html[data-theme="light"] .nav-links a.active,
        html[data-theme="light"] .nav-links a:hover   { color: var(--teal); }
        html[data-theme="light"] .hamburger           { color: #334155; border-color: rgba(0,0,0,.18); }

        /* Mobile nav drawer */
        html[data-theme="light"] .mobile-nav          { background: #ffffff; border-top: 1px solid rgba(0,0,0,.07); }
        html[data-theme="light"] .mobile-nav a        { color: #334155; border-bottom-color: rgba(0,0,0,.06); }

        /* Theme toggle button adapts to light background */
        html[data-theme="light"] #themeToggleBtn {
            background: rgba(0,0,0,.06);
            border-color: rgba(0,0,0,.15);
            color: #334155;
        }

        /* Language / Help dropdowns */
        html[data-theme="light"] #langDropdown,
        html[data-theme="light"] #assistDropdown {
            background: #ffffff;
            border-color: rgba(0,0,0,.10);
            box-shadow: 0 8px 24px rgba(0,0,0,.10);
        }
        html[data-theme="light"] #langDropdown a,
        html[data-theme="light"] #assistDropdown a        { color: #334155 !important; }
        html[data-theme="light"] #assistDropdown .footer-info { color: #64748b; }

        /* Stats strip stays dark — teal numbers need contrast */
        html[data-theme="light"] .stat-lbl { color: rgba(255,255,255,.65); }

        /* Footer stays dark for grounding */
        html[data-theme="light"] footer {
            background: #1a2332;
            border-top: 1px solid rgba(255,255,255,.06);
        }
        html[data-theme="light"] .footer-logo-text { color: #ffffff; }
        html[data-theme="light"] .footer-info      { color: rgba(255,255,255,.55); }

        /* ── Light-mode card shadows — make boxes clearly stand out on white bg ── */
        /* Rent section: subtle background to contrast with white page */
        html[data-theme="light"] .rent-section {
            background: #f4f8f7;
        }
        /* Rent form card — the "Book My Vehicle" box */
        html[data-theme="light"] .rent-form {
            background: #ffffff;
            box-shadow: 0 4px 28px rgba(0,107,95,.10), 0 1px 4px rgba(0,0,0,.07);
            border-color: #c8dbd8;
        }
        /* Fleet cards also get a light shadow */
        html[data-theme="light"] .fleet-card {
            box-shadow: 0 2px 16px rgba(0,0,0,.08);
            border: 1px solid #dde8e6;
        }
        /* Hero booking card on the dark hero — stronger shadow for depth */
        html[data-theme="light"] .hero-booking-card {
            box-shadow: 0 24px 70px rgba(0,0,0,.45), 0 0 0 1px rgba(255,255,255,.12);
        }
        /* "Why DriveNow" and other benefit cards */
        html[data-theme="light"] .why-card,
        html[data-theme="light"] .step-card {
            box-shadow: 0 2px 12px rgba(0,0,0,.06);
            background: #ffffff;
            border: 1px solid #e4eded;
        }

        /* ── Navbar pill buttons (theme / lang / help) in light mode ── */
        html[data-theme="light"] .nav-pill-btn {
            background:   rgba(0,0,0,.06);
            border-color: rgba(0,0,0,.18);
            color:        #334155;
        }
        html[data-theme="light"] .nav-pill-btn:hover {
            background:   rgba(0,0,0,.11);
        }

        /* ── Auth buttons (Staff Login / Customer Login / Sign Up) in the light navbar ── */
        html[data-theme="light"] .navbar .btn-ghost-w {
            color:        #334155;
            border-color: rgba(0,0,0,.22);
        }
        html[data-theme="light"] .navbar .btn-ghost-w:hover {
            background:   rgba(0,0,0,.05);
            border-color: #334155;
        }
        html[data-theme="light"] .navbar .btn-solid-w {
            background: #1a2332;
            color:      #ffffff;
        }
        html[data-theme="light"] .navbar .btn-solid-w:hover {
            background: #0d1520;
        }

        /* ── "Browse Complete Fleet" ghost button on the now-light featured-fleet section ── */
        html[data-theme="light"] #featured-fleet .btn-ghost-w {
            color:        var(--teal);
            border-color: rgba(0,107,95,.35);
            background:   transparent;
        }
        html[data-theme="light"] #featured-fleet .btn-ghost-w:hover {
            background:   rgba(0,107,95,.07);
            border-color: var(--teal);
        }

        /* ── #fleet section (Deals & Promotions) — heading + filter chips go invisible in light mode ── */
        /* h3 "Browse by Vehicle Type" has hardcoded color:#fff inline */
        html[data-theme="light"] #fleet h3 {
            color: #1a2332 !important;
        }
        /* Filter chips (SUV, Minivan…) have color:#e2e8f0 and near-transparent bg inline */
        html[data-theme="light"] #fleet a.reveal {
            background:   var(--st-surface-container) !important;
            border-color: rgba(0,107,95,.2) !important;
            color:        var(--teal) !important;
        }
        html[data-theme="light"] #fleet a.reveal:hover {
            background:   rgba(0,107,95,.08) !important;
        }

        /* ── Contributor recruitment section ── */
        /* Card uses rgba(255,255,255,.04) bg + color:#fff text — both invisible on white body */
        html[data-theme="light"] #contrib-cta [style*="background:rgba(255,255,255,.04)"] {
            background:   rgba(0,107,95,.06) !important;
            border-color: rgba(0,107,95,.18) !important;
        }
        html[data-theme="light"] #contrib-cta [style*="color:#fff"] {
            color: #1a2332 !important;
        }
        html[data-theme="light"] #contrib-cta [style*="color:#cbd5e1"] {
            color: #475569 !important;
        }
        /* Sub-stat cards inside the contributor card */
        html[data-theme="light"] #contrib-cta [style*="background:rgba(255,255,255,.04)"][style*="border-radius:14px"] {
            background:   rgba(0,107,95,.08) !important;
        }
        /* The £1,200 teal number stays teal — fine in light mode */

        /* ── Destinations section heading — inherits body color, no issue ── */
        /* ── About section — inherits body color, no issue ── */

        /* ═══════════════════════════════════════════════════════════════════
           DARK MODE (default — no data-theme attribute on <html>)
           Force every alternating "light" section and white card to be dark
           so the whole page is consistently dark when scrolling.
           ═══════════════════════════════════════════════════════════════════ */

        /* ── Brand / partner strip ── */
        html:not([data-theme="light"]) .brand-strip {
            background: #162521;
            border-top-color:    rgba(255,255,255,.07);
            border-bottom-color: rgba(255,255,255,.07);
        }
        html:not([data-theme="light"]) .brand-strip::before {
            background: linear-gradient(to right, #162521, transparent);
        }
        html:not([data-theme="light"]) .brand-strip::after {
            background: linear-gradient(to left,  #162521, transparent);
        }
        html:not([data-theme="light"]) .brand-name { color: rgba(255,255,255,.40); }

        /* ── How It Works / Why DriveNow (hiw-bg) ── */
        html:not([data-theme="light"]) .hiw-bg {
            background: #162521;
            border-top-color:    rgba(255,255,255,.07);
            border-bottom-color: rgba(255,255,255,.07);
        }
        html:not([data-theme="light"]) .hiw-bg .sec-label,
        html:not([data-theme="light"]) .hiw-bg .sec-label::before { color: var(--teal-light); }
        html:not([data-theme="light"]) .hiw-bg .sec-title  { color: #e8f0ee; }
        html:not([data-theme="light"]) .hiw-bg .why-left p { color: #8baaa5; }

        /* ── Accordion items (inside hiw-bg / Why DriveNow) ── */
        html:not([data-theme="light"]) .acc-item {
            background:    #1e3330;
            border-color:  rgba(255,255,255,.09);
        }
        html:not([data-theme="light"]) .acc-header     { color: #e8f0ee; }
        html:not([data-theme="light"]) .acc-title       { color: #e8f0ee; }
        html:not([data-theme="light"]) .acc-body-inner  { color: #8baaa5; }
        html:not([data-theme="light"]) .acc-num {
            border-color: rgba(255,255,255,.18);
            color: #8baaa5;
        }
        html:not([data-theme="light"]) .acc-chevron { color: #8baaa5; }

        /* ── Featured fleet section ──
           Uses style="background:var(--st-surface)" inline → needs !important to override */
        html:not([data-theme="light"]) #featured-fleet {
            background: #0D1520 !important;
        }
        html:not([data-theme="light"]) #featured-fleet .sec-label,
        html:not([data-theme="light"]) #featured-fleet .sec-label::before { color: var(--teal-light); }
        html:not([data-theme="light"]) #featured-fleet .sec-title { color: #e8f0ee; }
        html:not([data-theme="light"]) #featured-fleet p           { color: #8baaa5; }

        /* Fleet cards */
        html:not([data-theme="light"]) .fleet-card {
            background:   #1e3330;
            border-color: rgba(255,255,255,.09);
        }
        html:not([data-theme="light"]) .fleet-name { color: #e8f0ee; }
        html:not([data-theme="light"]) .spec        { color: #8baaa5; }
        html:not([data-theme="light"]) .btn-fleet {
            color:        #8baaa5;
            border-color: rgba(255,255,255,.13);
        }
        html:not([data-theme="light"]) .btn-fleet:hover {
            background:   rgba(255,255,255,.06);
            color:        #e8f0ee;
            border-color: var(--teal-light);
        }
        html:not([data-theme="light"]) .fleet-nav-btn {
            background:   #1e3330;
            border-color: rgba(255,255,255,.09);
            color:        #e8f0ee;
        }
        html:not([data-theme="light"]) .fleet-nav-btn:hover {
            border-color: var(--teal-light);
            color:        var(--teal-light);
        }

        /* ── Rent / Book a Vehicle section ── */
        html:not([data-theme="light"]) .rent-section {
            background:         #162521;
            border-top-color:   rgba(255,255,255,.07);
        }
        html:not([data-theme="light"]) .rent-section .sec-label,
        html:not([data-theme="light"]) .rent-section .sec-label::before { color: var(--teal-light); }
        html:not([data-theme="light"]) .rent-section .sec-title,
        html:not([data-theme="light"]) .rent-section h2  { color: #e8f0ee; }
        html:not([data-theme="light"]) .rent-copy p      { color: #8baaa5; }

        /* Rent form card ("Book My Vehicle" box) inside the Rent section */
        html:not([data-theme="light"]) .rent-form {
            background:   #1e3330;
            border-color: rgba(255,255,255,.10);
            box-shadow:   none;
        }
        /* IMPORTANT: scope to .rent-section only — the hero booking card also uses
           .rent-field/.rent-grid but sits on a white background and must stay dark-text */
        html:not([data-theme="light"]) .rent-section .rent-field label {
            color: rgba(255,255,255,.60);
        }
        html:not([data-theme="light"]) .rent-section .rent-field input,
        html:not([data-theme="light"]) .rent-section .rent-field select {
            background:   rgba(255,255,255,.06);
            border-color: rgba(255,255,255,.12);
            color:        #e8f0ee;
        }
        html:not([data-theme="light"]) .rent-section .rent-field input::placeholder { color: rgba(255,255,255,.25); }

        /* ── How It Works step cards ── */
        html:not([data-theme="light"]) .step-card {
            background:   #1e3330;
            border-color: rgba(255,255,255,.09);
        }
        html:not([data-theme="light"]) .step-title { color: #e8f0ee; }
        html:not([data-theme="light"]) .step-desc  { color: #8baaa5; }
        html:not([data-theme="light"]) .step-bg-num { color: rgba(255,255,255,.04); }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <!-- ═══ NAVIGATION BAR — Fixed at top; contains logo, links, language selector, login/register ═══ -->
    <nav class="navbar" id="navbar">
        <a href="#home" class="nav-logo" aria-label="DriveNow home">
            <div class="nav-logo-mark" aria-hidden="true">
                <svg viewBox="0 0 54 54" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M4 8h16c8.284 0 15 6.716 15 15v8c0 8.284-6.716 15-15 15H4V8z" fill="#1A2332"/>
                    <path d="M10 14h8c5.523 0 10 4.477 10 10v6c0 5.523-4.477 10-10 10h-8V14z" fill="#0D1520"/>
                    <defs>
                        <linearGradient id="navLogoGradient" x1="31" y1="8" x2="50" y2="46" gradientUnits="userSpaceOnUse">
                            <stop offset="0%" stop-color="#1A2332"/>
                            <stop offset="100%" stop-color="#0D9488"/>
                        </linearGradient>
                    </defs>
                    <path d="M31 8h6l13 22V8h4v38h-6L35 24v22h-4V8z" fill="url(#navLogoGradient)"/>
                </svg>
            </div>
            <span class="nav-wordmark">Drive<span>Now</span></span>
        </a>

        <ul class="nav-links">
            <li><a href="#home" class="active">Home</a></li>
            <li><a href="BrowseFleet.aspx">Fleet</a></li>
            <li><a href="#" onclick="openInfoModal('contact');return false;">Contact</a></li>
            <li><a href="ContributorApply.aspx">Contribute</a></li>
        </ul>

        <div class="nav-actions" style="display:flex;align-items:center;gap:.6rem;">

            <!-- Dark / Light theme toggle — switches --navy-deep and body background; hero stays dark -->
            <button type="button" id="themeToggleBtn" onclick="toggleTheme()"
                class="nav-pill-btn"
                title="Switch to light mode">
                &#9728;&#xFE0F; Light
            </button>

            <!-- Language selector -->
            <div style="position:relative;">
                <button type="button" id="langBtn" onclick="toggleLangMenu()" aria-label="Select language"
                    class="nav-pill-btn">
                    EN &#9662;
                </button>
                <div id="langDropdown" style="display:none;position:absolute;right:0;top:calc(100% + 8px);background:#1a2332;border:1px solid rgba(255,255,255,.1);border-radius:10px;min-width:130px;padding:6px 0;z-index:999;box-shadow:0 8px 24px rgba(0,0,0,.4);">
                    <a onclick="setLang('EN','English')" style="display:block;padding:8px 16px;font-size:.82rem;color:#e2e8f0;cursor:pointer;text-decoration:none;">English</a>
                    <a onclick="setLang('DA','Dansk')"   style="display:block;padding:8px 16px;font-size:.82rem;color:#e2e8f0;cursor:pointer;text-decoration:none;">Dansk</a>
                    <a onclick="setLang('DE','Deutsch')" style="display:block;padding:8px 16px;font-size:.82rem;color:#e2e8f0;cursor:pointer;text-decoration:none;">Deutsch</a>
                    <a onclick="setLang('FR','Fran&#231;ais')" style="display:block;padding:8px 16px;font-size:.82rem;color:#e2e8f0;cursor:pointer;text-decoration:none;">Français</a>
                    <a onclick="setLang('SV','Svenska')" style="display:block;padding:8px 16px;font-size:.82rem;color:#e2e8f0;cursor:pointer;text-decoration:none;">Svenska</a>
                </div>
            </div>

            <!-- Need Assistance dropdown -->
            <div style="position:relative;">
                <button type="button" id="assistBtn" onclick="toggleAssistMenu()" aria-label="Need assistance"
                    class="nav-pill-btn">
                    &#9776; Help
                </button>
                <div id="assistDropdown" style="display:none;position:absolute;right:0;top:calc(100% + 8px);background:#1a2332;border:1px solid rgba(255,255,255,.1);border-radius:10px;min-width:200px;padding:6px 0;z-index:999;box-shadow:0 8px 24px rgba(0,0,0,.4);">
                    <div style="padding:8px 16px 4px;font-size:.72rem;text-transform:uppercase;letter-spacing:.08em;color:#64748b;">Need Assistance?</div>
                    <a href="#" onclick="closeAllMenus();openInfoModal('faq');return false;"     style="display:block;padding:8px 16px;font-size:.82rem;color:#e2e8f0;text-decoration:none;">&#10067; FAQ</a>
                    <a href="#" onclick="closeAllMenus();openInfoModal('service');return false;" style="display:block;padding:8px 16px;font-size:.82rem;color:#e2e8f0;text-decoration:none;">Customer Service</a>
                    <a href="#" onclick="closeAllMenus();openInfoModal('contact');return false;" style="display:block;padding:8px 16px;font-size:.82rem;color:#e2e8f0;text-decoration:none;">&#9993; Contact Us</a>
                    <a href="#" onclick="closeAllMenus();openEReceiptInfo();return false;"       style="display:block;padding:8px 16px;font-size:.82rem;color:#e2e8f0;text-decoration:none;">Get E-Receipt</a>
                    <hr style="border:none;border-top:1px solid rgba(255,255,255,.08);margin:4px 0;" />
                    <a href="#" onclick="closeAllMenus();openClaimsInfo();return false;"         style="display:block;padding:8px 16px;font-size:.82rem;color:#f87171;text-decoration:none;">&#9888; Claims / Accident</a>
                </div>
            </div>

            <asp:Panel ID="pnlNavGuest" runat="server" style="display:contents;">
                <a href="Login.aspx" target="_blank" class="btn btn-ghost-w" style="font-size:.82rem;padding:.5rem 1rem;">Staff Login</a>
                <button type="button" class="btn btn-ghost-w" onclick="openModal('m-login')">Customer Login</button>
                <button type="button" class="btn btn-solid-w" onclick="openModal('m-register')">Sign Up</button>
            </asp:Panel>
            <asp:Panel ID="pnlNavLoggedIn" runat="server" Visible="false" style="display:contents;">
                <a href="CustomerPortal.aspx" class="btn btn-ghost-w" style="margin-right:.5rem;">My Dashboard</a>
                <asp:Button ID="btnNavLogout" runat="server" Text="Log Out" CssClass="btn btn-solid-w" OnClick="btnNavLogout_Click" CausesValidation="false" />
            </asp:Panel>
        </div>
        <button type="button" class="hamburger" aria-label="Open navigation" aria-expanded="false" aria-controls="mobile-nav" onclick="toggleNav(this)">&#9776;</button>
    </nav>

    <div class="mobile-nav" id="mobile-nav">
        <a href="#home" onclick="toggleNav()">Home</a>
        <a href="BrowseFleet.aspx" onclick="toggleNav()">Fleet</a>
        <a href="#" onclick="toggleNav();openInfoModal('contact');return false;">Contact</a>
    </div>

    <!-- #rent anchor kept for backward compatibility -->
    <span id="rent" style="position:absolute;top:0;"></span>
    <!-- ═══ HERO SECTION — Dark background with car slideshow + booking form side by side ═══ -->
    <section class="hero" id="home">
        <!-- Left-side floating badge (sits over the car slideshow) -->
        <div class="hero-slide-badge" style="position:absolute;bottom:3.5rem;left:1.8rem;z-index:15;display:flex;flex-direction:column;gap:.5rem;">
            <div style="font-size:.68rem;font-weight:700;letter-spacing:.12em;text-transform:uppercase;color:var(--teal-light);opacity:.85;">Our Fleet</div>
            <div id="slideLabel" style="font-family:var(--font-head);font-size:1rem;font-weight:700;color:#fff;opacity:.9;transition:opacity .4s;">Luxury &amp; Performance Cars</div>
        </div>

        <div class="hero-slides">
            <div class="hero-slide active">
                <div class="slide-spot"></div>
                <div class="slide-teal"></div>
                <img class="slide-car" src="https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=900&q=60" alt="Luxury DriveNow vehicle" />
            </div>
            <div class="hero-slide">
                <div class="slide-spot"></div>
                <div class="slide-teal"></div>
                <img class="slide-car" src="https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=900&q=60" alt="Sports car" />
            </div>
            <div class="hero-slide">
                <div class="slide-spot"></div>
                <div class="slide-teal"></div>
                <img class="slide-car" src="https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=900&q=60" alt="Executive sedan" />
            </div>
        </div>

        <div class="hero-content">
            <span class="hero-eyebrow">Premium Car Rental</span>
            <h1 class="hero-title">Your Journey, Your DriveNow</h1>

            <!-- ── Merged booking card ── -->
            <div class="hero-booking-card">
                <div class="card-header">
                    <p class="card-title">Plan Your Next Drive</p>
                    <span class="card-badge">Rent a Car</span>
                </div>

                <asp:ValidationSummary ID="RentValidationSummary" runat="server" CssClass="validation-summary" ValidationGroup="RentGroup" DisplayMode="BulletList" />
                <asp:Label ID="RentMessageLabel" runat="server" CssClass="rent-message" EnableViewState="false" />

                <div class="rent-grid">
                    <div class="rent-field">
                        <asp:Label ID="PickupLocationLabel" runat="server" AssociatedControlID="PickupLocationTextBox" Text="Pickup location" />
                        <asp:TextBox ID="PickupLocationTextBox" runat="server" MaxLength="120" placeholder="e.g. Niels Brock Copenhagen" />
                        <asp:RequiredFieldValidator ID="PickupLocationRequiredValidator" runat="server" ControlToValidate="PickupLocationTextBox" ValidationGroup="RentGroup" CssClass="validation-msg" ErrorMessage="Pickup location is required." Display="Dynamic" />
                    </div>

                    <div class="rent-field">
                        <asp:Label ID="DropLocationLabel" runat="server" AssociatedControlID="DropLocationTextBox" Text="Drop-off location" />
                        <asp:TextBox ID="DropLocationTextBox" runat="server" MaxLength="120" placeholder="e.g. Copenhagen Airport" />
                        <asp:RequiredFieldValidator ID="DropLocationRequiredValidator" runat="server" ControlToValidate="DropLocationTextBox" ValidationGroup="RentGroup" CssClass="validation-msg" ErrorMessage="Drop-off location is required." Display="Dynamic" />
                    </div>

                    <div class="rent-field">
                        <asp:Label ID="PickupDateLabel" runat="server" AssociatedControlID="PickupDateTextBox" Text="Pickup date" />
                        <asp:TextBox ID="PickupDateTextBox" runat="server" TextMode="Date" />
                        <asp:RequiredFieldValidator ID="PickupDateRequiredValidator" runat="server" ControlToValidate="PickupDateTextBox" ValidationGroup="RentGroup" CssClass="validation-msg" ErrorMessage="Pickup date is required." Display="Dynamic" />
                    </div>

                    <div class="rent-field">
                        <asp:Label ID="DropDateLabel" runat="server" AssociatedControlID="DropDateTextBox" Text="Return date" />
                        <asp:TextBox ID="DropDateTextBox" runat="server" TextMode="Date" />
                        <asp:RequiredFieldValidator ID="DropDateRequiredValidator" runat="server" ControlToValidate="DropDateTextBox" ValidationGroup="RentGroup" CssClass="validation-msg" ErrorMessage="Return date is required." Display="Dynamic" />
                    </div>

                    <div class="rent-field rent-wide">
                        <asp:Label ID="ServiceTypeLabel" runat="server" AssociatedControlID="ServiceTypeDropDownList" Text="Service type" />
                        <asp:DropDownList ID="ServiceTypeDropDownList" runat="server">
                            <%-- Items populated from tblTripType in Page_Load; static fallback below is overwritten --%>
                            <asp:ListItem Text="Select service type" Value="" />
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="ServiceTypeRequiredValidator" runat="server" ControlToValidate="ServiceTypeDropDownList" InitialValue="" ValidationGroup="RentGroup" CssClass="validation-msg" ErrorMessage="Service type is required." Display="Dynamic" />
                    </div>
                </div>

                <asp:Button ID="RentButton" runat="server" CssClass="form-btn rent-submit" Text="Search Available Cars &#8594;" ValidationGroup="RentGroup" OnClick="RentButton_Click" />
            </div>
        </div>

        <button type="button" class="c-arrow c-prev" aria-label="Previous slide" onclick="prevSlide()">‹</button>
        <button type="button" class="c-arrow c-next" aria-label="Next slide" onclick="nextSlide()">›</button>
        <div class="c-dots" aria-label="Carousel slides">
            <button type="button" class="dot active" aria-label="Show slide 1" onclick="goSlide(0)"></button>
            <button type="button" class="dot" aria-label="Show slide 2" onclick="goSlide(1)"></button>
            <button type="button" class="dot" aria-label="Show slide 3" onclick="goSlide(2)"></button>
        </div>
    </section>

    <div class="brand-strip">
        <div class="brand-track">
            <span class="brand-name">BMW</span>
            <span class="brand-name">Mercedes-Benz</span>
            <span class="brand-name">Audi</span>
            <span class="brand-name">Volvo</span>
            <span class="brand-name">Tesla</span>
            <span class="brand-name">Lexus</span>
            <span class="brand-name">Porsche</span>
            <span class="brand-name">Land Rover</span>
            <span class="brand-name">BMW</span>
            <span class="brand-name">Mercedes-Benz</span>
            <span class="brand-name">Audi</span>
            <span class="brand-name">Volvo</span>
            <span class="brand-name">Tesla</span>
            <span class="brand-name">Lexus</span>
            <span class="brand-name">Porsche</span>
            <span class="brand-name">Land Rover</span>
        </div>
    </div>

    <!-- ═══ FEATURED FLEET SECTION — Light background, shows top vehicles from the database ═══ -->
    <section class="section" id="featured-fleet" style="background:var(--st-surface);">
        <div class="section-inner">
            <div class="reveal" style="text-align:center;margin-bottom:2.5rem;">
                <span class="sec-label">Featured Selection</span>
                <h2 class="sec-title">Handpicked Luxury Vehicles</h2>
                <p style="color:var(--grey);font-size:.92rem;margin-top:.5rem;">Explore our curated collection of premium vehicles available for immediate booking.</p>
            </div>

            <div class="fleet-grid">
                <asp:Repeater ID="rptFeaturedFleet" runat="server">
                    <ItemTemplate>
                        <div class="fleet-card reveal">
                            <img class="fleet-img" src='<%# GetFleetImage(Eval("Make").ToString(), Eval("Model").ToString()) %>' alt='<%# Eval("Make") %> <%# Eval("Model") %>' loading="lazy" />
                            <div class="fleet-info">
                                <div class="fleet-name"><%# Eval("Make") %> <%# Eval("Model") %></div>
                                <div class="fleet-specs">
                                    <%# GetFleetSpecs(Eval("Make").ToString()) %>
                                </div>
                                <a href='<%# GetBookingUrl(Eval("VehicleID")) %>' class="btn-fleet btn-fleet-book">Book Now &#8594;</a>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <div style="text-align:center;margin-top:2.5rem;">
                <a href="BrowseFleet.aspx" class="btn btn-ghost-w btn-lg">Browse Complete Fleet</a>
            </div>

        </div>
    </section>

    <!-- ═══ STATS STRIP — Dark background, shows live numbers (trips, customers, etc.) ═══ -->
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
                <div class="stat-num" data-target="<%= TripTypeCount %>" data-suffix="">0</div>
                <div class="stat-lbl">Service Types</div>
            </div>
            <div class="reveal">
                <div class="stat-num" data-target="24" data-suffix="/7">0</div>
                <div class="stat-lbl">Customer Support</div>
            </div>
        </div>
    </div>

    <!-- ═══ ABOUT US SECTION — Light surface background, image + text layout ═══ -->
    <section class="section" id="about">
        <div class="section-inner">
            <div class="reveal">
                <span class="sec-label">About Us</span>
                <h2 class="sec-title">Elite Car Rentals with Refined<br />Service & Unmatched Class</h2>
            </div>
            <div class="about-grid">
                <div class="reveal">
                    <img class="about-img" src="https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=900&q=80" alt="DriveNow fleet"  loading="lazy" />
                </div>
                <div class="about-text reveal">
                    <h3>Delivering Sophistication on Every Ride</h3>
                    <p>At DriveNow, we offer more than just vehicles. We deliver sophistication on wheels. Every hire blends premium quality, precision performance, and attentive service.</p>
                    <p>From first contact to final mile, luxury meets convenience at every turn.</p>
                    <button type="button" class="btn btn-teal-outline btn-lg" style="margin-top:1.2rem;" onclick="openModal('m-register')">Get Started</button>
                </div>
            </div>
        </div>
    </section>

    <!-- ═══ WHY DRIVENOW SECTION — Light container background, accordion FAQ + How It Works steps ═══ -->
    <section class="section hiw-bg" id="why">
        <div class="section-inner">
            <div class="reveal"><span class="sec-label">Why Choose Us</span></div>
            <div class="why-grid">
                <div class="why-left reveal">
                    <h2 class="sec-title">Redefining Luxury Mobility with Distinction</h2>
                    <p>Choosing DriveNow means unlocking trusted service, high-quality vehicles, and a smooth driving experience from booking to return.</p>
                    <a href="#about" class="btn btn-teal btn-lg">Learn More</a>
                </div>
                <div class="why-right reveal">
                    <div class="accordion">
                        <div class="acc-item open">
                            <button type="button" class="acc-header" aria-expanded="true" onclick="toggleAcc(this)">
                                <span class="acc-num">1</span>
                                <span class="acc-title">Diverse Fleet of Prestige Vehicles</span>
                                <span class="acc-chevron" aria-hidden="true">▲</span>
                            </button>
                            <div class="acc-body">
                                <div class="acc-body-inner">Our fleet includes high-performance, comfortable, and elegant cars tailored to every preference and occasion.</div>
                            </div>
                        </div>
                        <div class="acc-item">
                            <button type="button" class="acc-header" aria-expanded="false" onclick="toggleAcc(this)">
                                <span class="acc-num">2</span>
                                <span class="acc-title">Concierge-Level Service</span>
                                <span class="acc-chevron" aria-hidden="true">▲</span>
                            </button>
                            <div class="acc-body">
                                <div class="acc-body-inner">Enjoy a seamless rental experience, from simple booking to prompt delivery at your preferred location.</div>
                            </div>
                        </div>
                        <div class="acc-item">
                            <button type="button" class="acc-header" aria-expanded="false" onclick="toggleAcc(this)">
                                <span class="acc-num">3</span>
                                <span class="acc-title">Flexible Lifestyle Plans</span>
                                <span class="acc-chevron" aria-hidden="true">▲</span>
                            </button>
                            <div class="acc-body">
                                <div class="acc-body-inner">Choose daily, weekly, and monthly rental options with clear payment solutions that fit your journey.</div>
                            </div>
                        </div>
                        <div class="acc-item">
                            <button type="button" class="acc-header" aria-expanded="false" onclick="toggleAcc(this)">
                                <span class="acc-num">4</span>
                                <span class="acc-title">Total Peace of Mind</span>
                                <span class="acc-chevron" aria-hidden="true">▲</span>
                            </button>
                            <div class="acc-body">
                                <div class="acc-body-inner">We prioritise reliable service and vehicle quality, helping every customer enjoy a smooth DriveNow experience.</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ═══════════════════════════════════════════════════
         PROMOTIONAL DEALS SECTION
    ═══════════════════════════════════════════════════ -->
    <section class="section" id="fleet" style="padding:4rem 0;">
        <div class="section-inner">
            <div class="reveal" style="text-align:center;margin-bottom:2.5rem;">
                <span class="sec-label">Exclusive Offers</span>
                <h2 class="sec-title">DriveNow Deals &amp; Promotions</h2>
                <p style="color:var(--grey);font-size:.92rem;margin-top:.5rem;">Unlock savings on your next premium journey.</p>
            </div>

            <!-- Deal cards -->
            <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:1.5rem;margin-bottom:2.5rem;">

                <!-- Deal 1: App download -->
                <div class="reveal" style="background:linear-gradient(135deg,#0f2a3a 0%,#0d9488 100%);border-radius:20px;padding:2rem;position:relative;overflow:hidden;">
                    <div style="position:absolute;top:-20px;right:-20px;width:120px;height:120px;background:rgba(255,255,255,.05);border-radius:50%;"></div>
                    
                    <div style="font-size:2.5rem;font-weight:800;color:#fff;line-height:1;">35% OFF</div>
                    <div style="font-size:1rem;font-weight:600;color:#5eead4;margin:.4rem 0 .75rem;">App Download Deal</div>
                    <p style="font-size:.85rem;color:rgba(255,255,255,.75);margin-bottom:1.2rem;">Download the DriveNow app and get 35% off your first booking. Available for new customers only.</p>
                    <div style="display:inline-block;background:rgba(255,255,255,.15);border:1px solid rgba(255,255,255,.25);color:#fff;padding:.4rem 1rem;border-radius:22px;font-size:.8rem;font-weight:700;letter-spacing:.05em;">Code: APP35</div>
                    <div style="margin-top:1.2rem;">
                        <button type="button" onclick="claimDeal('APP35','35% off your first booking')" style="background:#fff;color:#0d9488;border:none;border-radius:22px;padding:.55rem 1.4rem;font-weight:700;font-size:.88rem;cursor:pointer;">Claim Offer</button>
                    </div>
                </div>

                <!-- Deal 2: Weekend trip -->
                <div class="reveal" style="background:linear-gradient(135deg,#1a2332 0%,#1e3a5f 100%);border-radius:20px;padding:2rem;position:relative;overflow:hidden;">
                    <div style="position:absolute;top:-20px;right:-20px;width:120px;height:120px;background:rgba(255,255,255,.04);border-radius:50%;"></div>
                    
                    <div style="font-size:2.5rem;font-weight:800;color:#fff;line-height:1;">20% OFF</div>
                    <div style="font-size:1rem;font-weight:600;color:#93c5fd;margin:.4rem 0 .75rem;">Weekend Getaway</div>
                    <p style="font-size:.85rem;color:rgba(255,255,255,.75);margin-bottom:1.2rem;">Book a Friday–Sunday rental and enjoy 20% off. Explore Denmark in style for less.</p>
                    <div style="display:inline-block;background:rgba(255,255,255,.1);border:1px solid rgba(255,255,255,.2);color:#fff;padding:.4rem 1rem;border-radius:22px;font-size:.8rem;font-weight:700;letter-spacing:.05em;">Code: WKND20</div>
                    <div style="margin-top:1.2rem;">
                        <button type="button" onclick="claimDeal('WKND20','20% off weekend bookings')" style="background:#3b82f6;color:#fff;border:none;border-radius:22px;padding:.55rem 1.4rem;font-weight:700;font-size:.88rem;cursor:pointer;">Claim Offer</button>
                    </div>
                </div>

                <!-- Deal 3: Spring special -->
                <div class="reveal" style="background:linear-gradient(135deg,#2d1b69 0%,#6d28d9 100%);border-radius:20px;padding:2rem;position:relative;overflow:hidden;">
                    <div style="position:absolute;top:-20px;right:-20px;width:120px;height:120px;background:rgba(255,255,255,.05);border-radius:50%;"></div>
                    
                    <div style="font-size:2.5rem;font-weight:800;color:#fff;line-height:1;">Spring Deal</div>
                    <div style="font-size:1rem;font-weight:600;color:#c4b5fd;margin:.4rem 0 .75rem;">Chauffeured Rides</div>
                    <p style="font-size:.85rem;color:rgba(255,255,255,.75);margin-bottom:1.2rem;">Book a chauffeured trip in May or June and receive a complimentary airport pickup upgrade.</p>
                    <div style="display:inline-block;background:rgba(255,255,255,.1);border:1px solid rgba(255,255,255,.2);color:#fff;padding:.4rem 1rem;border-radius:22px;font-size:.8rem;font-weight:700;letter-spacing:.05em;">Code: SPRING26</div>
                    <div style="margin-top:1.2rem;">
                        <button type="button" onclick="claimDeal('SPRING26','free airport pickup upgrade')" style="background:#a78bfa;color:#fff;border:none;border-radius:22px;padding:.55rem 1.4rem;font-weight:700;font-size:.88rem;cursor:pointer;">Claim Offer</button>
                    </div>
                </div>

            </div>

            <!-- Vehicle segments -->
            <div class="reveal" style="margin-bottom:.75rem;">
                <h3 style="font-size:1.1rem;font-weight:700;color:#fff;margin-bottom:1rem;">Browse by Vehicle Type</h3>
            </div>
            <div style="display:flex;flex-wrap:wrap;gap:.75rem;margin-bottom:2.5rem;">
                <a href="BrowseFleet.aspx" class="reveal" style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.1);border-radius:14px;padding:.7rem 1.4rem;text-decoration:none;color:#e2e8f0;font-size:.88rem;font-weight:500;transition:.2s;">SUV</a>
                <a href="BrowseFleet.aspx" class="reveal" style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.1);border-radius:14px;padding:.7rem 1.4rem;text-decoration:none;color:#e2e8f0;font-size:.88rem;font-weight:500;transition:.2s;">Minivan</a>
                <a href="BrowseFleet.aspx" class="reveal" style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.1);border-radius:14px;padding:.7rem 1.4rem;text-decoration:none;color:#e2e8f0;font-size:.88rem;font-weight:500;transition:.2s;">Compact</a>
                <a href="BrowseFleet.aspx" class="reveal" style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.1);border-radius:14px;padding:.7rem 1.4rem;text-decoration:none;color:#e2e8f0;font-size:.88rem;font-weight:500;transition:.2s;">&#9889; Electric</a>
                <a href="BrowseFleet.aspx" class="reveal" style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.1);border-radius:14px;padding:.7rem 1.4rem;text-decoration:none;color:#e2e8f0;font-size:.88rem;font-weight:500;transition:.2s;">Hybrid</a>
                <a href="BrowseFleet.aspx" class="reveal" style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.1);border-radius:14px;padding:.7rem 1.4rem;text-decoration:none;color:#e2e8f0;font-size:.88rem;font-weight:500;transition:.2s;">&#11088; Luxury</a>
                <a href="BrowseFleet.aspx" class="reveal" style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.1);border-radius:14px;padding:.7rem 1.4rem;text-decoration:none;color:#e2e8f0;font-size:.88rem;font-weight:500;transition:.2s;">Sports</a>
                <a href="BrowseFleet.aspx" class="reveal" style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.1);border-radius:14px;padding:.7rem 1.4rem;text-decoration:none;color:#e2e8f0;font-size:.88rem;font-weight:500;transition:.2s;">Executive</a>
            </div>

            <div style="text-align:center;">
                <a href="BrowseFleet.aspx" class="btn btn-teal" style="padding:.85rem 2.5rem;font-size:1.05rem;">
                    Browse Full Fleet — All Vehicles &#8594;
                </a>
            </div>
        </div>
    </section>

    <!-- ═══════════════════════════════════════════════════
         WHERE TO NEXT — DESTINATIONS
    ═══════════════════════════════════════════════════ -->
    <section class="section" style="padding:4rem 0;background:rgba(255,255,255,.02);">
        <div class="section-inner">
            <div class="reveal" style="text-align:center;margin-bottom:2.5rem;">
                <span class="sec-label">Destinations</span>
                <h2 class="sec-title">Where to Next?</h2>
                <p style="color:var(--grey);font-size:.92rem;margin-top:.5rem;">Premium car hire wherever your journey takes you.</p>
            </div>
            <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:1.25rem;">
                <a href="BrowseFleet.aspx" class="reveal" style="text-decoration:none;position:relative;border-radius:18px;overflow:hidden;display:block;min-height:180px;">
                    <img src="https://images.unsplash.com/photo-1513622470522-26c3c8a854bc?auto=format&fit=crop&w=600&q=70" alt="Copenhagen" style="width:100%;height:180px;object-fit:cover;display:block;" loading="lazy" />
                    <div style="position:absolute;inset:0;background:linear-gradient(to top,rgba(0,0,0,.75) 0%,transparent 60%);border-radius:18px;"></div>
                    <div style="position:absolute;bottom:0;left:0;padding:1.2rem;">
                        <div style="font-size:1.1rem;font-weight:700;color:#fff;">Copenhagen</div>
                        <div style="font-size:.78rem;color:#5eead4;">Denmark</div>
                    </div>
                </a>
                <a href="BrowseFleet.aspx" class="reveal" style="text-decoration:none;position:relative;border-radius:18px;overflow:hidden;display:block;min-height:180px;">
                    <img src="https://images.unsplash.com/photo-1467269204594-9661b134dd2b?auto=format&fit=crop&w=600&q=70" alt="Europe" style="width:100%;height:180px;object-fit:cover;display:block;" loading="lazy" />
                    <div style="position:absolute;inset:0;background:linear-gradient(to top,rgba(0,0,0,.75) 0%,transparent 60%);border-radius:18px;"></div>
                    <div style="position:absolute;bottom:0;left:0;padding:1.2rem;">
                        <div style="font-size:1.1rem;font-weight:700;color:#fff;">Across Europe</div>
                        <div style="font-size:.78rem;color:#5eead4;">Long-distance hire</div>
                    </div>
                </a>
                <a href="BrowseFleet.aspx" class="reveal" style="text-decoration:none;position:relative;border-radius:18px;overflow:hidden;display:block;min-height:180px;">
                    <img src="https://images.unsplash.com/photo-1499092346589-b9b6be3e94b2?auto=format&fit=crop&w=600&q=70" alt="USA" style="width:100%;height:180px;object-fit:cover;display:block;" loading="lazy" />
                    <div style="position:absolute;inset:0;background:linear-gradient(to top,rgba(0,0,0,.75) 0%,transparent 60%);border-radius:18px;"></div>
                    <div style="position:absolute;bottom:0;left:0;padding:1.2rem;">
                        <div style="font-size:1.1rem;font-weight:700;color:#fff;">USA &amp; Canada</div>
                        <div style="font-size:.78rem;color:#5eead4;">Partner network</div>
                    </div>
                </a>
                <a href="BrowseFleet.aspx" class="reveal" style="text-decoration:none;position:relative;border-radius:18px;overflow:hidden;display:block;min-height:180px;">
                    <img src="https://images.unsplash.com/photo-1520175480921-4edfa2983e0f?auto=format&fit=crop&w=600&q=70" alt="Scandinavia" style="width:100%;height:180px;object-fit:cover;display:block;" loading="lazy" />
                    <div style="position:absolute;inset:0;background:linear-gradient(to top,rgba(0,0,0,.75) 0%,transparent 60%);border-radius:18px;"></div>
                    <div style="position:absolute;bottom:0;left:0;padding:1.2rem;">
                        <div style="font-size:1.1rem;font-weight:700;color:#fff;">Scandinavia</div>
                        <div style="font-size:.78rem;color:#5eead4;">Sweden &amp; Norway</div>
                    </div>
                </a>
            </div>
        </div>
    </section>

    <!-- ═══════════════════════════════════════════════════
         CONTRIBUTOR RECRUITMENT
    ═══════════════════════════════════════════════════ -->
    <section id="contrib-cta" class="section" style="padding:4.5rem 0;background:linear-gradient(135deg,rgba(13,148,136,.12) 0%,transparent 70%);">
        <div class="section-inner">
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:3rem;align-items:center;">
                <div class="reveal">
                    <span class="sec-label">Join Our Network</span>
                    <h2 class="sec-title" style="font-size:2rem;">Earn with DriveNow as a Contributor</h2>
                    <p style="color:var(--grey);font-size:.95rem;margin:1rem 0 1.5rem;line-height:1.7;">
                        Have a quality vehicle? Partner with DriveNow and turn it into income.
                        Our contributors earn competitive daily rates while we handle the bookings,
                        customer service, and logistics.
                    </p>
                    <div style="display:flex;flex-direction:column;gap:.75rem;margin-bottom:1.75rem;">
                        <div style="display:flex;align-items:flex-start;gap:.75rem;">
                            <div style="background:#0d9488;border-radius:50%;width:28px;height:28px;display:flex;align-items:center;justify-content:center;flex-shrink:0;font-size:.75rem;color:#fff;font-weight:700;">&#10003;</div>
                            <div style="font-size:.9rem;color:#cbd5e1;"><strong style="color:#fff;">Vehicle Owners</strong> — list your car and earn while it sits idle</div>
                        </div>
                        <div style="display:flex;align-items:flex-start;gap:.75rem;">
                            <div style="background:#0d9488;border-radius:50%;width:28px;height:28px;display:flex;align-items:center;justify-content:center;flex-shrink:0;font-size:.75rem;color:#fff;font-weight:700;">&#10003;</div>
                            <div style="font-size:.9rem;color:#cbd5e1;"><strong style="color:#fff;">Drivers</strong> — join as a chauffeured trip driver with flexible scheduling</div>
                        </div>
                        <div style="display:flex;align-items:flex-start;gap:.75rem;">
                            <div style="background:#0d9488;border-radius:50%;width:28px;height:28px;display:flex;align-items:center;justify-content:center;flex-shrink:0;font-size:.75rem;color:#fff;font-weight:700;">&#10003;</div>
                            <div style="font-size:.9rem;color:#cbd5e1;"><strong style="color:#fff;">Corporate Fleet</strong> — bulk partnership agreements available</div>
                        </div>
                    </div>
                    <a href="ContributorApply.aspx" class="btn btn-teal btn-lg" style="display:inline-block;text-decoration:none;">Apply as Contributor &#8594;</a>
                </div>
                <div class="reveal" style="background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.09);border-radius:24px;padding:2rem;">
                    <div style="text-align:center;margin-bottom:1.5rem;">
                        
                        <div style="font-size:1.3rem;font-weight:700;color:#fff;margin:.5rem 0 .25rem;">Average Contributor Earns</div>
                        <div style="font-size:2.8rem;font-weight:800;color:#14b8a6;">&#163;1,200</div>
                        <div style="font-size:.82rem;color:#64748b;">per month (based on active listings)</div>
                    </div>
                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;">
                        <div style="text-align:center;background:rgba(255,255,255,.04);border-radius:14px;padding:1rem;">
                            <div style="font-size:1.6rem;font-weight:700;color:#fff;">3 days</div>
                            <div style="font-size:.78rem;color:#64748b;">Avg. approval time</div>
                        </div>
                        <div style="text-align:center;background:rgba(255,255,255,.04);border-radius:14px;padding:1rem;">
                            <div style="font-size:1.6rem;font-weight:700;color:#fff;">24/7</div>
                            <div style="font-size:.78rem;color:#64748b;">Support for partners</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

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
                    <div class="step-icon" aria-hidden="true">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 13l2-5a3 3 0 0 1 3-2h8a3 3 0 0 1 3 2l2 5"/><path d="M5 13h14v5H5z"/><circle cx="7" cy="18" r="2"/><circle cx="17" cy="18" r="2"/></svg>
                    </div>
                    <div class="step-title">Choose Your Vehicle</div>
                    <div class="step-desc">Browse our elite fleet and select the vehicle that matches your style, needs, and budget.</div>
                </div>
                <div class="step-card reveal">
                    <div class="step-bg-num">02</div>
                    <div class="step-icon" aria-hidden="true">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="17" rx="2"/><path d="M16 2v4M8 2v4M3 10h18"/></svg>
                    </div>
                    <div class="step-title">Book & Confirm</div>
                    <div class="step-desc">Enter your pickup details and receive confirmation. No hidden fees, no waiting.</div>
                </div>
                <div class="step-card reveal">
                    <div class="step-bg-num">03</div>
                    <div class="step-icon" aria-hidden="true">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 3l1.8 5.4L19 10l-5.2 1.6L12 17l-1.8-5.4L5 10l5.2-1.6L12 3z"/><path d="M19 15l.8 2.2L22 18l-2.2.8L19 21l-.8-2.2L16 18l2.2-.8L19 15z"/></svg>
                    </div>
                    <div class="step-title">Enjoy the Ride</div>
                    <div class="step-desc">Your vehicle arrives on time. Sit back and enjoy a premium DriveNow experience.</div>
                </div>
            </div>
        </div>
    </section>

    <!-- ═══ CONTACT / CTA SECTION — Dark background, contains the Rent a Car form and contact info ═══ -->
    <section class="cta-section" id="contact">
        <div class="reveal">
            <h2 class="cta-title">Ready to hit the road?</h2>
            <p class="cta-sub">Join hundreds of satisfied customers who trust DriveNow for every journey.</p>
            <div class="cta-actions">
                <button type="button" class="btn btn-teal btn-lg" onclick="openModal('m-register')">Create Free Account</button>
                <button type="button" class="btn btn-teal-outline btn-lg" onclick="openModal('m-login')">Sign In</button>
            </div>
        </div>
    </section>

    <footer style="background:#0a111c;border-top:1px solid rgba(255,255,255,.06);padding:4rem 3rem 2rem;">
        <div style="max-width:1280px;margin:0 auto;">

            <!-- Top footer grid -->
            <div style="display:grid;grid-template-columns:2fr 1fr 1fr 1fr 1fr;gap:2.5rem;margin-bottom:3rem;">

                <!-- Brand column -->
                <div>
                    <div class="footer-logo" style="margin-bottom:1rem;">
                        <svg width="26" height="26" viewBox="0 0 54 54" fill="none" aria-hidden="true">
                            <path d="M4 8h16c8.284 0 15 6.716 15 15v8c0 8.284-6.716 15-15 15H4V8z" fill="#1A2332"/>
                            <path d="M10 14h8c5.523 0 10 4.477 10 10v6c0 5.523-4.477 10-10 10h-8V14z" fill="#0D1520"/>
                            <defs>
                                <linearGradient id="footerLogoGradient2" x1="31" y1="8" x2="50" y2="46" gradientUnits="userSpaceOnUse">
                                    <stop offset="0%" stop-color="#1A2332"/>
                                    <stop offset="100%" stop-color="#0D9488"/>
                                </linearGradient>
                            </defs>
                            <path d="M31 8h6l13 22V8h4v38h-6L35 24v22h-4V8z" fill="url(#footerLogoGradient2)"/>
                        </svg>
                        <span class="footer-logo-text">Drive<span>Now</span></span>
                    </div>
                    <p style="font-size:.83rem;color:#64748b;line-height:1.7;max-width:240px;margin-bottom:1.2rem;">
                        Premium vehicle hire and chauffeured journeys across Denmark and Europe.
                        Trusted by hundreds of customers since 2024.
                    </p>
                    <!-- Contact / phone numbers -->
                    <div style="font-size:.8rem;color:#475569;line-height:2;">
                        <div>DK: +45 70 10 20 30</div>
                        <div>UK: +44 20 7946 0958</div>
                        <div>DE: +49 30 1234 5678</div>
                        <div>&#9993; support@drivenow.dk</div>
                    </div>
                </div>

                <!-- Products & Services -->
                <div>
                    <div style="font-size:.72rem;text-transform:uppercase;letter-spacing:.1em;color:#0d9488;font-weight:700;margin-bottom:1rem;">Products &amp; Services</div>
                    <div style="display:flex;flex-direction:column;gap:.6rem;">
                        <a href="BrowseFleet.aspx"   style="font-size:.83rem;color:#64748b;text-decoration:none;">Browse Fleet</a>
                        <a href="BrowseFleet.aspx"   style="font-size:.83rem;color:#64748b;text-decoration:none;">Self-Drive Hire</a>
                        <a href="BrowseFleet.aspx"   style="font-size:.83rem;color:#64748b;text-decoration:none;">Chauffeured Rides</a>
                        <a href="BrowseFleet.aspx"   style="font-size:.83rem;color:#64748b;text-decoration:none;">Airport Transfers</a>
                        <a href="ContributorApply.aspx" style="font-size:.83rem;color:#64748b;text-decoration:none;">Contributor Programme</a>
                        <a href="#" onclick="openInfoModal('travelguide');return false;" style="font-size:.83rem;color:#64748b;text-decoration:none;cursor:pointer;">Travel Guide</a>
                    </div>
                </div>

                <!-- Company -->
                <div>
                    <div style="font-size:.72rem;text-transform:uppercase;letter-spacing:.1em;color:#0d9488;font-weight:700;margin-bottom:1rem;">Company</div>
                    <div style="display:flex;flex-direction:column;gap:.6rem;">
                        <a href="#about"  style="font-size:.83rem;color:#64748b;text-decoration:none;">About Us</a>
                        <a href="Careers.aspx" style="font-size:.83rem;color:#64748b;text-decoration:none;">Careers</a>
                        <a href="#" onclick="openInfoModal('pressmedia');return false;" style="font-size:.83rem;color:#64748b;text-decoration:none;cursor:pointer;">Press &amp; Media</a>
                        <a href="#contact" style="font-size:.83rem;color:#64748b;text-decoration:none;">Contact</a>
                        <a href="Login.aspx" target="_blank" style="font-size:.83rem;color:#64748b;text-decoration:none;">Staff Portal &#8594;</a>
                    </div>
                </div>

                <!-- Legal -->
                <div>
                    <div style="font-size:.72rem;text-transform:uppercase;letter-spacing:.1em;color:#0d9488;font-weight:700;margin-bottom:1rem;">Legal</div>
                    <div style="display:flex;flex-direction:column;gap:.6rem;">
                        <a href="#" onclick="openInfoModal('privacy');return false;" style="font-size:.83rem;color:#64748b;text-decoration:none;cursor:pointer;">Privacy Policy</a>
                        <a href="#" onclick="openInfoModal('terms');return false;" style="font-size:.83rem;color:#64748b;text-decoration:none;cursor:pointer;">Terms &amp; Conditions</a>
                        <a href="#" onclick="openInfoModal('cookiepolicy');return false;" style="font-size:.83rem;color:#64748b;text-decoration:none;cursor:pointer;">Cookie Policy</a>
                        <a href="#" onclick="openCookieSettings();return false;" style="font-size:.83rem;color:#64748b;text-decoration:none;cursor:pointer;">Cookie Preferences</a>
                        <a href="#" onclick="openInfoModal('gdpr');return false;" style="font-size:.83rem;color:#64748b;text-decoration:none;cursor:pointer;">GDPR &amp; Data Rights</a>
                        <a href="#" onclick="openClaimsInfo();return false;" style="font-size:.83rem;color:#f87171;text-decoration:none;cursor:pointer;">Claims / Accident</a>
                    </div>
                </div>

                <!-- Popular Locations -->
                <div>
                    <div style="font-size:.72rem;text-transform:uppercase;letter-spacing:.1em;color:#0d9488;font-weight:700;margin-bottom:1rem;">Popular Locations</div>
                    <div style="display:flex;flex-direction:column;gap:.6rem;">
                        <span style="font-size:.83rem;color:#64748b;display:flex;align-items:center;gap:.4rem;"><span style="color:#0d9488;font-size:.7rem;">&#9679;</span> Copenhagen, DK</span>
                        <span style="font-size:.83rem;color:#64748b;display:flex;align-items:center;gap:.4rem;"><span style="color:#0d9488;font-size:.7rem;">&#9679;</span> Aarhus, DK</span>
                        <span style="font-size:.83rem;color:#64748b;display:flex;align-items:center;gap:.4rem;"><span style="color:#0d9488;font-size:.7rem;">&#9679;</span> Odense, DK</span>
                        <span style="font-size:.83rem;color:#64748b;display:flex;align-items:center;gap:.4rem;"><span style="color:#0d9488;font-size:.7rem;">&#9679;</span> Stockholm, SE</span>
                        <span style="font-size:.83rem;color:#64748b;display:flex;align-items:center;gap:.4rem;"><span style="color:#0d9488;font-size:.7rem;">&#9679;</span> Oslo, NO</span>
                        <span style="font-size:.83rem;color:#64748b;display:flex;align-items:center;gap:.4rem;"><span style="color:#0d9488;font-size:.7rem;">&#9679;</span> Hamburg, DE</span>
                    </div>
                </div>

            </div>

            <!-- Bottom bar -->
            <div style="border-top:1px solid rgba(255,255,255,.06);padding-top:1.5rem;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:1rem;">
                <div style="font-size:.78rem;color:#334155;">
                    &copy; 2026 DriveNow. All rights reserved. &nbsp;&middot;&nbsp; CTEC2713N &nbsp;&middot;&nbsp; Niels Brock Copenhagen
                </div>
                <div style="display:flex;gap:1.25rem;">
                    <a href="#" onclick="openInfoModal('privacy');return false;" style="font-size:.78rem;color:#334155;text-decoration:none;cursor:pointer;">Privacy</a>
                    <a href="#" onclick="openInfoModal('terms');return false;" style="font-size:.78rem;color:#334155;text-decoration:none;cursor:pointer;">Terms</a>
                    <a href="#" onclick="openCookieSettings();return false;" style="font-size:.78rem;color:#334155;text-decoration:none;cursor:pointer;">Cookies</a>
                </div>
            </div>

        </div>
    </footer>

    <div class="overlay" id="m-login" role="dialog" aria-modal="true" aria-labelledby="lh">
        <div class="modal">
            <button type="button" class="modal-x" aria-label="Close login dialog" onclick="closeModal('m-login')">×</button>
            <div class="modal-logo">Drive<span>Now</span></div>
            <h2 class="modal-h" id="lh">Welcome back</h2>
            <p class="modal-p">Sign in to your DriveNow account</p>

            <asp:ValidationSummary ID="LoginValidationSummary" runat="server" CssClass="validation-summary" ValidationGroup="LoginGroup" DisplayMode="BulletList" />
            <asp:Label ID="LoginMessageLabel" runat="server" CssClass="form-message" EnableViewState="false" />

            <asp:Panel ID="pnlLoginPanel" runat="server" DefaultButton="LoginButton">
            <div class="field">
                <asp:Label ID="LoginEmailLabel" runat="server" AssociatedControlID="LoginEmailTextBox" Text="Email address" />
                <asp:TextBox ID="LoginEmailTextBox" runat="server" TextMode="Email" placeholder="you@example.com" autocomplete="email" />
                <asp:RequiredFieldValidator ID="LoginEmailRequiredValidator" runat="server" ControlToValidate="LoginEmailTextBox" ValidationGroup="LoginGroup" CssClass="validation-msg" ErrorMessage="Email address is required." Display="Dynamic" />
                <asp:RegularExpressionValidator ID="LoginEmailFormatValidator" runat="server" ControlToValidate="LoginEmailTextBox" ValidationGroup="LoginGroup" CssClass="validation-msg" ErrorMessage="Enter a valid email address." Display="Dynamic" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" />
            </div>

            <div class="field">
                <asp:Label ID="LoginPasswordLabel" runat="server" AssociatedControlID="LoginPasswordTextBox" Text="Password" />
                <asp:TextBox ID="LoginPasswordTextBox" runat="server" TextMode="Password" placeholder="Password" autocomplete="current-password" />
                <asp:RequiredFieldValidator ID="LoginPasswordRequiredValidator" runat="server" ControlToValidate="LoginPasswordTextBox" ValidationGroup="LoginGroup" CssClass="validation-msg" ErrorMessage="Password is required." Display="Dynamic" />
            </div>

            <asp:Button ID="LoginButton" runat="server" CssClass="form-btn" Text="Sign In" ValidationGroup="LoginGroup" OnClick="LoginButton_Click" />
            </asp:Panel>
            <p style="text-align:right;margin:-4px 0 8px;font-size:.8rem;">
                <a id="loginForgotLink" href="ForgotPassword.aspx?type=customer" style="color:#14b8a6;text-decoration:none;">Forgot password?</a>
            </p>
            <p class="modal-switch">No account? <a role="button" tabindex="0" onclick="switchModal('m-login','m-register')" onkeydown="linkKey(event, function(){ switchModal('m-login','m-register'); })">Create one</a></p>
        </div>
    </div>

    <div class="overlay" id="m-register" role="dialog" aria-modal="true" aria-labelledby="rh">
        <div class="modal">
            <button type="button" class="modal-x" aria-label="Close registration dialog" onclick="closeModal('m-register')">×</button>
            <div class="modal-logo">Drive<span>Now</span></div>
            <h2 class="modal-h" id="rh">Create account</h2>
            <p class="modal-p">Join DriveNow and start your journey today</p>

            <asp:ValidationSummary ID="RegisterValidationSummary" runat="server" CssClass="validation-summary" ValidationGroup="RegisterGroup" DisplayMode="BulletList" />
            <asp:Label ID="RegisterMessageLabel" runat="server" CssClass="form-message" EnableViewState="false" />

            <div class="field">
                <asp:Label ID="RegisterNameLabel" runat="server" AssociatedControlID="RegisterNameTextBox" Text="Full name" />
                <asp:TextBox ID="RegisterNameTextBox" runat="server" placeholder="First and last name" autocomplete="name" MaxLength="100" />
                <asp:RequiredFieldValidator ID="RegisterNameRequiredValidator" runat="server" ControlToValidate="RegisterNameTextBox" ValidationGroup="RegisterGroup" CssClass="validation-msg" ErrorMessage="Full name is required." Display="Dynamic" />
                <asp:RegularExpressionValidator ID="RegisterNameFormatValidator" runat="server" ControlToValidate="RegisterNameTextBox" ValidationGroup="RegisterGroup" CssClass="validation-msg" ErrorMessage="Please enter your first and last name (letters only, no numbers)." Display="Dynamic" ValidationExpression="^[a-zA-ZÀ-ÿ\s'\-\.]{3,}$" />
                <asp:CustomValidator ID="RegisterNameSpaceValidator" runat="server" ControlToValidate="RegisterNameTextBox" ValidationGroup="RegisterGroup" CssClass="validation-msg" ErrorMessage="Please enter both your first and last name." Display="Dynamic" ClientValidationFunction="validateNameHasSpace" />
            </div>

            <div class="field">
                <asp:Label ID="RegisterEmailLabel" runat="server" AssociatedControlID="RegisterEmailTextBox" Text="Email address" />
                <asp:TextBox ID="RegisterEmailTextBox" runat="server" TextMode="Email" placeholder="you@example.com" autocomplete="email" MaxLength="150" />
                <asp:RequiredFieldValidator ID="RegisterEmailRequiredValidator" runat="server" ControlToValidate="RegisterEmailTextBox" ValidationGroup="RegisterGroup" CssClass="validation-msg" ErrorMessage="Email address is required." Display="Dynamic" />
                <asp:RegularExpressionValidator ID="RegisterEmailFormatValidator" runat="server" ControlToValidate="RegisterEmailTextBox" ValidationGroup="RegisterGroup" CssClass="validation-msg" ErrorMessage="Enter a valid email address (e.g. name@example.com)." Display="Dynamic" ValidationExpression="^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$" />
            </div>

            <div class="field">
                <label class="dn-label">Phone Number <span style="color:#ef4444">*</span></label>
                <div style="display:flex;gap:.5rem;">
                    <select id="regPhoneCode" style="background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.12);border-radius:8px;padding:.6rem .5rem;color:#fff;font-size:.85rem;width:90px;flex-shrink:0;cursor:pointer;">
                        <option value="+45">+45</option>
                        <option value="+44">+44</option>
                        <option value="+1">+1</option>
                        <option value="+49">+49</option>
                        <option value="+33">+33</option>
                        <option value="+46">+46</option>
                        <option value="+47">+47</option>
                        <option value="+358">+358</option>
                        <option value="+31">+31</option>
                        <option value="+34">+34</option>
                        <option value="+39">+39</option>
                        <option value="+48">+48</option>
                        <option value="+91">+91</option>
                        <option value="+880">+880</option>
                        <option value="+92">+92</option>
                    </select>
                    <asp:TextBox ID="RegisterPhoneTextBox" runat="server" CssClass="dn-input" placeholder="70 00 00 00" autocomplete="tel" MaxLength="30" style="flex:1;" />
                </div>
                <asp:RequiredFieldValidator ID="RegisterPhoneRequiredValidator" runat="server" ControlToValidate="RegisterPhoneTextBox" ValidationGroup="RegisterGroup" CssClass="validation-msg" ErrorMessage="Phone number is required." Display="Dynamic" />
                <asp:RegularExpressionValidator ID="RegisterPhoneFormatValidator" runat="server" ControlToValidate="RegisterPhoneTextBox" ValidationGroup="RegisterGroup" CssClass="validation-msg" ErrorMessage="Phone number must contain only digits, spaces, +, - or brackets." Display="Dynamic" ValidationExpression="^[\d\s\+\-\(\)]{4,}$" />
            </div>

            <div class="field">
                <asp:Label ID="RegisterPasswordLabel" runat="server" AssociatedControlID="RegisterPasswordTextBox" Text="Password" />
                <asp:TextBox ID="RegisterPasswordTextBox" runat="server" TextMode="Password" placeholder="Min 8 chars, 1 uppercase, 1 number" autocomplete="new-password" />
                <asp:RequiredFieldValidator ID="RegisterPasswordRequiredValidator" runat="server" ControlToValidate="RegisterPasswordTextBox" ValidationGroup="RegisterGroup" CssClass="validation-msg" ErrorMessage="Password is required." Display="Dynamic" />
                <asp:RegularExpressionValidator ID="RegisterPasswordStrengthValidator" runat="server" ControlToValidate="RegisterPasswordTextBox" ValidationGroup="RegisterGroup" CssClass="validation-msg" ErrorMessage="Password must be at least 8 characters, include 1 uppercase letter and 1 number." Display="Dynamic" ValidationExpression="^(?=.*[A-Z])(?=.*\d).{8,}$" />
            </div>

            <div class="field">
                <asp:Label ID="RegisterConfirmPwLabel" runat="server" AssociatedControlID="RegisterConfirmPwTextBox" Text="Confirm password" />
                <asp:TextBox ID="RegisterConfirmPwTextBox" runat="server" TextMode="Password" placeholder="Re-enter your password" autocomplete="new-password" />
                <asp:RequiredFieldValidator ID="RegisterConfirmPwRequired" runat="server" ControlToValidate="RegisterConfirmPwTextBox" ValidationGroup="RegisterGroup" CssClass="validation-msg" ErrorMessage="Please confirm your password." Display="Dynamic" />
                <asp:CompareValidator ID="RegisterPasswordMatchValidator" runat="server" ControlToValidate="RegisterConfirmPwTextBox" ControlToCompare="RegisterPasswordTextBox" ValidationGroup="RegisterGroup" CssClass="validation-msg" ErrorMessage="Passwords do not match." Display="Dynamic" />
            </div>

            <asp:Button ID="RegisterButton" runat="server" CssClass="form-btn" Text="Create Account" ValidationGroup="RegisterGroup" OnClientClick="return confirmPrivacyConsentBeforeRegister();" OnClick="RegisterButton_Click" />
            <p class="modal-switch">Already a member? <a role="button" tabindex="0" onclick="switchModal('m-register','m-login')" onkeydown="linkKey(event, function(){ switchModal('m-register','m-login'); })">Sign in</a></p>
        </div>
    </div>

    <asp:HiddenField ID="PrivacyConsentHiddenField" runat="server" Value="false" />
    <asp:HiddenField ID="hfCustLoggedIn" runat="server" Value="0" />
    <asp:HiddenField ID="hfCustName"     runat="server" Value="" />

    <div class="overlay" id="m-privacy-consent" role="dialog" aria-modal="true" aria-labelledby="privacy-h">
        <div class="modal">
            <button type="button" class="modal-x" aria-label="Close privacy consent dialog" onclick="closeModal('m-privacy-consent')">×</button>
            <div class="modal-logo">Drive<span>Now</span></div>
            <h2 class="modal-h" id="privacy-h">Data privacy consent</h2>
            <p class="consent-text">
                To create your DriveNow account, we need your permission to store and use your personal information in line with GDPR and data privacy requirements.
            </p>
            <ul class="consent-list">
                <li>We store your name, email address, phone number, password, registration date, and account status.</li>
                <li>We use this data to create your account, manage your rentals, provide customer support, and keep your account secure.</li>
                <li>You may request access, correction, or deletion of your personal data, subject to legal and booking record requirements.</li>
            </ul>
            <label class="consent-check">
                <input type="checkbox" id="privacy-consent-checkbox" />
                <span>I understand and agree that DriveNow may store and process my personal data for account and rental services.</span>
            </label>
            <asp:Label ID="PrivacyConsentMessageLabel" runat="server" CssClass="form-message" EnableViewState="false" />
            <div class="consent-actions">
                <button type="button" class="btn btn-ghost-w" onclick="declinePrivacyConsent()">Decline</button>
                <button type="button" class="btn btn-teal" onclick="acceptPrivacyConsent()">Agree &amp; Create</button>
            </div>
        </div>
    </div>

    <!-- ═══════════════════════════════════════════════════
         INFO MODAL — FAQ / Contact / Service
    ═══════════════════════════════════════════════════ -->
    <div id="infoModal" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,.65);z-index:9995;align-items:center;justify-content:center;">
        <div style="background:#1a2332;border:1px solid rgba(255,255,255,.1);border-radius:18px;padding:2rem;max-width:540px;width:90%;max-height:80vh;overflow-y:auto;position:relative;">
            <button type="button" onclick="closeInfoModal()" aria-label="Close"
                style="position:absolute;top:1rem;right:1rem;background:rgba(255,255,255,.08);border:none;color:#fff;width:32px;height:32px;border-radius:50%;font-size:1.1rem;cursor:pointer;line-height:32px;text-align:center;">&#215;</button>
            <div id="infoModalContent"></div>
        </div>
    </div>

    <!-- ═══════════════════════════════════════════════════
         COOKIE CONSENT BANNER (GDPR)
    ═══════════════════════════════════════════════════ -->
    <div id="cookieBanner" style="display:none;position:fixed;bottom:0;left:0;right:0;z-index:9998;background:rgba(10,17,28,.97);border-top:1px solid rgba(255,255,255,.08);padding:1.1rem 2rem;backdrop-filter:blur(12px);">
        <div style="max-width:1280px;margin:0 auto;display:flex;align-items:center;justify-content:space-between;gap:1.5rem;flex-wrap:wrap;">
            <div style="flex:1;min-width:260px;">
                <div style="font-size:.88rem;font-weight:600;color:#fff;margin-bottom:.25rem;">We use cookies</div>
                <p style="font-size:.78rem;color:#64748b;line-height:1.5;margin:0;">
                    We and our third-party partners use cookies to improve your experience, analyse site traffic, personalise content, and serve targeted ads.
                    <a href="#" onclick="closeCookieBanner();openInfoModal('cookiepolicy');return false;" style="color:#0d9488;text-decoration:none;">Learn more</a>
                </p>
            </div>
            <div style="display:flex;gap:.75rem;flex-wrap:wrap;align-items:center;flex-shrink:0;">
                <button type="button" onclick="cookieDecline()"
                    style="background:transparent;border:1px solid rgba(255,255,255,.2);color:#94a3b8;padding:.45rem 1.1rem;border-radius:22px;font-size:.8rem;cursor:pointer;">
                    Decline
                </button>
                <button type="button" onclick="openCookieSettings()"
                    style="background:transparent;border:1px solid rgba(255,255,255,.2);color:#e2e8f0;padding:.45rem 1.1rem;border-radius:22px;font-size:.8rem;cursor:pointer;">
                    Manage Preferences
                </button>
                <button type="button" onclick="cookieAcceptAll()"
                    style="background:#0d9488;border:none;color:#fff;padding:.45rem 1.4rem;border-radius:22px;font-size:.8rem;font-weight:700;cursor:pointer;">
                    Agree to All
                </button>
            </div>
        </div>
    </div>

    <!-- Cookie preferences modal -->
    <div id="cookieSettingsModal" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,.6);z-index:10000;align-items:center;justify-content:center;">
        <div style="background:#1a2332;border:1px solid rgba(255,255,255,.1);border-radius:18px;padding:2rem;max-width:480px;width:90%;max-height:80vh;overflow-y:auto;">
            <h3 style="font-size:1rem;font-weight:700;color:#fff;margin-bottom:.5rem;">Cookie Preferences</h3>
            <p style="font-size:.8rem;color:#64748b;margin-bottom:1.25rem;line-height:1.6;">Choose which cookies you allow. Essential cookies are always on.</p>
            <div style="display:flex;flex-direction:column;gap:.9rem;margin-bottom:1.5rem;">
                <label style="display:flex;justify-content:space-between;align-items:center;font-size:.85rem;color:#e2e8f0;">
                    <span><strong>Essential</strong> — required for the site to work</span>
                    <input type="checkbox" checked disabled style="width:16px;height:16px;" />
                </label>
                <label style="display:flex;justify-content:space-between;align-items:center;font-size:.85rem;color:#e2e8f0;">
                    <span><strong>Analytics</strong> — help us understand usage</span>
                    <input type="checkbox" id="cookieAnalytics" style="width:16px;height:16px;" />
                </label>
                <label style="display:flex;justify-content:space-between;align-items:center;font-size:.85rem;color:#e2e8f0;">
                    <span><strong>Marketing</strong> — personalised ads &amp; offers</span>
                    <input type="checkbox" id="cookieMarketing" style="width:16px;height:16px;" />
                </label>
            </div>
            <div style="display:flex;gap:.75rem;justify-content:flex-end;">
                <button type="button" onclick="closeCookieSettings()"
                    style="background:transparent;border:1px solid rgba(255,255,255,.2);color:#94a3b8;padding:.5rem 1.2rem;border-radius:22px;font-size:.82rem;cursor:pointer;">
                    Cancel
                </button>
                <button type="button" onclick="saveCookiePrefs()"
                    style="background:#0d9488;border:none;color:#fff;padding:.5rem 1.4rem;border-radius:22px;font-size:.82rem;font-weight:700;cursor:pointer;">
                    Save Preferences
                </button>
            </div>
        </div>
    </div>

</form>

<script>
    // ── THEME TOGGLE ─────────────────────────────────────────────────────────
    // Restores saved preference from localStorage and applies it immediately.
    // toggleTheme() flips between "dark" (default) and "light" mode.
    (function () {
        // Read saved preference; default is dark if nothing stored yet
        var saved = localStorage.getItem('dn-theme') || 'dark';
        document.documentElement.setAttribute('data-theme', saved);
        // Update button label once the DOM is ready
        document.addEventListener('DOMContentLoaded', function () { updateThemeBtn(saved); });
    })();

    function toggleTheme() {
        var curr = document.documentElement.getAttribute('data-theme') || 'dark';
        var next = curr === 'dark' ? 'light' : 'dark';
        document.documentElement.setAttribute('data-theme', next);
        localStorage.setItem('dn-theme', next);
        updateThemeBtn(next);
    }

    // Updates the toggle button text to show what clicking it will switch TO
    function updateThemeBtn(theme) {
        var btn = document.getElementById('themeToggleBtn');
        if (!btn) return;
        if (theme === 'light') {
            btn.innerHTML = '&#127769;&#xFE0F; Dark';   // 🌙 Dark
            btn.title = 'Switch to dark mode';
        } else {
            btn.innerHTML = '&#9728;&#xFE0F; Light';    // ☀️ Light
            btn.title = 'Switch to light mode';
        }
    }
    // ─────────────────────────────────────────────────────────────────────────

    var navbar = document.getElementById('navbar');
    var lastFocused = null;
    var slides = document.querySelectorAll('.hero-slide');
    var dots = document.querySelectorAll('.dot');
    var cur = 0;
    var autoTmr;
    var consentSubmitPending = false;

    window.addEventListener('scroll', function () {
        navbar.classList.toggle('scrolled', window.scrollY > 50);
    });

    // Prepend country code to phone number before registration submit
    document.addEventListener('DOMContentLoaded', function() {
        var regBtn = document.getElementById('<%= RegisterButton.ClientID %>')
                  || document.querySelector('[id$="RegisterButton"]');
        if (regBtn) {
            regBtn.addEventListener('click', function() {
                var sel = document.getElementById('regPhoneCode');
                var ph  = document.querySelector('[id$="RegisterPhoneTextBox"]');
                if (sel && ph && ph.value && !ph.value.startsWith('+')) {
                    ph.value = sel.value + ' ' + ph.value.trim();
                }
            }, true);
        }
    });

    // Hero search — redirects to BrowseFleet with the search term in the URL
    function doHeroSearch() {
        var q = document.getElementById('heroSearch').value.trim();
        if (q.length > 0)
            window.location.href = 'BrowseFleet.aspx?search=' + encodeURIComponent(q);
        else
            window.location.href = 'BrowseFleet.aspx';
    }

    function toggleNav(button) {
        var nav = document.getElementById('mobile-nav');
        nav.classList.toggle('open');
        var open = nav.classList.contains('open');
        var trigger = button || document.querySelector('.hamburger');
        if (trigger) trigger.setAttribute('aria-expanded', open ? 'true' : 'false');
    }

    var slideLabels = ['Luxury &amp; Performance Cars', 'Sports &amp; Prestige Cars', 'Executive Sedans'];
    function goSlide(n) {
        slides[cur].classList.remove('active');
        dots[cur].classList.remove('active');
        cur = (n + slides.length) % slides.length;
        slides[cur].classList.add('active');
        dots[cur].classList.add('active');
        var lbl = document.getElementById('slideLabel');
        if (lbl) lbl.textContent = slideLabels[cur] || '';
    }

    function nextSlide() {
        clearInterval(autoTmr);
        goSlide(cur + 1);
        startAuto();
    }

    function prevSlide() {
        clearInterval(autoTmr);
        goSlide(cur - 1);
        startAuto();
    }

    function startAuto() {
        autoTmr = setInterval(function () { goSlide(cur + 1); }, 5000);
    }

    startAuto();

    function toggleAcc(header) {
        var item = header.parentElement;
        var isOpen = item.classList.contains('open');
        document.querySelectorAll('.acc-item').forEach(function (el) {
            el.classList.remove('open');
            var btn = el.querySelector('.acc-header');
            if (btn) btn.setAttribute('aria-expanded', 'false');
        });
        if (!isOpen) {
            item.classList.add('open');
            header.setAttribute('aria-expanded', 'true');
        }
    }

    function openModal(id) {
        var modal = document.getElementById(id);
        lastFocused = document.activeElement;
        modal.classList.add('open');
        document.body.style.overflow = 'hidden';

        setTimeout(function () {
            var focusTarget = modal.querySelector('input, button, [href], [tabindex]:not([tabindex="-1"])');
            if (focusTarget) focusTarget.focus();
        }, 30);
    }

    function closeModal(id) {
        var modal = document.getElementById(id);
        modal.classList.remove('open');
        document.body.style.overflow = '';
        if (lastFocused && typeof lastFocused.focus === 'function') {
            lastFocused.focus();
        }
    }

    function switchModal(a, b) {
        closeModal(a);
        setTimeout(function () { openModal(b); }, 220);
    }

    function linkKey(e, callback) {
        if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            callback();
        }
    }

    document.querySelectorAll('.overlay').forEach(function (ov) {
        ov.addEventListener('click', function (e) {
            if (e.target === ov) closeModal(ov.id);
        });
    });

    document.addEventListener('keydown', function (e) {
        var openOverlay = document.querySelector('.overlay.open');
        if (!openOverlay) return;

        if (e.key === 'Escape') {
            closeModal(openOverlay.id);
            return;
        }

        if (e.key !== 'Tab') return;

        var focusable = openOverlay.querySelectorAll('button, input, a[href], [tabindex]:not([tabindex="-1"])');
        if (!focusable.length) return;

        var first = focusable[0];
        var last = focusable[focusable.length - 1];

        if (e.shiftKey && document.activeElement === first) {
            e.preventDefault();
            last.focus();
        } else if (!e.shiftKey && document.activeElement === last) {
            e.preventDefault();
            first.focus();
        }
    });

    var ro = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
            if (entry.isIntersecting) {
                var d = parseInt(entry.target.dataset.d || '0', 10);
                setTimeout(function () { entry.target.classList.add('visible'); }, d);
                ro.unobserve(entry.target);
            }
        });
    }, { threshold: 0.12, rootMargin: '0px 0px -36px 0px' });

    document.querySelectorAll('.reveal').forEach(function (el, i) {
        el.dataset.d = (i % 4) * 75;
        ro.observe(el);
    });

    function animateCount(el) {
        var target = parseInt(el.dataset.target, 10);
        var suffix = el.dataset.suffix || '';
        var dur = 1800;
        var start = performance.now();

        function tick(now) {
            var p = Math.min((now - start) / dur, 1);
            var eased = 1 - Math.pow(1 - p, 3);
            el.textContent = Math.floor(eased * target) + suffix;
            if (p < 1) requestAnimationFrame(tick);
            else el.textContent = target + suffix;
        }

        requestAnimationFrame(tick);
    }

    var co = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
            if (entry.isIntersecting) {
                animateCount(entry.target);
                co.unobserve(entry.target);
            }
        });
    }, { threshold: 0.5 });

    document.querySelectorAll('.stat-num').forEach(function (el) { co.observe(el); });

    // CustomValidator client-side function: name must contain a space (first + last)
    function validateNameHasSpace(sender, args) {
        args.IsValid = args.Value.trim().indexOf(' ') !== -1;
    }

    function confirmPrivacyConsentBeforeRegister() {
        var hidden = document.getElementById('<%= PrivacyConsentHiddenField.ClientID %>');

        if (hidden && hidden.value === 'true') {
            return true;
        }

        if (typeof Page_ClientValidate === 'function' && !Page_ClientValidate('RegisterGroup')) {
            return false;
        }

        consentSubmitPending = true;
        openModal('m-privacy-consent');
        return false;
    }

    function acceptPrivacyConsent() {
        var checkbox = document.getElementById('privacy-consent-checkbox');
        var hidden = document.getElementById('<%= PrivacyConsentHiddenField.ClientID %>');
    var message = document.getElementById('<%= PrivacyConsentMessageLabel.ClientID %>');

    if (!checkbox || !checkbox.checked) {
        if (message) message.textContent = 'Please tick the consent box before creating the account.';
        return;
    }

    if (hidden) hidden.value = 'true';
    closeModal('m-privacy-consent');

    if (consentSubmitPending) {
        consentSubmitPending = false;
        document.getElementById('<%= RegisterButton.ClientID %>').click();
    }
}

function declinePrivacyConsent() {
    var hidden = document.getElementById('<%= PrivacyConsentHiddenField.ClientID %>');
        var checkbox = document.getElementById('privacy-consent-checkbox');

        if (hidden) hidden.value = 'false';
        if (checkbox) checkbox.checked = false;
        consentSubmitPending = false;
        closeModal('m-privacy-consent');
    }

    // ── Language menu ──────────────────────────────────
    var currentLang = 'EN';

    var LANG_DATA = {
        EN: {
            navHome:'Home', navAbout:'About Us', navFleet:'Our Fleet', navHow:'How It Works', navContact:'Contact',
            heroTitle:'Your Journey,<br />Your DriveNow',
            heroSub:'Experience elegance, performance, and style with our handpicked premium vehicle fleet.',
            heroCta:'Browse Our Fleet',
            featLabel:'Featured Selection', featTitle:'Handpicked Luxury Vehicles',
            featSub:'Explore our curated collection of premium vehicles available for immediate booking.',
            featBrowse:'Browse Complete Fleet',
            statCust:'Happy Customers', statVeh:'Premium Vehicles', statTypes:'Service Types', statSupport:'Customer Support',
            aboutLabel:'About Us',
            aboutTitle:'Elite Car Rentals with Refined<br />Service &amp; Unmatched Class',
            aboutH3:'Delivering Sophistication on Every Ride',
            aboutP:'At DriveNow, we offer more than just vehicles. We deliver sophistication on wheels. Every hire blends premium quality, precision performance, and attentive service.',
            aboutBtn:'Get Started',
            whyLabel:'Why Choose Us', whyTitle:'Redefining Luxury Mobility with Distinction',
            hiwLabel:'How It Works', hiwTitle:'Luxury Rentals Made Effortless',
            ctaTitle:'Ready to hit the road?',
            ctaSub:'Join hundreds of satisfied customers who trust DriveNow for every journey.',
            ctaCreate:'Create Free Account', ctaSignIn:'Sign In',
            loginH:'Welcome back', loginP:'Sign in to your DriveNow account',
            loginEmail:'Email address', loginPw:'Password', loginBtn:'Sign In',
            loginNoAcc:'No account?', loginCreate:'Create one', loginForgot:'Forgot password?',
            regH:'Create account', regP:'Join DriveNow and start your journey today',
            regName:'Full name', regEmail:'Email address', regPhone:'Phone number', regPw:'Password',
            regBtn:'Create Account', regHave:'Already a member?', regSignIn:'Sign in'
        },
        DA: {
            navHome:'Hjem', navAbout:'Om Os', navFleet:'Vores Flåde', navHow:'Sådan Fungerer Det', navContact:'Kontakt',
            heroTitle:'Din Rejse,<br />Dit DriveNow',
            heroSub:'Oplev elegance, præstation og stil med vores håndplukkede premium køretøjsflåde.',
            heroCta:'Se Vores Flåde',
            featLabel:'Udvalgte Biler', featTitle:'Håndplukkede Luksusbiler',
            featSub:'Udforsk vores kuraterede samling af premium køretøjer til øjeblikkelig booking.',
            featBrowse:'Se Hele Flåden',
            statCust:'Glade Kunder', statVeh:'Premium Køretøjer', statTypes:'Servicetyper', statSupport:'Kundesupport',
            aboutLabel:'Om Os',
            aboutTitle:'Elite Biludlejning med Raffineret<br />Service &amp; Uovertruffen Klasse',
            aboutH3:'Sofistikering på Hver Tur',
            aboutP:'Hos DriveNow tilbyder vi mere end bare køretøjer. Vi leverer sofistikering på hjul. Hver leje kombinerer premium kvalitet, præcision og opmærksom service.',
            aboutBtn:'Kom I Gang',
            whyLabel:'Hvorfor Vælge Os', whyTitle:'Nydefinerer Luksusmobilitet med Distinction',
            hiwLabel:'Sådan Fungerer Det', hiwTitle:'Luksusudlejning Gjort Nemt',
            ctaTitle:'Klar til at køre?',
            ctaSub:'Bliv en af hundredvis af tilfredse kunder, der stoler på DriveNow.',
            ctaCreate:'Opret Gratis Konto', ctaSignIn:'Log Ind',
            loginH:'Velkommen tilbage', loginP:'Log ind på din DriveNow-konto',
            loginEmail:'E-mailadresse', loginPw:'Adgangskode', loginBtn:'Log Ind',
            loginNoAcc:'Intet konto?', loginCreate:'Opret en', loginForgot:'Glemt adgangskode?',
            regH:'Opret konto', regP:'Bliv medlem af DriveNow og start din rejse i dag',
            regName:'Fulde navn', regEmail:'E-mailadresse', regPhone:'Telefonnummer', regPw:'Adgangskode',
            regBtn:'Opret Konto', regHave:'Allerede medlem?', regSignIn:'Log ind'
        },
        DE: {
            navHome:'Startseite', navAbout:'Über Uns', navFleet:'Unsere Flotte', navHow:'Wie Es Funktioniert', navContact:'Kontakt',
            heroTitle:'Ihre Reise,<br />Ihr DriveNow',
            heroSub:'Erleben Sie Eleganz, Leistung und Stil mit unserer handverlesenen Premiumflotte.',
            heroCta:'Flotte Entdecken',
            featLabel:'Ausgewählte Fahrzeuge', featTitle:'Handverlesene Luxusfahrzeuge',
            featSub:'Entdecken Sie unsere kuratierte Sammlung von Premiumfahrzeugen für sofortige Buchung.',
            featBrowse:'Gesamte Flotte Entdecken',
            statCust:'Zufriedene Kunden', statVeh:'Premium Fahrzeuge', statTypes:'Servicearten', statSupport:'Kundensupport',
            aboutLabel:'Über Uns',
            aboutTitle:'Exklusive Fahrzeugvermietung mit Raffiniertem<br />Service &amp; Unübertroffener Klasse',
            aboutH3:'Raffinesse bei Jeder Fahrt',
            aboutP:'Bei DriveNow bieten wir mehr als nur Fahrzeuge. Wir liefern Raffinesse auf Rädern. Jede Miete verbindet Premiumqualität, Präzision und aufmerksamen Service.',
            aboutBtn:'Loslegen',
            whyLabel:'Warum Wir', whyTitle:'Luxusmobilität mit Unterschied Neu Definieren',
            hiwLabel:'Wie Es Funktioniert', hiwTitle:'Luxusmiete Leicht Gemacht',
            ctaTitle:'Bereit für die Fahrt?',
            ctaSub:'Schließen Sie sich Hunderten zufriedener Kunden an, die DriveNow vertrauen.',
            ctaCreate:'Kostenloses Konto Erstellen', ctaSignIn:'Anmelden',
            loginH:'Willkommen zurück', loginP:'Melden Sie sich bei Ihrem DriveNow-Konto an',
            loginEmail:'E-Mail-Adresse', loginPw:'Passwort', loginBtn:'Anmelden',
            loginNoAcc:'Kein Konto?', loginCreate:'Erstellen', loginForgot:'Passwort vergessen?',
            regH:'Konto erstellen', regP:'Treten Sie DriveNow bei und starten Sie Ihre Reise',
            regName:'Vollständiger Name', regEmail:'E-Mail-Adresse', regPhone:'Telefonnummer', regPw:'Passwort',
            regBtn:'Konto Erstellen', regHave:'Bereits Mitglied?', regSignIn:'Anmelden'
        },
        FR: {
            navHome:'Accueil', navAbout:'À Propos', navFleet:'Notre Flotte', navHow:'Comment Ça Marche', navContact:'Contact',
            heroTitle:'Votre Voyage,<br />Votre DriveNow',
            heroSub:"Découvrez l'élégance, les performances et le style avec notre flotte premium sélectionnée.",
            heroCta:'Parcourir Notre Flotte',
            featLabel:'Sélection Vedette', featTitle:'Véhicules de Luxe Sélectionnés',
            featSub:'Explorez notre collection de véhicules premium disponibles pour réservation immédiate.',
            featBrowse:'Parcourir la Flotte',
            statCust:'Clients Satisfaits', statVeh:'Véhicules Premium', statTypes:'Types de Service', statSupport:'Support Client',
            aboutLabel:'À Propos',
            aboutTitle:'Location de Luxe avec Service Raffiné<br />&amp; Classe Inégalée',
            aboutH3:'Sophistication à Chaque Trajet',
            aboutP:"Chez DriveNow, nous offrons plus que des véhicules. Nous livrons de la sophistication sur roues. Chaque location allie qualité premium, performance de précision et service attentionné.",
            aboutBtn:'Commencer',
            whyLabel:'Pourquoi Nous Choisir', whyTitle:'Redéfinir la Mobilité de Luxe avec Distinction',
            hiwLabel:'Comment Ça Marche', hiwTitle:'Location de Luxe Simplifiée',
            ctaTitle:'Prêt à prendre la route ?',
            ctaSub:'Rejoignez des centaines de clients satisfaits qui font confiance à DriveNow.',
            ctaCreate:'Créer un Compte Gratuit', ctaSignIn:'Se Connecter',
            loginH:'Bon retour', loginP:'Connectez-vous à votre compte DriveNow',
            loginEmail:'Adresse e-mail', loginPw:'Mot de passe', loginBtn:'Se Connecter',
            loginNoAcc:'Pas de compte ?', loginCreate:'Créer un', loginForgot:'Mot de passe oublié ?',
            regH:'Créer un compte', regP:'Rejoignez DriveNow et commencez votre voyage',
            regName:'Nom complet', regEmail:'Adresse e-mail', regPhone:'Numéro de téléphone', regPw:'Mot de passe',
            regBtn:'Créer un Compte', regHave:'Déjà membre ?', regSignIn:'Se connecter'
        },
        SV: {
            navHome:'Hem', navAbout:'Om Oss', navFleet:'Vår Flotta', navHow:'Hur Det Fungerar', navContact:'Kontakt',
            heroTitle:'Din Resa,<br />Ditt DriveNow',
            heroSub:'Upplev elegans, prestanda och stil med vår handplockade premiumflotta.',
            heroCta:'Bläddra Vår Flotta',
            featLabel:'Utvalt Urval', featTitle:'Handplockade Lyxfordon',
            featSub:'Utforska vår kurerade samling av premiumfordon tillgängliga för omedelbar bokning.',
            featBrowse:'Bläddra Hela Flottan',
            statCust:'Nöjda Kunder', statVeh:'Premiumfordon', statTypes:'Tjänstetyper', statSupport:'Kundsupport',
            aboutLabel:'Om Oss',
            aboutTitle:'Premiumhyrbilar med Förfinad<br />Service &amp; Oöverträffad Klass',
            aboutH3:'Sofistikering på Varje Resa',
            aboutP:'Hos DriveNow erbjuder vi mer än bara fordon. Vi levererar sofistikering på hjul. Varje hyra kombinerar premiumkvalitet, precisionsprestanda och uppmärksam service.',
            aboutBtn:'Kom Igång',
            whyLabel:'Varför Oss', whyTitle:'Omdefiniera Lyxmobilitet med Distinktion',
            hiwLabel:'Hur Det Fungerar', hiwTitle:'Lyxuthyrning Gjord Enkel',
            ctaTitle:'Redo att ta vägen?',
            ctaSub:'Gå med hundratals nöjda kunder som litar på DriveNow.',
            ctaCreate:'Skapa Gratis Konto', ctaSignIn:'Logga In',
            loginH:'Välkommen tillbaka', loginP:'Logga in på ditt DriveNow-konto',
            loginEmail:'E-postadress', loginPw:'Lösenord', loginBtn:'Logga In',
            loginNoAcc:'Inget konto?', loginCreate:'Skapa ett', loginForgot:'Glömt lösenord?',
            regH:'Skapa konto', regP:'Gå med i DriveNow och börja din resa idag',
            regName:'Fullt namn', regEmail:'E-postadress', regPhone:'Telefonnummer', regPw:'Lösenord',
            regBtn:'Skapa Konto', regHave:'Redan medlem?', regSignIn:'Logga in'
        }
    };

    function toggleLangMenu() {
        var d = document.getElementById('langDropdown');
        var a = document.getElementById('assistDropdown');
        if (a) a.style.display = 'none';
        d.style.display = d.style.display === 'none' ? 'block' : 'none';
    }

    function setLang(code, label) {
        currentLang = code;
        document.getElementById('langDropdown').style.display = 'none';
        var btn = document.getElementById('langBtn');
        if (btn) btn.innerHTML = code + ' &#9662;';

        var t = LANG_DATA[code] || LANG_DATA['EN'];

        // Helper: set textContent safely
        function txt(sel, v) { var el = document.querySelector(sel); if (el && v !== undefined) el.textContent = v; }
        // Helper: set innerHTML safely (for elements with embedded HTML like <br>)
        function htm(sel, v) { var el = document.querySelector(sel); if (el && v !== undefined) el.innerHTML = v; }
        // Helper: set input value (for <input type="submit"> buttons)
        function inp(sel, v) { var el = document.querySelector(sel); if (el && v !== undefined) el.value = v; }

        // ── Navigation links ──────────────────────────────
        var navLinks = document.querySelectorAll('.nav-links a');
        if (navLinks[0]) navLinks[0].textContent = t.navHome;
        if (navLinks[2]) navLinks[2].textContent = t.navContact;

        // ── Hero section ──────────────────────────────────
        htm('.hero-title', t.heroTitle);
        txt('.hero-sub',   t.heroSub);
        txt('.hero-content .btn', t.heroCta);

        // ── Featured Fleet section ────────────────────────
        txt('#featured-fleet .sec-label',  t.featLabel);
        txt('#featured-fleet .sec-title',  t.featTitle);
        txt('#featured-fleet p',           t.featSub);
        txt('#featured-fleet .btn',        t.featBrowse);

        // ── Stats strip ───────────────────────────────────
        var statLbls = document.querySelectorAll('.stat-lbl');
        if (statLbls[0]) statLbls[0].textContent = t.statCust;
        if (statLbls[1]) statLbls[1].textContent = t.statVeh;
        if (statLbls[2]) statLbls[2].textContent = t.statTypes;
        if (statLbls[3]) statLbls[3].textContent = t.statSupport;

        // ── About section ─────────────────────────────────
        txt('#about .sec-label',        t.aboutLabel);
        htm('#about .sec-title',        t.aboutTitle);
        txt('#about h3',                t.aboutH3);
        var aboutPs = document.querySelectorAll('#about .about-text p');
        if (aboutPs[0]) aboutPs[0].textContent = t.aboutP;
        txt('#about .about-text button', t.aboutBtn);

        // ── Why Choose Us section ─────────────────────────
        txt('#why .sec-label', t.whyLabel);
        txt('#why .sec-title', t.whyTitle);

        // ── How It Works section ──────────────────────────
        txt('#how-it-works .sec-label', t.hiwLabel);
        txt('#how-it-works .sec-title', t.hiwTitle);

        // ── CTA section ───────────────────────────────────
        txt('.cta-title', t.ctaTitle);
        txt('.cta-sub',   t.ctaSub);
        var ctaBtns = document.querySelectorAll('.cta-actions button');
        if (ctaBtns[0]) ctaBtns[0].textContent = t.ctaCreate;
        if (ctaBtns[1]) ctaBtns[1].textContent = t.ctaSignIn;

        // ── Login modal ───────────────────────────────────
        txt('#m-login .modal-h', t.loginH);
        txt('#m-login .modal-p', t.loginP);
        var loginLabels = document.querySelectorAll('#m-login .field label');
        if (loginLabels[0]) loginLabels[0].textContent = t.loginEmail;
        if (loginLabels[1]) loginLabels[1].textContent = t.loginPw;
        inp('#m-login input.form-btn', t.loginBtn);
        var loginSwitch = document.querySelector('#m-login .modal-switch');
        if (loginSwitch) {
            if (loginSwitch.childNodes[0]) loginSwitch.childNodes[0].textContent = t.loginNoAcc + ' ';
            var lnkCreate = loginSwitch.querySelector('a');
            if (lnkCreate) lnkCreate.textContent = t.loginCreate;
        }
        var forgotEl = document.getElementById('loginForgotLink');
        if (forgotEl) forgotEl.textContent = t.loginForgot;

        // ── Register modal ────────────────────────────────
        txt('#m-register .modal-h', t.regH);
        txt('#m-register .modal-p', t.regP);
        var regLabels = document.querySelectorAll('#m-register .field label');
        if (regLabels[0]) regLabels[0].textContent = t.regName;
        if (regLabels[1]) regLabels[1].textContent = t.regEmail;
        if (regLabels[2]) regLabels[2].textContent = t.regPhone;
        if (regLabels[3]) regLabels[3].textContent = t.regPw;
        inp('#m-register input.form-btn', t.regBtn);
        var regSwitch = document.querySelector('#m-register .modal-switch');
        if (regSwitch) {
            if (regSwitch.childNodes[0]) regSwitch.childNodes[0].textContent = t.regHave + ' ';
            var lnkSignIn = regSwitch.querySelector('a');
            if (lnkSignIn) lnkSignIn.textContent = t.regSignIn;
        }
    }

    // ── Assist / Help menu ─────────────────────────────
    function toggleAssistMenu() {
        var d = document.getElementById('assistDropdown');
        var l = document.getElementById('langDropdown');
        if (l) l.style.display = 'none';
        d.style.display = d.style.display === 'none' ? 'block' : 'none';
    }
    function closeAllMenus() {
        var l = document.getElementById('langDropdown');
        var a = document.getElementById('assistDropdown');
        if (l) l.style.display = 'none';
        if (a) a.style.display = 'none';
    }
    // Close menus on outside click
    document.addEventListener('click', function(e) {
        if (!e.target.closest || (!e.target.closest('[onclick="toggleLangMenu()"]') && !e.target.closest('#langDropdown')))
            { var l = document.getElementById('langDropdown'); if(l) l.style.display='none'; }
        if (!e.target.closest || (!e.target.closest('[onclick="toggleAssistMenu()"]') && !e.target.closest('#assistDropdown')))
            { var a = document.getElementById('assistDropdown'); if(a) a.style.display='none'; }
    });

    // ── Cookie consent ─────────────────────────────────
    // Consent is stored in sessionStorage (cleared when browser closes),
    // so the banner appears fresh on every new visit / browser open.
    function cookieAcceptAll() {
        sessionStorage.setItem('dn_cookie_consent', 'all');
        document.getElementById('cookieBanner').style.display = 'none';
    }
    function cookieDecline() {
        sessionStorage.setItem('dn_cookie_consent', 'essential');
        document.getElementById('cookieBanner').style.display = 'none';
    }
    function closeCookieBanner() {
        document.getElementById('cookieBanner').style.display = 'none';
    }
    function openCookieSettings() {
        document.getElementById('cookieBanner').style.display = 'none';
        document.getElementById('cookieSettingsModal').style.display = 'flex';
    }
    function closeCookieSettings() {
        document.getElementById('cookieSettingsModal').style.display = 'none';
    }
    function saveCookiePrefs() {
        var analytics = document.getElementById('cookieAnalytics').checked;
        var marketing = document.getElementById('cookieMarketing').checked;
        var val = 'essential' + (analytics ? '+analytics' : '') + (marketing ? '+marketing' : '');
        sessionStorage.setItem('dn_cookie_consent', val);
        document.getElementById('cookieSettingsModal').style.display = 'none';
    }
    // Show cookie banner unless the user has already responded in this browser session.
    // sessionStorage is cleared when the browser/tab is closed, so the banner
    // reappears every time the site is opened fresh.
    (function() {
        var hasConsent = sessionStorage.getItem('dn_cookie_consent') !== null;
        if (!hasConsent) {
            setTimeout(function() {
                document.getElementById('cookieBanner').style.display = 'block';
            }, 1200);
        }
    })();

    // ── Info modal (FAQ / Contact / Service) ──────────
    var INFO_CONTENT = {
        faq: '<h3 style="font-size:1.1rem;font-weight:700;color:#fff;margin-bottom:1.2rem;">Frequently Asked Questions</h3>' +
             '<div style="display:flex;flex-direction:column;gap:1rem;">' +
             faqItem('How do I book a vehicle?', 'Create a free account, browse our fleet on the Our Fleet page, select a vehicle and click Book Now. Follow the 3-step booking process.') +
             faqItem('What documents do I need?', 'A valid driving licence, passport or national ID, and a payment method. International licences are accepted.') +
             faqItem('Can I cancel my booking?', 'Yes. Cancellations made 24+ hours before pickup are free. Same-day cancellations may incur a small fee.') +
             faqItem('Is insurance included?', 'Basic third-party insurance is included. Optional full-cover upgrade is available at checkout.') +
             faqItem('What is the minimum age?', 'Drivers must be at least 21 years old and hold a valid licence for 2+ years.') +
             faqItem('Do you offer airport pickups?', 'Yes. Select "Airport Transfer" as your service type and enter the airport and flight details.') +
             faqItem('How do I become a contributor?', 'Click "Apply as Contributor" on our homepage or navigate to the Contributor section. Approval takes 3 business days.') +
             '</div>',
        contact: '<h3 style="font-size:1.1rem;font-weight:700;color:#fff;margin-bottom:1.2rem;">Contact DriveNow</h3>' +
                 '<div style="display:flex;flex-direction:column;gap:.9rem;">' +
                 contactRow('', 'Denmark (main)', '+45 70 10 20 30') +
                 contactRow('', 'United Kingdom', '+44 20 7946 0958') +
                 contactRow('', 'Germany', '+49 30 1234 5678') +
                 contactRow('', 'Sweden / Norway', '+46 8 123 456 78') +
                 contactRow('&#9993;', 'General enquiries', 'support@drivenow.dk') +
                 contactRow('&#9993;', 'Partnerships', 'partners@drivenow.dk') +
                 contactRow('', 'Head office', 'Niels Brock, Copenhagen, Denmark') +
                 contactRow('', 'Opening hours', 'Mon–Fri 08:00–20:00 · Sat–Sun 09:00–17:00') +
                 '</div>',
        service: '<h3 style="font-size:1.1rem;font-weight:700;color:#fff;margin-bottom:1.2rem;">Customer Service</h3>' +
                 '<p style="font-size:.88rem;color:#94a3b8;margin-bottom:1.2rem;">Our team is here to help with bookings, changes, and any questions about your DriveNow experience.</p>' +
                 '<div style="display:flex;flex-direction:column;gap:.9rem;">' +
                 contactRow('', '24/7 urgent support', '+45 70 10 20 30') +
                 contactRow('&#9993;', 'Email support', 'support@drivenow.dk') +
                 contactRow('', 'Average response', 'Within 2 hours') +
                 '</div>' +
                 '<div style="background:rgba(13,148,136,.15);border:1px solid rgba(13,148,136,.3);border-radius:10px;padding:1rem;margin-top:1.2rem;font-size:.83rem;color:#5eead4;">' +
                 'For booking changes, please have your booking reference number ready.' +
                 '</div>',

        privacy: '<h3 style="font-size:1.1rem;font-weight:700;color:#fff;margin-bottom:.4rem;">Privacy Policy</h3>' +
                 '<p style="font-size:.72rem;color:#64748b;margin-bottom:1.2rem;">Last updated: January 2026 &nbsp;&middot;&nbsp; DriveNow ApS, Copenhagen, Denmark</p>' +
                 legalSection('1. Who We Are',
                     'DriveNow ApS ("DriveNow", "we", "us") operates the vehicle hire and chauffeured journey platform at drivenow.dk. We are registered in Denmark and subject to EU GDPR regulation.') +
                 legalSection('2. What Data We Collect',
                     'We collect: (a) <strong style="color:#e2e8f0;">Account data</strong> — name, email address, phone number, and password (stored as a salted hash). ' +
                     '(b) <strong style="color:#e2e8f0;">Booking data</strong> — pickup/drop-off locations, dates, vehicle choices, insurance selections, and payment reference numbers. ' +
                     '(c) <strong style="color:#e2e8f0;">Usage data</strong> — pages visited, session duration, and browser type (via essential cookies only). ' +
                     'We do <strong style="color:#f87171;">not</strong> store full card numbers; payment processing is handled by our payment partner.') +
                 legalSection('3. Why We Use Your Data',
                     'Your data is used to: process and manage your bookings; send booking confirmations and receipts; respond to your support requests; comply with legal obligations; and (with your consent) send promotional offers. ' +
                     'Legal basis: GDPR Article 6(1)(b) — contract performance; Article 6(1)(c) — legal obligation; Article 6(1)(a) — consent for marketing.') +
                 legalSection('4. Who We Share Data With',
                     'We share data only as necessary: with drivers assigned to your booking (name and pickup location only); with our payment processor; and with authorities where required by law. ' +
                     'We do not sell your data to third parties.') +
                 legalSection('5. How Long We Keep Your Data',
                     'Active account data is kept while your account exists. Booking records are retained for 7 years for legal and tax purposes. Unsuccessful contributor applications are deleted after 12 months.') +
                 legalSection('6. Your Rights',
                     'Under GDPR you have the right to: access your data; correct inaccurate data; delete your data ("right to be forgotten"); restrict processing; data portability; and object to processing. ' +
                     'To exercise any right, email <strong style="color:#5eead4;">privacy@drivenow.dk</strong>. We will respond within 30 days.') +
                 legalSection('7. Contact',
                     'Data Controller: DriveNow ApS · Danasvej 3, 1910 Frederiksberg, Denmark · privacy@drivenow.dk'),

        terms: '<h3 style="font-size:1.1rem;font-weight:700;color:#fff;margin-bottom:.4rem;">Terms &amp; Conditions</h3>' +
               '<p style="font-size:.72rem;color:#64748b;margin-bottom:1.2rem;">Last updated: January 2026 &nbsp;&middot;&nbsp; Please read carefully before using DriveNow.</p>' +
               legalSection('1. Acceptance',
                   'By creating an account or making a booking, you agree to these Terms & Conditions. If you do not agree, please do not use our services.') +
               legalSection('2. Eligibility',
                   'You must be at least 18 years old to create an account. Drivers must be 21+ with a valid licence held for 2+ years. You are responsible for ensuring all information you provide is accurate and up to date.') +
               legalSection('3. Bookings',
                   'All bookings are subject to vehicle availability. A booking is confirmed only once you receive a confirmation email with a booking reference. DriveNow reserves the right to cancel bookings in exceptional circumstances (e.g. vehicle damage) with a full refund.') +
               legalSection('4. Cancellations & Refunds',
                   'Cancellations made 24+ hours before the scheduled pickup are free of charge. Cancellations within 24 hours may incur a fee of up to 50% of the booking value. No-shows are non-refundable. Refunds are processed within 5–10 business days.') +
               legalSection('5. Vehicle Use',
                   'Vehicles must be used lawfully and returned in the same condition as collected. You are liable for any damage beyond normal wear and tear. Smoking, pets (without prior arrangement), and off-road use are prohibited unless explicitly permitted.') +
               legalSection('6. Insurance',
                   'All bookings include basic third-party insurance. Additional cover options are available at checkout. DriveNow is not liable for personal belongings left in vehicles.') +
               legalSection('7. Contributor Programme',
                   'Contributors (vehicle owners and drivers) agree to separate Contributor Terms provided at the time of application. DriveNow acts as an intermediary and does not guarantee earnings.') +
               legalSection('8. Governing Law',
                   'These terms are governed by Danish law. Any disputes shall be resolved in the courts of Copenhagen, Denmark.') +
               legalSection('9. Contact',
                   'Questions about these terms? Email <strong style="color:#5eead4;">legal@drivenow.dk</strong>'),

        cookiepolicy: '<h3 style="font-size:1.1rem;font-weight:700;color:#fff;margin-bottom:.4rem;">Cookie Policy</h3>' +
                      '<p style="font-size:.72rem;color:#64748b;margin-bottom:1.2rem;">Last updated: January 2026 &nbsp;&middot;&nbsp; This policy explains how DriveNow uses cookies.</p>' +
                      legalSection('What Are Cookies?',
                          'Cookies are small text files placed on your device when you visit a website. They help us remember your preferences and understand how you use our site.') +
                      legalSection('Essential Cookies (Always Active)',
                          'These cookies are required for the site to function and cannot be turned off. They include: <strong style="color:#e2e8f0;">session cookies</strong> — keep you logged in during your visit; <strong style="color:#e2e8f0;">security tokens</strong> — protect against cross-site request forgery; <strong style="color:#e2e8f0;">cookie consent state</strong> — remembers your cookie preference.') +
                      legalSection('Analytics Cookies (Optional)',
                          'These help us understand how visitors use our site — which pages are popular, how long sessions last, and where users come from. Data is anonymised. You can opt out at any time via Cookie Preferences.') +
                      legalSection('Marketing Cookies (Optional)',
                          'These allow us to show you relevant promotions and measure ad effectiveness. We do not share marketing cookie data with third parties for resale. You can opt out at any time.') +
                      legalSection('How to Manage Cookies',
                          'You can change your preferences at any time using the <strong style="color:#14b8a6;">Cookie Preferences</strong> link in the footer. You can also delete cookies through your browser settings, though this may affect site functionality.') +
                      legalSection('Contact',
                          'Cookie queries: <strong style="color:#5eead4;">privacy@drivenow.dk</strong>'),

        gdpr: '<h3 style="font-size:1.1rem;font-weight:700;color:#fff;margin-bottom:.4rem;">GDPR &amp; Your Data Rights</h3>' +
              '<p style="font-size:.72rem;color:#64748b;margin-bottom:1.2rem;">Your rights under the General Data Protection Regulation (EU) 2016/679</p>' +
              '<div style="background:rgba(13,148,136,.1);border:1px solid rgba(13,148,136,.25);border-radius:10px;padding:1rem 1.2rem;margin-bottom:1.2rem;font-size:.83rem;color:#5eead4;line-height:1.6;">' +
              'DriveNow is committed to protecting your personal data. You have strong rights under GDPR, and we make exercising them easy.' +
              '</div>' +
              legalSection('&#128065; Right of Access',
                  'You have the right to request a copy of all personal data we hold about you. We will provide this within 30 days, free of charge, in a readable format.') +
              legalSection('&#9998; Right to Rectification',
                  'If any data we hold is inaccurate or incomplete, you have the right to have it corrected. You can update most information directly in your account settings.') +
              legalSection('&#128465; Right to Erasure ("Right to be Forgotten")',
                  'You can ask us to delete your personal data. We will comply unless we are legally required to retain it (e.g. booking records for tax purposes, retained for 7 years).') +
              legalSection('&#9203; Right to Restrict Processing',
                  'You can ask us to pause how we use your data while a complaint is being investigated, or if you dispute its accuracy.') +
              legalSection('&#128228; Right to Data Portability',
                  'You have the right to receive your data in a structured, machine-readable format (e.g. JSON or CSV) and transfer it to another service.') +
              legalSection('&#128683; Right to Object',
                  'You can object to processing based on legitimate interests or direct marketing at any time. Marketing objections are actioned immediately.') +
              legalSection('&#128274; Right to Withdraw Consent',
                  'Where processing is based on your consent, you can withdraw it at any time. This does not affect processing that already took place.') +
              legalSection('How to Exercise Your Rights',
                  'Email <strong style="color:#5eead4;">privacy@drivenow.dk</strong> with the subject line "GDPR Request" and describe what you would like us to do. We respond within 30 days. ' +
                  'You also have the right to lodge a complaint with the Danish Data Protection Authority (Datatilsynet) at <strong style="color:#5eead4;">dt.dk</strong>.'),

        travelguide: '<h3 style="font-size:1.1rem;font-weight:700;color:#fff;margin-bottom:1rem;">Travel Guide</h3>' +
                     '<div style="background:rgba(20,184,166,.07);border:1px solid rgba(20,184,166,.2);border-radius:12px;padding:1.2rem;text-align:center;">' +
                     '<div style="font-size:2rem;margin-bottom:.6rem;">&#128506;</div>' +
                     '<div style="font-size:.95rem;font-weight:700;color:#fff;margin-bottom:.4rem;">Coming Soon</div>' +
                     '<p style="font-size:.83rem;color:#64748b;line-height:1.6;">Our destination guides for Copenhagen, Aarhus, Oslo, Stockholm and Hamburg are currently being written. Check back soon for curated travel tips, local highlights, and the best routes to explore by DriveNow.</p>' +
                     '</div>',

        pressmedia: '<h3 style="font-size:1.1rem;font-weight:700;color:#fff;margin-bottom:1rem;">Press &amp; Media</h3>' +
                    '<p style="font-size:.88rem;color:#94a3b8;margin-bottom:1.2rem;">For press enquiries, interview requests, or media assets, please contact our communications team.</p>' +
                    '<div style="display:flex;flex-direction:column;gap:.9rem;">' +
                    contactRow('&#9993;', 'Press enquiries', 'press@drivenow.dk') +
                    contactRow('', 'Response time', 'Within 24 hours') +
                    contactRow('', 'Spokesperson', 'Available for interviews Mon–Fri') +
                    '</div>' +
                    '<div style="background:rgba(255,255,255,.04);border-radius:10px;padding:1rem;margin-top:1.2rem;font-size:.83rem;color:#94a3b8;line-height:1.6;">' +
                    'High-resolution logos, photos, and brand assets are available on request. Please quote your publication name and deadline in your email.' +
                    '</div>'
    };

    function faqItem(q, a) {
        return '<div style="background:rgba(255,255,255,.04);border-radius:10px;padding:.9rem 1rem;">' +
               '<div style="font-size:.88rem;font-weight:600;color:#e2e8f0;margin-bottom:.4rem;">' + q + '</div>' +
               '<div style="font-size:.82rem;color:#94a3b8;line-height:1.55;">' + a + '</div></div>';
    }
    function contactRow(icon, label, value) {
        return '<div style="display:flex;align-items:center;gap:.75rem;padding:.6rem 0;border-bottom:1px solid rgba(255,255,255,.05);">' +
               '<div style="font-size:1rem;width:24px;text-align:center;">' + icon + '</div>' +
               '<div><div style="font-size:.75rem;color:#64748b;">' + label + '</div>' +
               '<div style="font-size:.88rem;color:#e2e8f0;font-weight:500;">' + value + '</div></div></div>';
    }
    function legalSection(title, body) {
        return '<div style="margin-bottom:1rem;">' +
               '<div style="font-size:.82rem;font-weight:700;color:#e2e8f0;margin-bottom:.3rem;">' + title + '</div>' +
               '<div style="font-size:.82rem;color:#94a3b8;line-height:1.65;">' + body + '</div></div>';
    }

    function openInfoModal(type) {
        var modal = document.getElementById('infoModal');
        var content = document.getElementById('infoModalContent');
        content.innerHTML = INFO_CONTENT[type] || '';
        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }
    function closeInfoModal() {
        document.getElementById('infoModal').style.display = 'none';
        document.body.style.overflow = '';
    }
    document.getElementById('infoModal').addEventListener('click', function(e) {
        if (e.target === this) closeInfoModal();
    });

    // ── Info popups ────────────────────────────────────
    function openEReceiptInfo() {
        var loggedIn = '<%= Session["CustomerLoggedIn"] != null && (bool)Session["CustomerLoggedIn"] ? "yes" : "no" %>';
        if (loggedIn === 'yes') {
            var name = '<%= Session["CustomerName"] != null ? Session["CustomerName"].ToString() : "" %>';
            var email = '<%= Session["CustomerEmail"] != null ? Session["CustomerEmail"].ToString() : "" %>';
            openInfoModal('_receipt');
            document.getElementById('infoModalContent').innerHTML =
                '<h3 style="font-size:1.1rem;font-weight:700;color:#fff;margin-bottom:1rem;">Get E-Receipt</h3>' +
                '<p style="font-size:.88rem;color:#94a3b8;margin-bottom:1rem;">Hello, ' + name + '. Your e-receipts are available in your customer dashboard.</p>' +
                '<a href="CustomerPortal.aspx" style="display:inline-block;background:#0d9488;color:#fff;padding:.6rem 1.4rem;border-radius:22px;font-weight:600;font-size:.88rem;text-decoration:none;margin-top:.5rem;">Go to My Dashboard</a>';
            document.getElementById('infoModal').style.display = 'flex';
            document.body.style.overflow = 'hidden';
        } else {
            openModal('m-login');
        }
    }
    function openClaimsInfo() {
        openInfoModal('_claims');
        document.getElementById('infoModalContent').innerHTML =
            '<h3 style="font-size:1.1rem;font-weight:700;color:#fff;margin-bottom:1rem;">&#9888; Claims &amp; Accident Reports</h3>' +
            '<p style="font-size:.88rem;color:#94a3b8;margin-bottom:1.2rem;">In the event of an accident or incident, contact us immediately on our 24/7 line:</p>' +
            '<div style="background:rgba(239,68,68,.12);border:1px solid rgba(239,68,68,.3);border-radius:12px;padding:1.2rem;margin-bottom:1rem;">' +
            '<div style="font-size:1.4rem;font-weight:800;color:#f87171;">+45 70 10 20 30</div>' +
            '<div style="font-size:.78rem;color:#94a3b8;margin-top:.25rem;">Available 24 hours, 7 days a week</div></div>' +
            contactRow('&#9993;', 'Claims email', 'claims@drivenow.dk') +
            contactRow('', 'Response time', 'Within 2 hours') +
            '<p style="font-size:.78rem;color:#64748b;margin-top:1rem;">Please do not move the vehicle and ensure all parties are safe before calling.</p>';
        document.getElementById('infoModal').style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }

    // ── Promo deal claim ───────────────────────────────
    function claimDeal(code, desc) {
        var loggedIn = document.getElementById('<%= hfCustLoggedIn.ClientID %>').value === '1';
        var name     = document.getElementById('<%= hfCustName.ClientID %>').value;
        if (loggedIn) {
            openInfoModal('_deal');
            document.getElementById('infoModalContent').innerHTML =
                '<h3 style="font-size:1.1rem;font-weight:700;color:#fff;margin-bottom:1rem;">Offer Saved, ' + name + '!</h3>' +
                '<p style="font-size:.88rem;color:#94a3b8;margin-bottom:1rem;">Your promotional code has been noted for your next booking.</p>' +
                '<div style="background:rgba(13,148,136,.15);border:1px solid rgba(13,148,136,.3);border-radius:12px;padding:1rem;margin-bottom:1.2rem;">' +
                '<div style="font-size:1.4rem;font-weight:800;color:#14b8a6;letter-spacing:.1em;">' + code + '</div>' +
                '<div style="font-size:.78rem;color:#5eead4;margin-top:.2rem;">' + desc + '</div></div>' +
                '<p style="font-size:.82rem;color:#64748b;margin-bottom:1.2rem;">Apply this code at checkout when booking a vehicle.</p>' +
                '<a href="BrowseFleet.aspx" style="display:inline-block;background:#0d9488;color:#fff;padding:.6rem 1.4rem;border-radius:22px;font-weight:600;font-size:.88rem;text-decoration:none;">Browse Fleet &amp; Book Now</a>';
            document.getElementById('infoModal').style.display = 'flex';
            document.body.style.overflow = 'hidden';
        } else {
            // Store promo code in sessionStorage so it survives the modal open
            sessionStorage.setItem('pendingPromo', code);
            openModal('m-register');
        }
    }

    // ── Capture returnUrl for post-login redirect — but do NOT auto-open the
    //    login modal. The homepage must stay put on load; the customer opens
    //    the login/sign-up box themselves via the nav buttons. (openlogin=1 and
    //    returnUrl no longer pop the modal automatically.)
    (function() {
        var params = new URLSearchParams(window.location.search);
        var returnUrl = params.get('returnUrl');
        if (returnUrl) sessionStorage.setItem('dn_returnUrl', returnUrl);
    })();

    // ── Reopen login/register modal after a failed server-side postback ──
    // RegisterStartupScript fires BEFORE openModal is defined (it runs just before
    // </form>, but openModal is defined in this <script> block which is AFTER </form>).
    // This DOMContentLoaded listener is the reliable fix: all scripts are parsed
    // before DOMContentLoaded fires, so openModal is guaranteed to exist.
    (function() {
        function tryReopenModal() {
            var loginMsg = document.querySelector('#m-login .form-message');
            if (loginMsg && loginMsg.textContent.trim()) { openModal('m-login'); return; }
            var regMsg   = document.querySelector('#m-register .form-message');
            if (regMsg   && regMsg.textContent.trim())   { openModal('m-register'); }
        }
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', tryReopenModal);
        } else {
            tryReopenModal();
        }
    })();

    // ── Enter key submits login / register modals ─────────────────────────
    (function () {
        function onEnterLogin(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                var btn = document.getElementById('<%= LoginButton.ClientID %>');
                if (btn) btn.click();
            }
        }
        function onEnterRegister(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                var btn = document.getElementById('<%= RegisterButton.ClientID %>');
                if (btn) btn.click();
            }
        }
        function attachEnterHandlers() {
            ['<%= LoginEmailTextBox.ClientID %>', '<%= LoginPasswordTextBox.ClientID %>'].forEach(function (id) {
                var el = document.getElementById(id);
                if (el) el.addEventListener('keydown', onEnterLogin);
            });
            ['<%= RegisterNameTextBox.ClientID %>', '<%= RegisterEmailTextBox.ClientID %>',
             '<%= RegisterPhoneTextBox.ClientID %>', '<%= RegisterPasswordTextBox.ClientID %>',
             '<%= RegisterConfirmPwTextBox.ClientID %>'].forEach(function (id) {
                var el = document.getElementById(id);
                if (el) el.addEventListener('keydown', onEnterRegister);
            });
        }
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', attachEnterHandlers);
        } else {
            attachEnterHandlers();
        }
    })();
</script>
</body>
</html>







