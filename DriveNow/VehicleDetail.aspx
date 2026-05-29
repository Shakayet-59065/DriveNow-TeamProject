<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VehicleDetail.aspx.cs" Inherits="DriveNow.VehicleDetail" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><asp:Literal ID="litPageTitle" runat="server" Text="Vehicle Details" /> — DriveNow</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;800&family=DM+Sans:opsz,wght@9..40,400;9..40,500&display=swap" rel="stylesheet" />
    <style>
        :root {
            --navy: #1A2332; --navy-deep: #0D1520; --teal: #0D9488;
            --teal-light: #14B8A6; --white: #FFFFFF; --grey: #94A3B8;
            --font-head: 'Outfit', Arial, sans-serif; --font-body: 'DM Sans', Arial, sans-serif;
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: var(--font-body); background: var(--navy-deep); color: var(--white); min-height: 100vh; }

        /* NAV */
        nav { display: flex; align-items: center; justify-content: space-between; padding: 1rem 2rem; background: rgba(13,21,32,.92); backdrop-filter: blur(12px); position: sticky; top: 0; z-index: 100; border-bottom: 1px solid rgba(255,255,255,.07); }
        .nav-logo { font-family: var(--font-head); font-size: 1.4rem; font-weight: 800; color: var(--white); text-decoration: none; }
        .nav-logo span { color: var(--teal-light); }
        .nav-links { display: flex; gap: 1.5rem; align-items: center; }
        .nav-links a { color: rgba(255,255,255,.75); text-decoration: none; font-size: .93rem; transition: color .2s; }
        .nav-links a:hover { color: var(--white); }
        .btn { display: inline-flex; align-items: center; gap: .4rem; padding: .6rem 1.4rem; border-radius: 8px; font-family: var(--font-head); font-weight: 600; font-size: .88rem; text-decoration: none; border: none; cursor: pointer; transition: all .2s; }
        .btn-teal { background: var(--teal); color: var(--white); }
        .btn-teal:hover { background: var(--teal-light); }
        .btn-ghost { background: transparent; color: var(--white); border: 1.5px solid rgba(255,255,255,.25); }
        .btn-ghost:hover { border-color: var(--white); }

        /* BREADCRUMB */
        .breadcrumb { padding: 1.2rem 2rem .5rem; font-size: .85rem; color: var(--grey); }
        .breadcrumb a { color: var(--teal-light); text-decoration: none; }
        .breadcrumb a:hover { text-decoration: underline; }
        .breadcrumb span { margin: 0 .4rem; }

        /* DETAIL LAYOUT */
        .detail-wrap { max-width: 1100px; margin: 0 auto; padding: 1.5rem 2rem 5rem; display: grid; grid-template-columns: 1fr 420px; gap: 3rem; }

        /* IMAGE PANEL */
        .vehicle-img-wrap { position: relative; border-radius: 16px; overflow: hidden; border: 1px solid rgba(255,255,255,.08); }
        .vehicle-img-wrap img { width: 100%; aspect-ratio: 16/10; object-fit: cover; display: block; }
        .avail-badge { position: absolute; top: 1rem; left: 1rem; background: rgba(13,148,136,.9); color: var(--white); font-family: var(--font-head); font-size: .78rem; font-weight: 700; letter-spacing: .08em; text-transform: uppercase; padding: .35rem .9rem; border-radius: 99px; }

        /* INFO PANEL */
        .info-panel { display: flex; flex-direction: column; gap: 1.5rem; }
        .info-label { font-family: var(--font-head); font-size: .78rem; font-weight: 700; letter-spacing: .12em; text-transform: uppercase; color: var(--teal-light); margin-bottom: .4rem; }
        .vehicle-name { font-family: var(--font-head); font-size: clamp(1.8rem, 4vw, 2.4rem); font-weight: 800; line-height: 1.15; }
        .vehicle-reg { font-size: .88rem; color: var(--grey); margin-top: .4rem; }

        .rate-box { background: rgba(13,148,136,.1); border: 1px solid rgba(13,148,136,.3); border-radius: 12px; padding: 1.2rem 1.5rem; }
        .rate-value { font-family: var(--font-head); font-size: 2.2rem; font-weight: 800; color: var(--teal-light); }
        .rate-value span { font-size: 1rem; font-weight: 400; color: var(--grey); }

        .specs-grid { display: grid; grid-template-columns: 1fr 1fr; gap: .75rem; }
        .spec-item { background: rgba(26,35,50,.7); border: 1px solid rgba(255,255,255,.07); border-radius: 10px; padding: .85rem 1rem; }
        .spec-label { font-size: .75rem; color: var(--grey); margin-bottom: .2rem; }
        .spec-value { font-family: var(--font-head); font-size: .97rem; font-weight: 600; }

        .divider { border: none; border-top: 1px solid rgba(255,255,255,.08); }

        .btn-book-large { display: block; width: 100%; padding: .9rem; border-radius: 10px; background: var(--teal); color: var(--white); font-family: var(--font-head); font-size: 1rem; font-weight: 700; text-align: center; text-decoration: none; border: none; cursor: pointer; transition: background .2s; }
        .btn-book-large:hover { background: var(--teal-light); }
        .btn-login-large { display: block; width: 100%; padding: .9rem; border-radius: 10px; background: transparent; color: var(--white); font-family: var(--font-head); font-size: 1rem; font-weight: 700; text-align: center; text-decoration: none; border: 1.5px solid rgba(255,255,255,.25); cursor: pointer; transition: all .2s; }
        .btn-login-large:hover { border-color: var(--white); }
        .btn-back { display: inline-flex; align-items: center; gap: .4rem; color: var(--grey); text-decoration: none; font-size: .88rem; margin-top: .5rem; transition: color .2s; }
        .btn-back:hover { color: var(--white); }

        /* ERROR */
        .not-found { text-align: center; padding: 8rem 2rem; }
        .not-found h2 { font-family: var(--font-head); font-size: 2rem; font-weight: 800; margin-bottom: 1rem; }
        .not-found p { color: var(--grey); margin-bottom: 2rem; }

        /* FOOTER */
        footer { text-align: center; padding: 2rem; color: var(--grey); font-size: .83rem; border-top: 1px solid rgba(255,255,255,.06); }

        @media(max-width:860px) {
            .detail-wrap { grid-template-columns: 1fr; }
        }
        @media(max-width:640px) {
            nav { padding: 1rem; }
            .nav-links .hide-mob { display: none; }
            .breadcrumb { padding: 1rem 1rem .5rem; }
            .detail-wrap { padding: 1rem 1rem 4rem; }
        }
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
</head>
<body>
    <form id="form1" runat="server">

    <nav>
        <a href="Default.aspx" class="nav-logo">Drive<span>Now</span></a>
        <div class="nav-links">
            <a href="Default.aspx" class="hide-mob">Home</a>
            <a href="BrowseFleet.aspx" class="hide-mob">Fleet</a>
            <asp:PlaceHolder ID="phGuest" runat="server">
                <a href="Default.aspx?openlogin=1" class="btn btn-ghost">Log In</a>
                <a href="Default.aspx" class="btn btn-teal">Sign Up</a>
            </asp:PlaceHolder>
            <asp:PlaceHolder ID="phLoggedIn" runat="server" Visible="false">
                <a href="CustomerPortal.aspx" class="btn btn-teal">My Portal</a>
            </asp:PlaceHolder>
        </div>
    </nav>

    <asp:Panel ID="pnlNotFound" runat="server" Visible="false">
        <div class="not-found">
            <h2>Vehicle Not Found</h2>
            <p>This vehicle may no longer be available.</p>
            <a href="BrowseFleet.aspx" class="btn btn-teal">Browse All Vehicles</a>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlDetail" runat="server">
        <div class="breadcrumb">
            <a href="Default.aspx">Home</a>
            <span>›</span>
            <a href="BrowseFleet.aspx">Fleet</a>
            <span>›</span>
            <asp:Literal ID="litBreadcrumb" runat="server" />
        </div>

        <div class="detail-wrap">
            <!-- IMAGE -->
            <div>
                <div class="vehicle-img-wrap">
                    <asp:Image ID="imgVehicle" runat="server" CssClass="" AlternateText="Vehicle" />
                    <div class="avail-badge">Available</div>
                </div>
            </div>

            <!-- INFO -->
            <div class="info-panel">
                <div>
                    <div class="info-label">Premium Vehicle</div>
                    <div class="vehicle-name"><asp:Literal ID="litVehicleName" runat="server" /></div>
                    <div class="vehicle-reg">Reg: <asp:Literal ID="litReg" runat="server" /></div>
                </div>

                <div class="rate-box">
                    <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:.5rem;">
                        <div class="info-label" style="margin-bottom:0;">Daily Rate</div>
                        <select id="currencySelect" onchange="convertCurrency(this.value)"
                                style="background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.15);border-radius:6px;padding:.3rem .6rem;color:var(--white);font-size:.78rem;width:auto;">
                            <option value="GBP">GBP £</option>
                            <option value="EUR">EUR €</option>
                            <option value="USD">USD $</option>
                            <option value="DKK">DKK kr</option>
                            <option value="SEK">SEK kr</option>
                            <option value="NOK">NOK kr</option>
                            <option value="AUD">AUD $</option>
                        </select>
                    </div>
                    <div class="rate-value" id="rateDisplay">
                        <span id="currencySymbol">£</span><span id="rateAmount"><asp:Literal ID="litRate" runat="server" /></span>
                        <span>/ day</span>
                    </div>
                    <div style="font-size:.72rem;color:var(--grey);margin-top:.3rem;" id="rateNote">Indicative rate — charged in GBP at checkout</div>
                </div>

                <div>
                    <div class="info-label" style="margin-bottom:.75rem;">Specifications</div>
                    <div class="specs-grid">
                        <div class="spec-item">
                            <div class="spec-label">Category</div>
                            <div class="spec-value"><asp:Literal ID="litCategory" runat="server" /></div>
                        </div>
                        <div class="spec-item">
                            <div class="spec-label">Seating</div>
                            <div class="spec-value"><asp:Literal ID="litSeats" runat="server" /></div>
                        </div>
                        <div class="spec-item">
                            <div class="spec-label">Doors</div>
                            <div class="spec-value"><asp:Literal ID="litDoors" runat="server" /></div>
                        </div>
                        <div class="spec-item">
                            <div class="spec-label">Transmission</div>
                            <div class="spec-value">Automatic</div>
                        </div>
                        <div class="spec-item">
                            <div class="spec-label">Year</div>
                            <div class="spec-value">2025</div>
                        </div>
                        <div class="spec-item">
                            <div class="spec-label">Mileage</div>
                            <div class="spec-value"><asp:Literal ID="litMileage" runat="server" /></div>
                        </div>
                    </div>
                </div>

                <hr class="divider" />

                <asp:PlaceHolder ID="phBookBtn" runat="server" Visible="false">
                    <a href="#" id="bookLink" runat="server" class="btn-book-large">Book This Vehicle</a>
                </asp:PlaceHolder>
                <asp:PlaceHolder ID="phLoginBtn" runat="server">
                    <a href="#" id="loginLink" runat="server" class="btn-login-large">Log In to Book</a>
                </asp:PlaceHolder>

                <a href="BrowseFleet.aspx" class="btn-back">← Back to Fleet</a>
            </div>
        </div>
    </asp:Panel>

    <footer>
        © 2025 DriveNow — Premium Vehicle Hire
    </footer>

    </form>

<script>
    // Currency converter – approximate indicative rates (GBP base, updated May 2025)
    var RATES = { GBP:1, EUR:1.18, USD:1.27, DKK:8.72, SEK:13.5, NOK:13.9, AUD:1.98 };
    var SYMBOLS = { GBP:'£', EUR:'€', USD:'$', DKK:'kr ', SEK:'kr ', NOK:'kr ', AUD:'A$' };
    var baseRate = parseFloat(document.getElementById('rateAmount').textContent);

    function convertCurrency(code) {
        var converted = (baseRate * RATES[code]).toFixed(2);
        document.getElementById('currencySymbol').innerHTML = SYMBOLS[code];
        document.getElementById('rateAmount').textContent   = converted;
        document.getElementById('rateNote').textContent     = code === 'GBP'
            ? 'Indicative rate — charged in GBP at checkout'
            : 'Indicative rate only — charged in GBP at checkout';
    }
</script>
</body>
</html>
