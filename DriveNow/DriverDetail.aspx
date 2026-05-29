<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DriverDetail.aspx.cs" Inherits="DriveNow.DriverDetail" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Driver Profile</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <link rel="stylesheet" href="Content/Site.css"/>
    <style>
        .driver-avatar{width:72px;height:72px;border-radius:50%;background:linear-gradient(135deg,#0d9488,#0891b2);display:flex;align-items:center;justify-content:center;font-size:1.6rem;font-weight:800;color:#fff;overflow:hidden;flex-shrink:0;}
        .driver-avatar img{width:72px;height:72px;border-radius:50%;object-fit:cover;}
        .profile-hero{display:flex;align-items:center;gap:1.4rem;margin-bottom:1.2rem;}
        .profile-name{font-size:1.25rem;font-weight:800;color:#fff;margin-bottom:.25rem;}
        .profile-exp{font-size:.82rem;color:#5eead4;margin-bottom:.35rem;}
        .stars{display:inline-flex;align-items:center;gap:.1rem;font-size:1rem;}
        .star-full{color:#fbbf24;}
        .star-empty{color:rgba(255,255,255,.18);}
        .rating-num{font-size:.8rem;color:#fbbf24;font-weight:700;margin-left:.3rem;}
        .no-rating{font-size:.78rem;color:#64748b;font-style:italic;}
        .gender-badge{display:inline-block;padding:.2rem .65rem;border-radius:99px;font-size:.75rem;font-weight:700;border:1px solid;margin-right:.3rem;}
        .gender-m{background:rgba(59,130,246,.1);border-color:rgba(59,130,246,.25);color:#93c5fd;}
        .gender-f{background:rgba(236,72,153,.1);border-color:rgba(236,72,153,.25);color:#f9a8d4;}
        .gender-x{background:rgba(139,92,246,.1);border-color:rgba(139,92,246,.25);color:#c4b5fd;}
        .specialty-badge{display:inline-block;padding:.2rem .65rem;border-radius:99px;font-size:.75rem;font-weight:600;background:rgba(13,148,136,.12);border:1px solid rgba(13,148,136,.3);color:#5eead4;}
        .bio-empty{color:#64748b;font-style:italic;font-size:.85rem;}
        .detail-grid{display:grid;grid-template-columns:1fr 1fr;gap:.5rem 2rem;}
        .detail-row{padding:.5rem 0;border-bottom:1px solid rgba(255,255,255,.05);}
        .detail-row:last-child{border-bottom:none;}
        .detail-lbl{font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:.07em;color:#64748b;margin-bottom:.15rem;}
        .detail-val{font-size:.88rem;color:#e2e8f0;font-weight:600;}
        .sensitive-banner{background:rgba(251,191,36,.07);border:1px solid rgba(251,191,36,.2);border-radius:10px;padding:.75rem 1rem;font-size:.78rem;color:#fbbf24;margin-bottom:1rem;line-height:1.55;}
        .rating-row{display:flex;align-items:center;gap:.8rem;flex-wrap:wrap;margin-top:.5rem;}
        .rating-msg{font-size:.82rem;display:block;margin-top:.4rem;}
        .rating-msg-ok{color:#4ade80;}
        .rating-msg-err{color:#fca5a5;}
        .not-found-box{text-align:center;padding:3rem 1rem;}
        .not-found-box h2{font-size:1.2rem;font-weight:700;color:#94a3b8;margin-bottom:.5rem;}
        .not-found-box p{color:#64748b;margin-bottom:1.2rem;font-size:.9rem;}
        .form-section-head{font-size:.7rem;font-weight:700;letter-spacing:.09em;text-transform:uppercase;color:#14b8a6;margin:1.2rem 0 .7rem;padding-bottom:.4rem;border-bottom:1px solid rgba(255,255,255,.07);}
    </style>
</head>
<body>
<form id="form1" runat="server">
<div class="dn-shell">

    <!-- SIDEBAR -->
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo"><img src="Content/logo.png" alt="DriveNow"/></div>
        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">MAIN</div>
            <a href="MainMenu.aspx"        class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">dashboard</span> Dashboard</a>
            <div class="dn-nav-label">NAVIGATE</div>
            <a href="TripList.aspx"        class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">route</span> Trips</a>
            <a href="TripTypeList.aspx"    class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">category</span> Trip Types</a>
            <a href="CustomerList.aspx"    class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">group</span> Customers</a>
            <a href="DriverList.aspx"      class="dn-nav-item active"><span class="material-symbols-outlined" style="font-size:17px;">person</span> Drivers</a>
            <a href="VehicleList.aspx"     class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">directions_car</span> Vehicles</a>
            <a href="ContributorList.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">handshake</span> Contributors</a>
            <div class="dn-nav-label">ADMIN</div>
            <a href="TempPasswords.aspx"   class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">key</span> Temp Passwords</a>
            <a href="StaffList.aspx"       class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">badge</span> Staff</a>
        </nav>
        <div class="dn-sidebar-footer">
            <a href="StaffProfile.aspx" style="text-decoration:none;">
                <div class="dn-sidebar-user">
                    <div class="dn-sidebar-avatar"><%= (Session["Username"] != null ? Session["Username"].ToString().Substring(0,1).ToUpper() : "A") %></div>
                    <div>
                        <div class="dn-sidebar-name"><%= Session["Username"] ?? "Admin" %></div>
                        <div class="dn-sidebar-role">Staff Portal &rsaquo;</div>
                    </div>
                </div>
            </a>
            <a href="Logout.aspx" class="dn-sidebar-logout">Sign Out</a>
        </div>
    </div>

    <!-- MAIN -->
    <div class="dn-main">
        <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
            <div class="dn-topbar-left">
                <span class="dn-page-title">Driver Profile</span>
                <span class="dn-page-sub">Staff view — confidential driver information</span>
            </div>
            <div class="dn-topbar-right">
                <asp:HyperLink ID="lnkNavBack" runat="server" CssClass="dn-btn dn-btn-secondary dn-btn-sm" Text="&#8592; Driver List" NavigateUrl="DriverList.aspx" />
            </div>
        </div>

        <div class="dn-content">

            <asp:Panel ID="pnlNotFound" runat="server" Visible="false">
                <div class="dn-form-card">
                    <div class="not-found-box">
                        <h2>Driver Not Found</h2>
                        <p>The driver profile you are looking for does not exist or is no longer active.</p>
                        <a href="DriverList.aspx" class="dn-btn dn-btn-primary">Back to Driver List</a>
                    </div>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlProfile" runat="server" Visible="false">

                <!-- Profile card -->
                <div class="dn-form-card" style="margin-bottom:1rem;">
                    <div class="profile-hero">
                        <div class="driver-avatar"><asp:Literal ID="litAvatarContent" runat="server" /></div>
                        <div>
                            <div class="profile-name"><asp:Literal ID="litName" runat="server" /></div>
                            <div class="profile-exp"><asp:Literal ID="litExp" runat="server" /></div>
                            <asp:Literal ID="litStars" runat="server" />
                            <div style="margin-top:.4rem;">
                                <asp:Literal ID="litGenderBadge" runat="server" />
                                <asp:Literal ID="litSpecialtyBadge" runat="server" />
                            </div>
                        </div>
                    </div>
                    <div style="color:#94a3b8;font-size:.9rem;line-height:1.7;border-top:1px solid rgba(255,255,255,.07);padding-top:.9rem;">
                        <asp:Literal ID="litBio" runat="server" />
                    </div>
                </div>

                <!-- Public: join date -->
                <asp:Panel ID="pnlPublicInfo" runat="server">
                    <div class="dn-form-card" style="margin-bottom:1rem;">
                        <div class="form-section-head">Driver Details</div>
                        <div class="detail-row"><div class="detail-lbl">Member Since</div><div class="detail-val"><asp:Literal ID="litJoinDate" runat="server" /></div></div>
                        <div class="detail-row"><div class="detail-lbl">Status</div><div class="detail-val" style="color:#4ade80;">Active Driver</div></div>
                    </div>
                </asp:Panel>

                <!-- Admin: confidential details + actions -->
                <asp:Panel ID="pnlAdminInfo" runat="server" Visible="false">
                    <div class="sensitive-banner">&#9888; Sensitive personal data — visible to authorised staff only. Do not share outside the portal. Processed under GDPR Article 6(1)(b).</div>

                    <div class="dn-form-card" style="margin-bottom:1rem;">
                        <div class="form-section-head">Confidential — Staff View</div>
                        <div class="detail-grid">
                            <div class="detail-row"><div class="detail-lbl">Driver ID</div><div class="detail-val"><asp:Literal ID="litAdminID" runat="server" /></div></div>
                            <div class="detail-row"><div class="detail-lbl">Phone</div><div class="detail-val"><asp:Literal ID="litAdminPhone" runat="server" /></div></div>
                            <div class="detail-row"><div class="detail-lbl">Licence Number</div><div class="detail-val"><asp:Literal ID="litAdminLicence" runat="server" /></div></div>
                            <div class="detail-row"><div class="detail-lbl">Date of Birth</div><div class="detail-val"><asp:Literal ID="litAdminDOB" runat="server" /></div></div>
                            <div class="detail-row"><div class="detail-lbl">Join Date</div><div class="detail-val"><asp:Literal ID="litAdminJoin" runat="server" /></div></div>
                            <div class="detail-row"><div class="detail-lbl">Status</div><div class="detail-val"><asp:Literal ID="litAdminStatus" runat="server" /></div></div>
                        </div>
                    </div>

                    <!-- Rating panel -->
                    <div class="dn-form-card" style="margin-bottom:1rem;">
                        <div class="form-section-head">Performance Rating</div>
                        <p style="font-size:.82rem;color:#64748b;margin-bottom:.8rem;">Update this driver's star rating based on performance reviews and customer feedback.</p>
                        <div class="rating-row">
                            <asp:DropDownList ID="ddlRating" runat="server" CssClass="dn-select" style="width:auto;min-width:220px;">
                                <asp:ListItem Value="">-- Select Rating --</asp:ListItem>
                                <asp:ListItem Value="5.0">5.0 — Excellent</asp:ListItem>
                                <asp:ListItem Value="4.5">4.5 — Very Good</asp:ListItem>
                                <asp:ListItem Value="4.0">4.0 — Good</asp:ListItem>
                                <asp:ListItem Value="3.5">3.5 — Above Average</asp:ListItem>
                                <asp:ListItem Value="3.0">3.0 — Average</asp:ListItem>
                                <asp:ListItem Value="2.5">2.5 — Below Average</asp:ListItem>
                                <asp:ListItem Value="2.0">2.0 — Poor</asp:ListItem>
                                <asp:ListItem Value="1.0">1.0 — Very Poor</asp:ListItem>
                            </asp:DropDownList>
                            <asp:Button ID="btnUpdateRating" runat="server" Text="Update Rating"
                                CssClass="dn-btn dn-btn-primary dn-btn-sm" OnClick="btnUpdateRating_Click"
                                CausesValidation="false" />
                        </div>
                        <asp:Label ID="lblRatingMsg" runat="server" Visible="false" />
                    </div>

                    <!-- Action buttons -->
                    <div class="dn-form-card">
                        <div class="dn-form-actions">
                            <asp:HyperLink ID="lnkEdit" runat="server" CssClass="dn-btn dn-btn-primary" Text="Edit Driver Details" />
                            <asp:HyperLink ID="lnkBack" runat="server" CssClass="dn-btn dn-btn-secondary" Text="&#8592; Back to Driver List" NavigateUrl="DriverList.aspx" />
                        </div>
                    </div>
                </asp:Panel>

            </asp:Panel>
        </div>

        <div class="dn-footer">DriveNow Admin &middot; CTEC2713N &middot; Niels Brock Copenhagen</div>
    </div>

</div>
</form>
<script>
    /* ── Mobile sidebar toggle ───────────────────────────── */
    function toggleSidebar() {
        document.body.classList.toggle('sidebar-open');
    }
    /* Close sidebar when clicking the dark overlay backdrop */
    document.addEventListener('click', function(e) {
        if (document.body.classList.contains('sidebar-open') &&
            !e.target.closest('.dn-sidebar') &&
            !e.target.closest('.dn-mobile-menu-btn')) {
            document.body.classList.remove('sidebar-open');
        }
    });
</script>
</body>
</html>
