<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerPortal.aspx.cs" Inherits="DriveNow.CustomerPortal" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Trips — DriveNow</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;800&family=DM+Sans:opsz,wght@9..40,400;9..40,500&display=swap" rel="stylesheet" />
    <style>
        :root{--navy:#1A2332;--navy-deep:#0D1520;--teal:#0D9488;--teal-light:#14B8A6;--white:#fff;--grey:#94A3B8;--font-head:'Outfit',Arial,sans-serif;--font-body:'DM Sans',Arial,sans-serif;}
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
        body{font-family:var(--font-body);background:var(--navy-deep);color:var(--white);min-height:100vh;}

        nav{display:flex;align-items:center;justify-content:space-between;padding:1rem 2rem;background:rgba(13,21,32,.95);backdrop-filter:blur(12px);position:sticky;top:0;z-index:100;border-bottom:1px solid rgba(255,255,255,.07);}
        .nav-logo{font-family:var(--font-head);font-size:1.4rem;font-weight:800;color:var(--white);text-decoration:none;}
        .nav-logo span{color:var(--teal-light);}
        .nav-right{display:flex;align-items:center;gap:1rem;}
        .nav-name{font-size:.88rem;color:var(--grey);}
        .btn{display:inline-flex;align-items:center;padding:.55rem 1.2rem;border-radius:8px;font-family:var(--font-head);font-weight:600;font-size:.85rem;text-decoration:none;border:none;cursor:pointer;transition:all .2s;}
        .btn-teal{background:var(--teal);color:var(--white);}
        .btn-teal:hover{background:var(--teal-light);}
        .btn-ghost{background:transparent;color:var(--white);border:1.5px solid rgba(255,255,255,.2);}
        .btn-ghost:hover{border-color:var(--white);}
        .btn-sm{padding:.4rem .9rem;font-size:.8rem;}

        .page{max-width:1200px;margin:0 auto;padding:2.5rem 2rem 5rem;}

        .welcome-bar{margin-bottom:2rem;}
        .welcome-bar .label{font-size:.75rem;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:var(--teal-light);margin-bottom:.4rem;}
        .welcome-bar h1{font-family:var(--font-head);font-size:clamp(1.6rem,4vw,2.2rem);font-weight:800;}

        .stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:1rem;margin-bottom:2.5rem;}
        .stat-card{background:rgba(26,35,50,.8);border:1px solid rgba(255,255,255,.08);border-radius:12px;padding:1.3rem 1.5rem;}
        .stat-num{font-family:var(--font-head);font-size:2rem;font-weight:800;color:var(--teal-light);line-height:1;}
        .stat-lbl{font-size:.8rem;color:var(--grey);margin-top:.35rem;}

        .loyalty-badge{display:flex;align-items:center;flex-wrap:wrap;gap:.5rem;border:1px solid;border-radius:10px;padding:.65rem 1.1rem;margin-bottom:1.4rem;background:rgba(26,35,50,.55);}
        .quick-links{display:flex;gap:1rem;flex-wrap:wrap;margin-bottom:2.5rem;}

        .section-title{font-family:var(--font-head);font-size:1.1rem;font-weight:700;margin-bottom:1.2rem;display:flex;align-items:center;gap:.6rem;}
        .section-title::after{content:'';flex:1;height:1px;background:rgba(255,255,255,.08);}

        .trip-table-wrap{overflow-x:auto;border-radius:12px;border:1px solid rgba(255,255,255,.08);}
        table{width:100%;border-collapse:collapse;font-size:.85rem;}
        thead{background:rgba(13,148,136,.12);}
        thead th{padding:.85rem 1rem;text-align:left;font-family:var(--font-head);font-size:.72rem;font-weight:700;letter-spacing:.07em;text-transform:uppercase;color:var(--teal-light);white-space:nowrap;}
        tbody tr{border-top:1px solid rgba(255,255,255,.05);transition:background .15s;}
        tbody tr:hover{background:rgba(255,255,255,.03);}
        tbody td{padding:.85rem 1rem;vertical-align:top;color:rgba(255,255,255,.85);}

        .trip-id{font-family:var(--font-head);font-weight:700;font-size:.9rem;}
        .vehicle-name{font-weight:600;margin-bottom:.15rem;}
        .reg-no{font-size:.76rem;color:var(--grey);}
        .location-main{font-weight:500;margin-bottom:.15rem;}
        .location-date{font-size:.76rem;color:var(--grey);}
        .driver-cell{color:var(--grey);font-size:.82rem;}
        .notes-cell{font-size:.8rem;color:var(--grey);max-width:160px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}

        .badge{display:inline-block;padding:.22rem .7rem;border-radius:99px;font-size:.72rem;font-weight:700;letter-spacing:.05em;text-transform:uppercase;}
        .badge-upcoming{background:rgba(13,148,136,.18);color:var(--teal-light);}
        .badge-today{background:rgba(234,179,8,.15);color:#FCD34D;}
        .badge-completed{background:rgba(148,163,184,.12);color:var(--grey);}
        .badge-cancelled{background:rgba(239,68,68,.12);color:#fca5a5;}

        .type-chip{display:inline-block;padding:.18rem .6rem;border-radius:6px;font-size:.74rem;background:rgba(255,255,255,.07);color:rgba(255,255,255,.7);}
        .rate{font-family:var(--font-head);font-weight:700;color:var(--teal-light);}

        .empty-state{text-align:center;padding:4rem 1rem;}
        .empty-icon{font-size:3rem;margin-bottom:1rem;}
        .empty-state h3{font-family:var(--font-head);font-size:1.2rem;margin-bottom:.5rem;}
        .empty-state p{color:var(--grey);font-size:.9rem;margin-bottom:1.5rem;}

        .flash{display:flex;align-items:center;gap:.75rem;padding:1rem 1.4rem;border-radius:10px;margin-bottom:2rem;font-size:.93rem;animation:slideDown .4s ease;}
        .flash-success{background:rgba(13,148,136,.15);border:1px solid rgba(13,148,136,.35);color:#5EEAD4;}
        .flash-info{background:rgba(99,102,241,.12);border:1px solid rgba(99,102,241,.3);color:#A5B4FC;}
        @keyframes slideDown{from{opacity:0;transform:translateY(-10px);}to{opacity:1;transform:none;}}
        @keyframes fadeUp{from{opacity:0;transform:translateY(18px);}to{opacity:1;transform:none;}}
        .page{animation:fadeUp .45s ease;}
        .stat-card{transition:transform .2s,box-shadow .2s,border-color .2s;}
        .stat-card:hover{transform:translateY(-4px);box-shadow:0 12px 32px rgba(13,148,136,.18);border-color:rgba(13,148,136,.35);}
        .btn:active,.btn-teal:active,.btn-ghost:active{transform:scale(.96);}
        .trip-table-wrap tbody tr{transition:background .15s,transform .1s;}
        .quick-links .btn{transition:transform .18s,background .18s,box-shadow .18s;}
        .quick-links .btn:hover{transform:translateY(-2px);box-shadow:0 6px 18px rgba(13,148,136,.22);}
        @media(max-width:700px){.page{padding:1.5rem 1rem 4rem;}.stats{grid-template-columns:1fr 1fr;}}

        /* ── Phone: 480px ── */
        @media (max-width: 480px) {
            .page { padding: 1rem .75rem; }
            .stats { grid-template-columns: 1fr 1fr; gap: .6rem; }
            .stat-card { padding: .85rem .75rem; }
            .stat-num { font-size: 1.5rem; }
            .stat-lbl { font-size: .68rem; }
            .section-title { font-size: 1rem; }
            .edit-profile-card { padding: 1rem; border-radius: 10px; }
            .ep-row { grid-template-columns: 1fr !important; }
            .trip-table-wrap { overflow-x: auto; -webkit-overflow-scrolling: touch; }
            .trip-table-wrap table { min-width: 500px; }
        }

        /* ── Very small: 380px ── */
        @media (max-width: 380px) {
            .stats { grid-template-columns: 1fr; }
            .edit-profile-card { padding: .85rem .7rem; }
        }

        /* Edit profile */
        .edit-profile-card{background:rgba(26,35,50,.8);border:1px solid rgba(13,148,136,.25);border-radius:14px;padding:1.6rem;margin-top:2.5rem;}
        .ep-title{font-family:var(--font-head);font-size:1.05rem;font-weight:700;margin-bottom:1.2rem;display:flex;align-items:center;gap:.5rem;}
        .ep-title::after{content:'';flex:1;height:1px;background:rgba(255,255,255,.08);}
        .ep-row{display:grid;grid-template-columns:1fr 1fr;gap:1rem;margin-bottom:1rem;}
        .ep-field label{display:block;font-size:.74rem;font-weight:600;text-transform:uppercase;letter-spacing:.07em;color:var(--teal-light);margin-bottom:.35rem;}
        .ep-field input{width:100%;background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.12);border-radius:8px;padding:.65rem .9rem;color:#fff;font-size:.88rem;font-family:var(--font-body);outline:none;transition:border-color .2s;}
        .ep-field input:focus{border-color:var(--teal);}
        .ep-consent{background:rgba(13,148,136,.07);border:1px solid rgba(13,148,136,.18);border-radius:9px;padding:.9rem 1rem;margin:1rem 0;font-size:.78rem;color:#5eead4;line-height:1.6;}
        .ep-consent-check{display:flex;align-items:flex-start;gap:.55rem;margin-top:.6rem;}
        .ep-consent-check input[type=checkbox]{margin-top:2px;width:15px;height:15px;accent-color:#0d9488;flex-shrink:0;cursor:pointer;}
        .ep-consent-check span{font-size:.78rem;color:#94a3b8;line-height:1.5;}
        .ep-msg-ok{background:rgba(13,148,136,.15);border:1px solid rgba(13,148,136,.3);color:#5eead4;padding:.7rem 1rem;border-radius:8px;font-size:.85rem;margin-bottom:.9rem;}
        .ep-msg-err{background:rgba(239,68,68,.1);border:1px solid rgba(239,68,68,.3);color:#fca5a5;padding:.7rem 1rem;border-radius:8px;font-size:.85rem;margin-bottom:.9rem;}
        .val-hint{color:#fca5a5;font-size:.75rem;margin-top:.2rem;}
        .ep-save-btn{background:var(--teal);color:#fff;border:none;border-radius:9px;padding:.65rem 1.6rem;font-size:.9rem;font-weight:700;font-family:var(--font-head);cursor:pointer;transition:background .2s;}
        .ep-save-btn:hover{background:var(--teal-light);}
        .cancel-btn{background:rgba(239,68,68,.1);border:1px solid rgba(239,68,68,.3);color:#fca5a5;padding:.3rem .75rem;border-radius:22px;font-size:.75rem;cursor:pointer;text-decoration:none;display:inline-block;}
        .cancel-btn:hover{background:rgba(239,68,68,.2);}
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
</head>
<body>
<form id="form1" runat="server">

<nav>
    <a href="Default.aspx" class="nav-logo">Drive<span>Now</span></a>
    <div class="nav-right">
        <span class="nav-name"><asp:Literal ID="litNavName" runat="server" /></span>
        <a href="BrowseFleet.aspx" class="btn btn-teal btn-sm">Quick Book</a>
        <asp:Button ID="btnLogout" runat="server" Text="Log Out" CssClass="btn btn-ghost btn-sm" OnClick="btnLogout_Click" CausesValidation="false" />
    </div>
</nav>

<div class="page">

        <asp:Panel ID="pnlFlash" runat="server" Visible="false">
        <asp:Literal ID="litFlash" runat="server" />
    </asp:Panel>
<div class="welcome-bar">
        <div class="label">Customer Dashboard</div>
        <h1>Welcome back, <asp:Literal ID="litName" runat="server" /></h1>
    </div>

    <div class="stats">
        <div class="stat-card">
            <div class="stat-num"><asp:Literal ID="litTotal"     runat="server" Text="0" /></div>
            <div class="stat-lbl">Total Trips</div>
        </div>
        <div class="stat-card">
            <div class="stat-num"><asp:Literal ID="litUpcoming"  runat="server" Text="0" /></div>
            <div class="stat-lbl">Upcoming</div>
        </div>
        <div class="stat-card">
            <div class="stat-num"><asp:Literal ID="litCompleted" runat="server" Text="0" /></div>
            <div class="stat-lbl">Completed</div>
        </div>
        <div class="stat-card">
            <div class="stat-num">£<asp:Literal ID="litSpend" runat="server" Text="0.00" /></div>
            <div class="stat-lbl">Est. Total Spend</div>
        </div>
    </div>

    <!-- Loyalty tier badge -->
    <asp:Literal ID="litLoyaltyTier" runat="server" />

    <div class="quick-links">
        <a href="BrowseFleet.aspx" class="btn btn-teal">Book a Vehicle</a>
        <a href="ContributorApply.aspx" class="btn btn-ghost">Become a Contributor</a>
        <a href="Default.aspx"     class="btn btn-ghost" style="font-size:.8rem;">&#8592; Home</a>
    </div>

    <div class="section-title">My Trip Records</div>

    <asp:Panel ID="pnlTrips" runat="server">
        <div class="trip-table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>Trip ID</th>
                        <th>Vehicle</th>
                        <th>Type</th>
                        <th>Pickup</th>
                        <th>Drop-off</th>
                        <th>Driver</th>
                        <th>Insurance</th>
                        <th>Add-Ons</th>
                        <th>Rate</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptTrips" runat="server" OnItemCommand="rptTrips_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td><span class="trip-id">#<%# Eval("CustomerTripID") %></span></td>
                                <td>
                                    <div class="vehicle-name"><%# Eval("VehicleMake") %> <%# Eval("VehicleModel") %></div>
                                    <div class="reg-no"><%# Eval("RegistrationNo") %></div>
                                </td>
                                <td><span class="type-chip"><%# Eval("TypeName") %></span></td>
                                <td>
                                    <div class="location-main"><%# Eval("PickupLocation") %></div>
                                    <div class="location-date"><%# Convert.ToDateTime(Eval("PickupDate")).ToString("dd MMM yyyy HH:mm") %></div>
                                </td>
                                <td>
                                    <div class="location-main"><%# Eval("DropoffLocation") %></div>
                                    <div class="location-date"><%# FormatDate(Eval("DropoffDate")) %></div>
                                </td>
                                <td><span class="driver-cell"><%# FormatDriverLink(Eval("DriverName"), Eval("DriverID")) %></span></td>
                                <td><span class="type-chip"><%# FormatInsurance(Eval("InsuranceTier")) %></span></td>
                                <td><span class="notes-cell" title='<%# Eval("Addons") %>'><%# FormatAddons(Eval("Addons")) %></span></td>
                                <td><span class="rate">£<%# Convert.ToDecimal(Eval("BaseRate")).ToString("N2") %></span></td>
                                <td><%# GetStatusBadge(Eval("PickupDate"), Eval("TripIsActive"), Eval("CarReturned")) %></td>
                                <td>
                                    <%-- Cancel only available if upcoming, active, and NOT already returned by staff --%>
                                    <asp:LinkButton ID="lnkCancel" runat="server"
                                        CommandName="CancelTrip"
                                        CommandArgument='<%# Eval("CustomerTripID") %>'
                                        Visible='<%# Convert.ToDateTime(Eval("PickupDate")).Date >= DateTime.Today && Convert.ToBoolean(Eval("TripIsActive")) && !Convert.ToBoolean(Eval("CarReturned")) %>'
                                        CssClass="cancel-btn"
                                        OnClientClick="return confirm('Cancel this booking? This action cannot be undone.');"
                                        CausesValidation="false">Cancel</asp:LinkButton>
                                    <asp:Label ID="lblCancelNA" runat="server"
                                        Visible='<%# Convert.ToDateTime(Eval("PickupDate")).Date < DateTime.Today || !Convert.ToBoolean(Eval("TripIsActive")) || Convert.ToBoolean(Eval("CarReturned")) %>'
                                        style="color:#64748b;font-size:.78rem;">&#8212;</asp:Label>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="empty-state">
            <div class="empty-icon"></div>
            <h3>No trips yet</h3>
            <p>You have not made any bookings. Browse our fleet to get started.</p>
            <a href="BrowseFleet.aspx" class="btn btn-teal">Browse Our Fleet</a>
        </div>
    </asp:Panel>

    <!-- ─── E-RECEIPTS ──────────────────────────────────────────── -->
    <div style="margin-top:2.5rem;">
        <div class="section-title">My E-Receipts</div>

        <asp:Panel ID="pnlReceipts" runat="server">
            <asp:Repeater ID="rptReceipts" runat="server">
                <ItemTemplate>
                    <div style="background:rgba(26,35,50,.8);border:1px solid rgba(255,255,255,.08);border-radius:14px;padding:1.4rem 1.6rem;margin-bottom:1rem;display:flex;align-items:flex-start;justify-content:space-between;gap:1rem;flex-wrap:wrap;">
                        <div>
                            <div style="font-size:.72rem;text-transform:uppercase;letter-spacing:.08em;color:#0d9488;margin-bottom:.3rem;">DriveNow E-Receipt</div>
                            <div style="font-family:'Outfit',Arial,sans-serif;font-size:1rem;font-weight:700;color:#fff;margin-bottom:.2rem;">
                                <%# Eval("VehicleMake") %> <%# Eval("VehicleModel") %>
                            </div>
                            <div style="font-size:.78rem;color:#64748b;">
                                Ref: #DN-<%# Eval("CustomerTripID") %> &nbsp;&middot;&nbsp;
                                <%# Convert.ToDateTime(Eval("PickupDate")).ToString("dd MMM yyyy") %>
                                &#8594; <%# FormatDateShort(Eval("DropoffDate")) %>
                            </div>
                            <div style="font-size:.78rem;color:#64748b;margin-top:.2rem;">
                                <%# Eval("PickupLocation") %> &#8594; <%# Eval("DropoffLocation") %>
                            </div>
                        </div>
                        <div style="text-align:right;flex-shrink:0;">
                            <div style="font-family:'Outfit',Arial,sans-serif;font-size:1.5rem;font-weight:800;color:#14b8a6;">
                                &pound;<%# Convert.ToDecimal(Eval("BaseRate")).ToString("N2") %>
                            </div>
                            <div style="font-size:.72rem;color:#64748b;margin-bottom:.6rem;">Estimated total</div>
                            <button type="button"
                                onclick="printReceipt('<%# Eval("CustomerTripID") %>','<%# Eval("VehicleMake") %> <%# Eval("VehicleModel") %>','<%# Eval("PickupLocation") %>','<%# Eval("DropoffLocation") %>','<%# Convert.ToDateTime(Eval("PickupDate")).ToString("dd MMM yyyy") %>','&pound;<%# Convert.ToDecimal(Eval("BaseRate")).ToString("N2") %>')"
                                style="background:rgba(13,148,136,.15);border:1px solid rgba(13,148,136,.35);color:#14b8a6;padding:.35rem .9rem;border-radius:22px;font-size:.75rem;cursor:pointer;font-weight:600;">
                                Print / Save as PDF
                            </button>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>

        <asp:Panel ID="pnlNoReceipts" runat="server" Visible="false">
            <div style="background:rgba(26,35,50,.5);border:1px solid rgba(255,255,255,.06);border-radius:14px;padding:2rem;text-align:center;">
                <div style="margin-bottom:.75rem;"></div>
                <div style="font-size:.95rem;font-weight:600;color:#fff;margin-bottom:.4rem;">No receipts yet</div>
                <div style="font-size:.83rem;color:#64748b;margin-bottom:1rem;">Your e-receipts will appear here after your first booking is confirmed.</div>
                <a href="BrowseFleet.aspx" class="btn btn-teal btn-sm">Book Your First Trip</a>
            </div>
        </asp:Panel>
    </div>

    <!-- ─── EDIT PROFILE ──────────────────────────────────────────── -->
    <div class="edit-profile-card">
        <div class="ep-title">&#9998; Edit My Profile</div>

        <asp:Label ID="lblProfileMsg" runat="server" Visible="false" />

        <div class="ep-row">
            <div class="ep-field">
                <label>Email Address</label>
                <asp:TextBox ID="txtEditEmail" runat="server" TextMode="Email" MaxLength="150" placeholder="your@email.com" />
                <asp:RegularExpressionValidator ID="revEditEmail" runat="server"
                    ControlToValidate="txtEditEmail" CssClass="val-hint" Display="Dynamic"
                    ErrorMessage="Enter a valid email address."
                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" />
            </div>
            <div class="ep-field">
                <label>Phone Number</label>
                <asp:TextBox ID="txtEditPhone" runat="server" MaxLength="20" placeholder="+45 70 00 00 00" />
            </div>
        </div>

        <!-- Ethical / GDPR consent -->
        <div class="ep-consent">
            <strong>Data Protection Notice</strong><br />
            Updating your contact details means DriveNow will store the revised information (email address, phone number) in your customer account. This data is used solely for booking confirmation and customer support purposes, in accordance with GDPR Article 6(1)(b).
            <div class="ep-consent-check">
                <asp:CheckBox ID="chkProfileConsent" runat="server" />
                <span>I confirm these details are correct and I consent to DriveNow updating my personal data as described. *</span>
            </div>
            <asp:Label ID="lblProfileConsentError" runat="server" CssClass="val-hint" Visible="false" Text="You must confirm your consent before saving changes." />
        </div>

        <asp:Button ID="btnSaveProfile" runat="server" Text="Save Changes"
            CssClass="ep-save-btn"
            OnClick="btnSaveProfile_Click"
            CausesValidation="false" />
    </div>

    <!-- ─── CHANGE PASSWORD ──────────────────────────────────────────── -->
    <div class="edit-profile-card" style="margin-top:1.5rem;">
        <div class="ep-title">Change Password</div>

        <asp:Label ID="lblChangePwMsg" runat="server" Visible="false" />

        <div class="ep-row">
            <div class="ep-field">
                <label>New Password</label>
                <asp:TextBox ID="txtNewPw" runat="server" TextMode="Password" placeholder="At least 8 characters" />
            </div>
            <div class="ep-field">
                <label>Confirm New Password</label>
                <asp:TextBox ID="txtConfirmPw" runat="server" TextMode="Password" placeholder="Re-enter new password" />
            </div>
        </div>

        <asp:Button ID="btnChangePassword" runat="server" Text="Update Password"
            CssClass="ep-save-btn"
            OnClick="btnChangePassword_Click"
            CausesValidation="false" />
    </div>

</div>

<!-- Receipt print popup -->
<div id="receiptPrintModal" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,.65);z-index:9999;align-items:center;justify-content:center;">
    <div id="receiptCard" style="background:#fff;border-radius:16px;padding:2.5rem;max-width:460px;width:90%;color:#0f172a;font-family:Arial,sans-serif;">
        <div style="text-align:center;margin-bottom:1.5rem;">
            <div style="font-size:1.4rem;font-weight:800;color:#0d9488;margin-bottom:.2rem;">DriveNow</div>
            <div style="font-size:.75rem;color:#64748b;text-transform:uppercase;letter-spacing:.1em;">Official E-Receipt</div>
        </div>
        <hr style="border:none;border-top:1px solid #e2e8f0;margin:0 0 1.2rem;" />
        <div id="receiptBody" style="font-size:.88rem;line-height:2;color:#334155;"></div>
        <hr style="border:none;border-top:1px solid #e2e8f0;margin:1.2rem 0;" />
        <div style="font-size:.72rem;color:#94a3b8;text-align:center;">This is an electronic receipt. DriveNow &middot; support@drivenow.dk &middot; CTEC2713N</div>
        <div style="display:flex;gap:.75rem;justify-content:flex-end;margin-top:1.4rem;">
            <button type="button" onclick="document.getElementById('receiptPrintModal').style.display='none';" style="background:#f1f5f9;border:1px solid #e2e8f0;color:#475569;padding:.5rem 1.2rem;border-radius:22px;font-size:.83rem;cursor:pointer;">Close</button>
            <button type="button" onclick="window.print();" style="background:#0d9488;border:none;color:#fff;padding:.5rem 1.4rem;border-radius:22px;font-size:.83rem;font-weight:600;cursor:pointer;">Print</button>
        </div>
    </div>
</div>

</form>
<script>
    function printReceipt(id, vehicle, pickup, dropoff, date, amount) {
        document.getElementById('receiptBody').innerHTML =
            '<div><strong>Receipt No:</strong> DN-' + id + '</div>' +
            '<div><strong>Date Issued:</strong> ' + new Date().toLocaleDateString('en-GB', {day:'numeric',month:'long',year:'numeric'}) + '</div>' +
            '<div><strong>Vehicle:</strong> ' + vehicle + '</div>' +
            '<div><strong>Pickup:</strong> ' + pickup + '</div>' +
            '<div><strong>Drop-off:</strong> ' + dropoff + '</div>' +
            '<div><strong>Trip Date:</strong> ' + date + '</div>' +
            '<div style="margin-top:.5rem;font-size:1.1rem;font-weight:700;color:#0d9488;"><strong>Total:</strong> ' + amount + '</div>';
        document.getElementById('receiptPrintModal').style.display = 'flex';
    }
    document.getElementById('receiptPrintModal').addEventListener('click', function(e) {
        if (e.target === this) this.style.display = 'none';
    });
</script>
</body>
</html>

