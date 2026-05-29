<%--
    Page: ContributorView.aspx
    Developer: Ushna
    Component: Contributor Applications
    Purpose: Full application detail view for staff. Shows all contributor
             fields including photos, vehicle details and driver credentials.
             Staff can approve & promote the contributor from this page.
             Accessed via ContributorList.aspx?id=X buttons.
--%>
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContributorView.aspx.cs" Inherits="DriveNow.ContributorView" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Application Review</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <link rel="stylesheet" href="Content/Site.css" />
    <style>
        /* ── Sidebar extras ── */
        .dn-sidebar-module { padding:14px 20px 10px; border-bottom:1px solid rgba(255,255,255,.07); margin-bottom:6px; }
        .dn-sidebar-module-label { font-size:10px;letter-spacing:.1em;text-transform:uppercase;color:#14b8a6;margin-bottom:4px; }
        .dn-sidebar-module-title { font-size:15px;font-weight:700;color:#fff; }

        /* ── Two-column layout ── */
        .cv-grid { display:grid; grid-template-columns:1fr 1fr; gap:1.5rem; margin-bottom:1.5rem; }
        @media(max-width:800px){ .cv-grid{ grid-template-columns:1fr; } }

        /* ── CARDS — light-theme consistent with the rest of the admin shell ──
           Site.css sets body { background:#f8fafb } so cards must use
           an explicit light background and DARK text colours.              */
        .cv-card {
            background: #fff;
            border: 1px solid #e5eaef;
            border-radius: 14px;
            padding: 1.4rem;
            box-shadow: 0 1px 4px rgba(0,0,0,.06);
        }
        .cv-card-title { font-size:.72rem; font-weight:700; letter-spacing:.09em; text-transform:uppercase; color:#0d9488; margin-bottom:1rem; }

        .cv-row { display:flex; justify-content:space-between; align-items:flex-start; padding:.55rem 0; border-bottom:1px solid #f1f5f9; }
        .cv-row:last-child { border-bottom:none; }
        .cv-row-label { font-size:.78rem; color:#64748b; min-width:120px; flex-shrink:0; }
        .cv-row-val   { font-size:.88rem; color:#0f172a; text-align:right; word-break:break-word; max-width:260px; font-weight:500; }

        /* ── Type badges ── */
        .cv-type-badge { display:inline-block; padding:.25rem .75rem; border-radius:20px; font-size:.72rem; font-weight:700; letter-spacing:.06em; text-transform:uppercase; }
        .cv-badge-driver   { background:rgba(59,130,246,.10); color:#2563eb; border:1px solid rgba(59,130,246,.25); }
        .cv-badge-owner    { background:rgba(168,85,247,.10);  color:#7c3aed; border:1px solid rgba(168,85,247,.25); }
        .cv-badge-ownerdrv { background:rgba(13,148,136,.10);  color:#0d9488; border:1px solid rgba(13,148,136,.25); }

        /* ── Status pills ── */
        .cv-status-approved { display:inline-flex; align-items:center; gap:.4rem; color:#16a34a; font-size:.82rem; font-weight:600; }
        .cv-status-pending  { display:inline-flex; align-items:center; gap:.4rem; color:#d97706; font-size:.82rem; font-weight:600; }
        .cv-dot { width:8px; height:8px; border-radius:50%; display:inline-block; }
        .cv-dot-green { background:#16a34a; }
        .cv-dot-amber { background:#d97706; }

        /* ── Section panel (driver creds / vehicle details) ── */
        .cv-section { margin-bottom:1.5rem; }
        .cv-section-head { font-size:.72rem; font-weight:700; letter-spacing:.09em; text-transform:uppercase; color:#0d9488; margin-bottom:.85rem; padding-bottom:.5rem; border-bottom:2px solid rgba(13,148,136,.18); }

        /* ── Photo box ── */
        .cv-photo-box { margin-top:.85rem; }
        .cv-photo-box img { border-radius:10px; max-width:100%; max-height:240px; object-fit:cover; border:1px solid #e2e8f0; }

        /* ── Approve panel ── */
        .cv-approve-panel { background:rgba(13,148,136,.06); border:1px solid rgba(13,148,136,.22); border-radius:14px; padding:1.4rem; margin-top:1.5rem; }
        .cv-approve-title { font-size:.9rem; font-weight:700; color:#0d9488; margin-bottom:1rem; }
        .cv-approve-warn  { background:rgba(217,119,6,.08); border:1px solid rgba(217,119,6,.3); border-radius:8px; padding:.75rem 1rem; font-size:.8rem; color:#92400e; margin-bottom:1rem; }
        .cv-override-field { margin-bottom:.85rem; }
        .cv-override-field label { display:block; font-size:.75rem; font-weight:600; text-transform:uppercase; letter-spacing:.06em; color:#64748b; margin-bottom:.35rem; }
        .cv-override-field input { background:#fff; border:1.5px solid #cbd5e1; border-radius:8px; padding:.6rem .85rem; color:#0f172a; font-size:.88rem; width:100%; max-width:260px; }
        .cv-override-field input:focus { outline:none; border-color:#0d9488; box-shadow:0 0 0 3px rgba(13,148,136,.12); }

        /* ── Already-approved banner ── */
        .cv-success-banner { background:rgba(13,148,136,.08); border:1px solid rgba(13,148,136,.3); border-radius:12px; padding:1.1rem 1.3rem; margin-top:1.5rem; }
        .cv-success-banner-title { font-size:.88rem; font-weight:700; color:#0d7a6f; margin-bottom:.45rem; }
        .cv-success-banner-links a { font-size:.8rem; color:#0d9488; text-decoration:none; margin-right:1rem; font-weight:600; }
        .cv-success-banner-links a:hover { text-decoration:underline; }

        .btn-approve-full { background:#0d9488; color:#fff; border:none; border-radius:10px; padding:.7rem 1.6rem; font-size:.9rem; font-weight:700; cursor:pointer; letter-spacing:.02em; transition:background .2s; }
        .btn-approve-full:hover { background:#0f766e; }

        /* ── Responsive ── */
        @media (max-width: 480px) {
            .cv-card { padding: 1rem; }
            .cv-row { flex-direction: column; gap: .2rem; align-items: flex-start; }
            .cv-row-val { text-align: left; max-width: 100%; }
            .cv-row-label { min-width: unset; }
            .cv-approve-panel { padding: 1rem; }
            .cv-override-field input { max-width: 100%; }
            .btn-approve-full { width: 100%; padding: .7rem; }
        }
        @media (max-width: 380px) {
            .cv-card { padding: .85rem; }
            .cv-type-badge { font-size: .65rem; padding: .2rem .6rem; }
            .cv-success-banner { padding: .85rem 1rem; }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">
<div class="dn-shell">

    <!-- SIDEBAR -->
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo">
            <img src="Content/logo.png" alt="DriveNow" />
        </div>

        <div class="dn-sidebar-module">
            <div class="dn-sidebar-module-label">Current Module</div>
            <div class="dn-sidebar-module-title">Contributor Dashboard</div>
        </div>

        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">MAIN</div>
            <a href="MainMenu.aspx"        class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">dashboard</span> Dashboard</a>

            <div class="dn-nav-label">NAVIGATE</div>
            <a href="TripList.aspx"        class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">route</span> Trips</a>
            <a href="TripTypeList.aspx"    class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">category</span> Trip Types</a>
            <a href="CustomerList.aspx"    class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">group</span> Customers</a>
            <a href="DriverList.aspx"      class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">person</span> Drivers</a>
            <a href="VehicleList.aspx"     class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">directions_car</span> Vehicles</a>
            <a href="ContributorList.aspx" class="dn-nav-item active"><span class="material-symbols-outlined" style="font-size:17px;">handshake</span> Contributors</a>
            <div class="dn-nav-label">ADMIN</div>
            <a href="TempPasswords.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">key</span> Temp Passwords</a>
            <a href="StaffList.aspx"       class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">badge</span> Staff</a>
        </nav>

        <div class="dn-sidebar-footer">
            <a href="StaffProfile.aspx" style="text-decoration:none;" title="View your profile">
                <div class="dn-sidebar-user">
                    <div class="dn-sidebar-avatar"><%= (Session["Username"] != null ? Session["Username"].ToString().Substring(0,1).ToUpper() : "?") %></div>
                    <div>
                        <div class="dn-sidebar-name"><%= Session["Username"] %></div>
                        <div class="dn-sidebar-role">Staff Portal &rsaquo;</div>
                    </div>
                </div>
            </a>
            <a href="Logout.aspx" class="dn-sidebar-logout">Sign Out</a>
        </div>
    </div>

    <!-- MAIN PANEL -->
    <div class="dn-main">

        <!-- TOPBAR -->
        <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
            <div class="dn-topbar-left">
                <span class="dn-page-title">Application Review &mdash; #CON-<asp:Label ID="lblPageID" runat="server" Text="?" /></span>
                <span class="dn-page-sub">Full contributor application details</span>
            </div>
            <div class="dn-topbar-right">
                <span class="dn-topbar-date"><asp:Label ID="lblDate" runat="server" /></span>
                <a href="ContributorList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">&larr; Back to List</a>
            </div>
        </div>

        <!-- CONTENT -->
        <div class="dn-content">

            <asp:Label ID="lblMessage" runat="server" Visible="false" />

            <!-- Two-column layout -->
            <div class="cv-grid">

                <!-- LEFT: Application summary -->
                <div class="cv-card">
                    <div class="cv-card-title">Application Summary</div>
                    <div class="cv-row">
                        <span class="cv-row-label">ID</span>
                        <span class="cv-row-val">#CON-<asp:Label ID="lblID" runat="server" /></span>
                    </div>
                    <div class="cv-row">
                        <span class="cv-row-label">Type</span>
                        <span class="cv-row-val"><asp:Label ID="lblTypeBadge" runat="server" /></span>
                    </div>
                    <div class="cv-row">
                        <span class="cv-row-label">Date Applied</span>
                        <span class="cv-row-val"><asp:Label ID="lblApplicationDate" runat="server" /></span>
                    </div>
                    <div class="cv-row">
                        <span class="cv-row-label">Status</span>
                        <span class="cv-row-val"><asp:Label ID="lblStatus" runat="server" /></span>
                    </div>
                    <div class="cv-row">
                        <span class="cv-row-label">Message / Notes</span>
                        <span class="cv-row-val"><asp:Label ID="lblNotes" runat="server" Text="—" /></span>
                    </div>
                </div>

                <!-- RIGHT: Personal details -->
                <div class="cv-card">
                    <div class="cv-card-title">Personal Details</div>
                    <div class="cv-row">
                        <span class="cv-row-label">Full Name</span>
                        <span class="cv-row-val"><asp:Label ID="lblFullName" runat="server" /></span>
                    </div>
                    <div class="cv-row">
                        <span class="cv-row-label">Email</span>
                        <span class="cv-row-val"><asp:Label ID="lblEmail" runat="server" /></span>
                    </div>
                    <div class="cv-row">
                        <span class="cv-row-label">Phone</span>
                        <span class="cv-row-val"><asp:Label ID="lblPhone" runat="server" /></span>
                    </div>
                </div>

            </div>

            <!-- DRIVER CREDENTIALS (shown for Driver or OwnerDriver) -->
            <asp:Panel ID="pnlDriverCreds" runat="server" Visible="false" CssClass="cv-card cv-section" style="margin-bottom:1.5rem;">
                <div class="cv-section-head">Driver Credentials</div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;">
                    <div>
                        <div class="cv-row">
                            <span class="cv-row-label">Licence Number</span>
                            <span class="cv-row-val"><asp:Label ID="lblLicenceNumber" runat="server" Text="—" /></span>
                        </div>
                        <div class="cv-row">
                            <span class="cv-row-label">Date of Birth</span>
                            <span class="cv-row-val"><asp:Label ID="lblDateOfBirth" runat="server" Text="—" /></span>
                        </div>
                        <div class="cv-row">
                            <span class="cv-row-label">Licence Issued</span>
                            <span class="cv-row-val"><asp:Label ID="lblLicenceIssue" runat="server" Text="—" /></span>
                        </div>
                        <div class="cv-row">
                            <span class="cv-row-label">Licence Expiry</span>
                            <span class="cv-row-val"><asp:Label ID="lblLicenceExpiry" runat="server" Text="—" /></span>
                        </div>
                    </div>
                    <div>
                        <div class="cv-photo-box">
                            <asp:Panel ID="pnlProfilePhoto" runat="server" Visible="false">
                                <div style="font-size:.72rem;color:#94a3b8;margin-bottom:.4rem;">Profile Photo</div>
                                <asp:Image ID="imgProfilePhoto" runat="server" CssClass="" style="border-radius:10px;max-width:100%;max-height:200px;object-fit:cover;border:1px solid rgba(255,255,255,.1);" />
                            </asp:Panel>
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <!-- VEHICLE DETAILS (shown for VehicleOwner or OwnerDriver) -->
            <asp:Panel ID="pnlVehicleDetails" runat="server" Visible="false" CssClass="cv-card cv-section" style="margin-bottom:1.5rem;">
                <div class="cv-section-head">Vehicle Details</div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;">
                    <div>
                        <div class="cv-row">
                            <span class="cv-row-label">Make</span>
                            <span class="cv-row-val"><asp:Label ID="lblVehicleMake" runat="server" Text="—" /></span>
                        </div>
                        <div class="cv-row">
                            <span class="cv-row-label">Model</span>
                            <span class="cv-row-val"><asp:Label ID="lblVehicleModel" runat="server" Text="—" /></span>
                        </div>
                        <div class="cv-row">
                            <span class="cv-row-label">Year</span>
                            <span class="cv-row-val"><asp:Label ID="lblVehicleYear" runat="server" Text="—" /></span>
                        </div>
                        <div class="cv-row">
                            <span class="cv-row-label">Registration</span>
                            <span class="cv-row-val"><asp:Label ID="lblVehicleReg" runat="server" Text="—" /></span>
                        </div>
                        <div class="cv-row">
                            <span class="cv-row-label">Colour</span>
                            <span class="cv-row-val"><asp:Label ID="lblVehicleColour" runat="server" Text="—" /></span>
                        </div>
                        <div class="cv-row">
                            <span class="cv-row-label">Seats</span>
                            <span class="cv-row-val"><asp:Label ID="lblVehicleSeats" runat="server" Text="—" /></span>
                        </div>
                        <div class="cv-row">
                            <span class="cv-row-label">Daily Rate</span>
                            <span class="cv-row-val">&pound;<asp:Label ID="lblVehicleDailyRate" runat="server" Text="—" /></span>
                        </div>
                    </div>
                    <div>
                        <div class="cv-photo-box">
                            <asp:Panel ID="pnlVehiclePhoto" runat="server" Visible="false">
                                <div style="font-size:.72rem;color:#94a3b8;margin-bottom:.4rem;">Vehicle Photo</div>
                                <asp:Image ID="imgVehiclePhoto" runat="server" style="border-radius:10px;max-width:100%;max-height:200px;object-fit:cover;border:1px solid rgba(255,255,255,.1);" />
                            </asp:Panel>
                            <%-- Placeholder shown when no photo is uploaded --%>
                            <asp:Panel ID="pnlNoVehiclePhotoView" runat="server" Visible="false">
                                <div style="font-size:.72rem;color:#94a3b8;margin-bottom:.4rem;">Vehicle Photo</div>
                                <div style="width:180px;height:110px;border:2px dashed #cbd5e1;border-radius:10px;display:flex;align-items:center;justify-content:center;color:#64748b;font-size:.75rem;flex-direction:column;gap:.35rem;background:#f8fafb;">
                                    <span class="material-symbols-outlined" style="font-size:28px;color:#94a3b8;">directions_car</span>
                                    No photo uploaded
                                </div>
                                <div style="margin-top:.5rem;">
                                    <a href='<%# "ContributorEdit.aspx?id=" + Request.QueryString["id"] %>' class="dn-btn dn-btn-secondary dn-btn-sm" style="font-size:.75rem;">Upload Photo</a>
                                </div>
                            </asp:Panel>
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <!-- ACTION BAR -->

            <!-- APPROVE PANEL (pending contributors) -->
            <asp:Panel ID="pnlApprove" runat="server" Visible="false" CssClass="cv-approve-panel">
                <div class="cv-approve-title">Approve &amp; Promote Application</div>

                <!-- Warning: missing DOB for driver types -->
                <asp:Panel ID="pnlWarnDOB" runat="server" Visible="false" CssClass="cv-approve-warn">
                    Date of Birth is missing. Please enter it before approving a driver applicant.
                    <div class="cv-override-field" style="margin-top:.6rem;">
                        <label for="<%= txtOverrideDOB.ClientID %>">Date of Birth override</label>
                        <asp:TextBox ID="txtOverrideDOB" runat="server" TextMode="Date" />
                    </div>
                </asp:Panel>

                <!-- Warning: missing daily rate for vehicle types -->
                <asp:Panel ID="pnlWarnRate" runat="server" Visible="false" CssClass="cv-approve-warn">
                    Daily Rate is missing. Please enter it before approving a vehicle applicant.
                    <div class="cv-override-field" style="margin-top:.6rem;">
                        <label for="<%= txtOverrideRate.ClientID %>">Daily Rate override (&pound;/day)</label>
                        <asp:TextBox ID="txtOverrideRate" runat="server" TextMode="Number" placeholder="e.g. 75.00" />
                    </div>
                </asp:Panel>

                <asp:Button ID="btnApproveFull" runat="server" Text="&#10003; Approve &amp; Promote"
                    CssClass="btn-approve-full"
                    OnClick="btnApproveFull_Click"
                    OnClientClick="return confirm('Approve this application and promote the contributor into the fleet?');" />
            </asp:Panel>

            <!-- SUCCESS BANNER (already approved) -->
            <asp:Panel ID="pnlApprovedBanner" runat="server" Visible="false" CssClass="cv-success-banner">
                <div class="cv-success-banner-title">&#10003; Application Approved</div>
                <div class="cv-success-banner-links">
                    <asp:HyperLink ID="lnkDriver"  runat="server" Visible="false" />
                    <asp:HyperLink ID="lnkVehicle" runat="server" Visible="false" />
                </div>
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
