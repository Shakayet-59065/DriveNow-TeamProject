<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripEdit.aspx.cs" Inherits="DriveNow.TripEdit" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Edit Trip</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <link rel="stylesheet" href="Content/Site.css" />
    <style>
        .ins-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:.7rem;margin-top:.4rem;}
        .ins-card{border:2px solid rgba(255,255,255,.1);border-radius:10px;padding:.9rem 1rem;cursor:pointer;transition:border-color .2s,background .2s;position:relative;}
        .ins-card:hover{border-color:rgba(20,184,166,.5);}
        .ins-card.ins-selected{border-color:#14b8a6;background:rgba(20,184,166,.1);}
        .ins-card input[type=radio]{position:absolute;opacity:0;pointer-events:none;}
        .ins-tier{font-size:.68rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;color:#14b8a6;margin-bottom:.2rem;}
        .ins-name{font-size:.88rem;font-weight:700;color:#fff;margin-bottom:.2rem;}
        .ins-price{font-size:.82rem;color:#14b8a6;font-weight:600;}
        .addon-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:.7rem;margin-top:.4rem;}
        .addon-card{display:flex;align-items:center;gap:.7rem;background:rgba(26,35,50,.7);border:2px solid rgba(255,255,255,.1);border-radius:10px;padding:.75rem .9rem;cursor:pointer;transition:border-color .2s,background .2s;}
        .addon-card:hover{border-color:rgba(20,184,166,.4);}
        .addon-card.addon-sel{border-color:#14b8a6;background:rgba(20,184,166,.1);}
        .addon-chk{width:16px;height:16px;accent-color:#14b8a6;cursor:pointer;flex-shrink:0;}
        .addon-name{font-size:.82rem;font-weight:700;color:#fff;}
        .addon-rate{font-size:.74rem;color:#14b8a6;}
        .section-divider{border:none;border-top:1px solid rgba(255,255,255,.08);margin:1.5rem 0 1rem;}
        .section-label{font-size:.72rem;font-weight:700;text-transform:uppercase;letter-spacing:.09em;color:#14b8a6;margin-bottom:.75rem;}
        @media(max-width:700px){.ins-grid,.addon-grid{grid-template-columns:1fr 1fr;}}
        @media(max-width:420px){.ins-grid,.addon-grid{grid-template-columns:1fr;}}
    </style>
</head>
<body>
<form id="frmTripEdit" runat="server">
<div class="dn-shell">

    <!-- SIDEBAR -->
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo"><img src="Content/logo.png" alt="DriveNow" /></div>
        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">Main</div>
            <a href="MainMenu.aspx"     class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">dashboard</span> Dashboard</a>
            <a href="TripList.aspx"     class="dn-nav-item active"><span class="material-symbols-outlined" style="font-size:17px;">route</span> Trips</a>
            <a href="TripTypeList.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">category</span> Trip Types</a>
            <div class="dn-nav-label">Team</div>
            <a href="CustomerList.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">group</span> Customers</a>
            <a href="DriverList.aspx"   class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">person</span> Drivers</a>
            <a href="VehicleList.aspx"  class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">directions_car</span> Vehicles</a>
            <a href="ContributorList.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">handshake</span> Contributors</a>
            <div class="dn-nav-label">ADMIN</div>
            <a href="TempPasswords.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">key</span> Temp Passwords</a>
            <a href="StaffList.aspx"     class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">badge</span> Staff</a>
        </nav>
        <div class="dn-sidebar-footer">
            <div class="dn-sidebar-user">
                <div class="dn-sidebar-avatar"><%= (Session["Username"] != null ? Session["Username"].ToString().Substring(0,1).ToUpper() : "?") %></div>
                <div><div class="dn-sidebar-name">Admin</div><div class="dn-sidebar-role">Staff Portal</div></div>
            </div>
            <a href="Logout.aspx" class="dn-sidebar-logout">&#8617; Log out</a>
        </div>
    </div>

    <!-- MAIN -->
    <div class="dn-main">
        <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
            <div class="dn-topbar-title">Edit Trip</div>
            <div class="dn-topbar-right">
                <a href="TripList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">&larr; Trip List</a>
            </div>
        </div>

        <div class="dn-content">
            <div class="dn-page-header">
                <div>
                    <div class="dn-page-title">Edit Trip</div>
                    <div class="dn-page-sub">Update all details for this trip booking</div>
                </div>
            </div>

            <div class="dn-form-card">
                <asp:Label ID="lblError"   runat="server" CssClass="dn-alert-error"   Visible="false" />
                <asp:Label ID="lblSuccess" runat="server" CssClass="dn-alert-success" Visible="false" />
                <asp:HiddenField ID="hdnTripID"         runat="server" />
                <asp:HiddenField ID="hdnCustomerTripID" runat="server" />

                <%-- ── CORE TRIP FIELDS ── --%>
                <div class="section-label">Core Trip</div>

                <div class="dn-field">
                    <label class="dn-label">Customer <span class="required">*</span></label>
                    <asp:DropDownList ID="ddlCustomer" runat="server" CssClass="dn-select" />
                </div>
                <div class="dn-field">
                    <label class="dn-label">Vehicle <span class="required">*</span></label>
                    <asp:DropDownList ID="ddlVehicle" runat="server" CssClass="dn-select" />
                </div>
                <div class="dn-field">
                    <label class="dn-label">Driver</label>
                    <asp:DropDownList ID="ddlDriver" runat="server" CssClass="dn-select" />
                    <div class="dn-hint">Select &lsquo;Self-Drive&rsquo; if no driver is needed.</div>
                </div>
                <div class="dn-field">
                    <label class="dn-label">Trip Type <span class="required">*</span></label>
                    <asp:DropDownList ID="ddlTripType" runat="server" CssClass="dn-select" />
                </div>

                <hr class="section-divider" />
                <%-- ── PICKUP DETAILS ── --%>
                <div class="section-label">Pickup Details</div>

                <div class="dn-field">
                    <label class="dn-label">Pickup Location <span class="required">*</span></label>
                    <asp:TextBox ID="txtPickupLocation" runat="server" CssClass="dn-input"
                        placeholder="e.g. Niels Brock Copenhagen, Danasvej 3" MaxLength="200" />
                </div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;">
                    <div class="dn-field">
                        <label class="dn-label">Pickup Date <span class="required">*</span></label>
                        <asp:TextBox ID="txtPickupDate" runat="server" CssClass="dn-input" TextMode="Date" />
                    </div>
                    <div class="dn-field">
                        <label class="dn-label">Pickup Time</label>
                        <asp:TextBox ID="txtPickupTime" runat="server" CssClass="dn-input" TextMode="Time" />
                    </div>
                </div>

                <hr class="section-divider" />
                <%-- ── DROP-OFF DETAILS ── --%>
                <div class="section-label">Drop-off Details</div>

                <div class="dn-field">
                    <label class="dn-label">Drop-off Location <span class="required">*</span></label>
                    <asp:TextBox ID="txtDropoffLocation" runat="server" CssClass="dn-input"
                        placeholder="e.g. Copenhagen Airport, Terminal 2" MaxLength="200" />
                </div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;">
                    <div class="dn-field">
                        <label class="dn-label">Drop-off Date <span class="required">*</span></label>
                        <asp:TextBox ID="txtDropoffDate" runat="server" CssClass="dn-input" TextMode="Date" />
                    </div>
                    <div class="dn-field">
                        <label class="dn-label">Drop-off Time</label>
                        <asp:TextBox ID="txtDropoffTime" runat="server" CssClass="dn-input" TextMode="Time" />
                    </div>
                </div>

                <div class="dn-field">
                    <label class="dn-label">Notes</label>
                    <asp:TextBox ID="txtNotes" runat="server" CssClass="dn-input" TextMode="MultiLine"
                        placeholder="Special requirements, accessibility needs, etc." MaxLength="500"
                        style="min-height:70px;resize:vertical;" />
                </div>

                <hr class="section-divider" />
                <%-- ── INSURANCE ── --%>
                <div class="section-label">Insurance</div>
                <asp:HiddenField ID="hdnInsurance" runat="server" Value="Basic" />
                <div class="ins-grid">
                    <div class="ins-card" id="ins-Basic" onclick="selectIns('Basic')">
                        <input type="radio" name="insRadio" value="Basic" />
                        <div class="ins-tier">Basic</div>
                        <div class="ins-name">Third-Party Cover</div>
                        <div class="ins-price">FREE / day</div>
                    </div>
                    <div class="ins-card" id="ins-Standard" onclick="selectIns('Standard')">
                        <input type="radio" name="insRadio" value="Standard" />
                        <div class="ins-tier">Standard</div>
                        <div class="ins-name">Damage &amp; Theft</div>
                        <div class="ins-price">+&pound;10 / day</div>
                    </div>
                    <div class="ins-card" id="ins-Premium" onclick="selectIns('Premium')">
                        <input type="radio" name="insRadio" value="Premium" />
                        <div class="ins-tier">Premium</div>
                        <div class="ins-name">Full Comprehensive</div>
                        <div class="ins-price">+&pound;20 / day</div>
                    </div>
                    <div class="ins-card" id="ins-Elite" onclick="selectIns('Elite')">
                        <input type="radio" name="insRadio" value="Elite" />
                        <div class="ins-tier">Elite</div>
                        <div class="ins-name">Ultimate Protection</div>
                        <div class="ins-price">+&pound;35 / day</div>
                    </div>
                </div>

                <hr class="section-divider" />
                <%-- ── ADD-ONS ── --%>
                <div class="section-label">Add-Ons &amp; Extras</div>
                <div class="addon-grid">
                    <label class="addon-card" onclick="toggleAddon(this)">
                        <asp:CheckBox ID="chkGPS"         runat="server" CssClass="addon-chk" />
                        <span><div class="addon-name">GPS Navigation</div><div class="addon-rate">+&pound;5/day</div></span>
                    </label>
                    <label class="addon-card" onclick="toggleAddon(this)">
                        <asp:CheckBox ID="chkMobileMount" runat="server" CssClass="addon-chk" />
                        <span><div class="addon-name">Mobile Mount &amp; Charger</div><div class="addon-rate">+&pound;3/day</div></span>
                    </label>
                    <label class="addon-card" onclick="toggleAddon(this)">
                        <asp:CheckBox ID="chkBabySeat"    runat="server" CssClass="addon-chk" />
                        <span><div class="addon-name">Baby/Child Seat</div><div class="addon-rate">+&pound;8/day</div></span>
                    </label>
                    <label class="addon-card" onclick="toggleAddon(this)">
                        <asp:CheckBox ID="chkBoosterSeat" runat="server" CssClass="addon-chk" />
                        <span><div class="addon-name">Booster Seat</div><div class="addon-rate">+&pound;5/day</div></span>
                    </label>
                    <label class="addon-card" onclick="toggleAddon(this)">
                        <asp:CheckBox ID="chkCycleCarrier" runat="server" CssClass="addon-chk" />
                        <span><div class="addon-name">Cycle Carrier</div><div class="addon-rate">+&pound;10/day</div></span>
                    </label>
                    <label class="addon-card" onclick="toggleAddon(this)">
                        <asp:CheckBox ID="chkRoofBox"     runat="server" CssClass="addon-chk" />
                        <span><div class="addon-name">Roof Box (400L)</div><div class="addon-rate">+&pound;12/day</div></span>
                    </label>
                    <label class="addon-card" onclick="toggleAddon(this)">
                        <asp:CheckBox ID="chkWifiHotspot" runat="server" CssClass="addon-chk" />
                        <span><div class="addon-name">4G WiFi Hotspot</div><div class="addon-rate">+&pound;6/day</div></span>
                    </label>
                    <label class="addon-card" onclick="toggleAddon(this)">
                        <asp:CheckBox ID="chkDashcam"     runat="server" CssClass="addon-chk" />
                        <span><div class="addon-name">Dashcam (front+rear)</div><div class="addon-rate">+&pound;4/day</div></span>
                    </label>
                </div>

                <div class="dn-form-actions" style="margin-top:1.5rem;">
                    <asp:Button ID="btnSave" runat="server" Text="Save Changes"
                        CssClass="dn-btn dn-btn-primary" OnClick="btnSave_Click" />
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel"
                        CssClass="dn-btn dn-btn-secondary" OnClick="btnCancel_Click"
                        CausesValidation="false" />
                </div>
            </div>
        </div>
        <div class="dn-footer">DriveNow Admin System &middot; CTEC2713N &middot; Niels Brock Copenhagen</div>
    </div>

</div>
</form>
<script>
    /* ── Mobile sidebar toggle ── */
    function toggleSidebar() { document.body.classList.toggle('sidebar-open'); }
    document.addEventListener('click', function(e) {
        if (document.body.classList.contains('sidebar-open') &&
            !e.target.closest('.dn-sidebar') &&
            !e.target.closest('.dn-mobile-menu-btn'))
            document.body.classList.remove('sidebar-open');
    });

    /* ── Insurance card selection ── */
    function selectIns(tier) {
        document.querySelectorAll('.ins-card').forEach(function(c) { c.classList.remove('ins-selected'); });
        var card = document.getElementById('ins-' + tier);
        if (card) card.classList.add('ins-selected');
        var hdn = document.querySelector('[id$="hdnInsurance"]');
        if (hdn) hdn.value = tier;
    }

    /* ── Add-on card toggle ── */
    function toggleAddon(label) {
        setTimeout(function() {
            var chk = label.querySelector('input[type=checkbox]');
            if (chk) label.classList.toggle('addon-sel', chk.checked);
        }, 0);
    }

    /* ── Restore state on page load / postback ── */
    document.addEventListener('DOMContentLoaded', function() {
        // Restore insurance selection
        var hdn = document.querySelector('[id$="hdnInsurance"]');
        if (hdn && hdn.value) selectIns(hdn.value);

        // Restore add-on selected state (survives postback because CheckBox keeps .Checked)
        document.querySelectorAll('.addon-card').forEach(function(lbl) {
            var chk = lbl.querySelector('input[type=checkbox]');
            if (chk && chk.checked) lbl.classList.add('addon-sel');
        });
    });
</script>
</body>
</html>
