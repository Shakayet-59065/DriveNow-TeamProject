<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StaffProfile.aspx.cs" Inherits="DriveNow.StaffProfile" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Staff Profile</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <link rel="stylesheet" href="Content/Site.css" />
    <style>
        .dn-sidebar-module{padding:14px 20px 10px;border-bottom:1px solid rgba(255,255,255,.07);margin-bottom:6px;}
        .dn-sidebar-module-label{font-size:10px;letter-spacing:.1em;text-transform:uppercase;color:#14b8a6;margin-bottom:4px;}
        .dn-sidebar-module-title{font-size:15px;font-weight:700;color:#fff;}
        .profile-card{background:#1e293b;border-radius:16px;padding:2rem;margin-bottom:1.5rem;}
        .profile-avatar-lg{width:80px;height:80px;border-radius:50%;background:linear-gradient(135deg,#0d9488,#1a2332);display:flex;align-items:center;justify-content:center;font-size:2rem;font-weight:700;color:#fff;margin-bottom:1rem;}
        .profile-field{margin-bottom:1rem;}
        .profile-field label{display:block;font-size:.75rem;text-transform:uppercase;letter-spacing:.08em;color:#64748b;margin-bottom:.35rem;}
        .profile-field .pf-value{font-size:.95rem;color:#e2e8f0;font-weight:500;}
        .profile-grid{display:grid;grid-template-columns:1fr 1fr;gap:1rem;}
        .stat-box{background:#0f172a;border-radius:12px;padding:1.25rem;text-align:center;}
        .stat-box .sb-num{font-size:2rem;font-weight:800;color:#14b8a6;}
        .stat-box .sb-lbl{font-size:.78rem;color:#64748b;margin-top:.25rem;}

        /* Edit form */
        .edit-card{background:#1e293b;border-radius:16px;padding:2rem;margin-bottom:1.5rem;border:1px solid rgba(13,148,136,.25);}
        .edit-card-title{font-size:1rem;font-weight:700;color:#fff;margin-bottom:1.4rem;padding-bottom:.75rem;border-bottom:1px solid rgba(255,255,255,.07);display:flex;align-items:center;gap:.5rem;}
        .edit-field{margin-bottom:1.1rem;}
        .edit-field label{display:block;font-size:.74rem;font-weight:600;text-transform:uppercase;letter-spacing:.08em;color:#14b8a6;margin-bottom:.38rem;}
        .edit-field input{width:100%;background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.12);border-radius:8px;padding:.65rem .9rem;color:#fff;font-size:.9rem;font-family:inherit;outline:none;transition:border-color .2s;}
        .edit-field input:focus{border-color:#0d9488;}
        .edit-field input[readonly]{opacity:.5;cursor:not-allowed;}
        .edit-row{display:grid;grid-template-columns:1fr 1fr;gap:1rem;}
        .consent-box{background:rgba(13,148,136,.07);border:1px solid rgba(13,148,136,.2);border-radius:10px;padding:1rem 1.1rem;margin-bottom:1.2rem;font-size:.8rem;color:#5eead4;line-height:1.65;}
        .consent-check{display:flex;align-items:flex-start;gap:.65rem;margin-top:.75rem;}
        .consent-check input[type=checkbox]{margin-top:2px;width:16px;height:16px;accent-color:#0d9488;flex-shrink:0;cursor:pointer;}
        .consent-check span{font-size:.8rem;color:#94a3b8;line-height:1.5;}
        .alert-success{background:rgba(13,148,136,.15);border:1px solid rgba(13,148,136,.35);color:#5eead4;padding:.85rem 1.1rem;border-radius:10px;margin-bottom:1.2rem;font-size:.88rem;}
        .alert-error{background:rgba(239,68,68,.12);border:1px solid rgba(239,68,68,.3);color:#fca5a5;padding:.85rem 1.1rem;border-radius:10px;margin-bottom:1.2rem;font-size:.88rem;}
        .val-hint{color:#fca5a5;font-size:.75rem;margin-top:.25rem;}
        .divider-thin{border:none;border-top:1px solid rgba(255,255,255,.07);margin:1.2rem 0;}
        .section-label{font-size:.72rem;font-weight:700;letter-spacing:.09em;text-transform:uppercase;color:#64748b;margin-bottom:.8rem;}
    </style>
</head>
<body>
<form id="frmStaffProfile" runat="server">
<div class="dn-shell">

    <!-- SIDEBAR -->
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo"><img src="Content/logo.png" alt="DriveNow" /></div>

        <div class="dn-sidebar-module">
            <div class="dn-sidebar-module-label">Current Module</div>
            <div class="dn-sidebar-module-title">My Profile</div>
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
            <a href="ContributorList.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">handshake</span> Contributors</a>
            <div class="dn-nav-label">ADMIN</div>
            <a href="TempPasswords.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">key</span> Temp Passwords</a>
            <a href="StaffList.aspx"       class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">badge</span> Staff</a>
        </nav>

        <div class="dn-sidebar-footer">
            <a href="StaffProfile.aspx" style="text-decoration:none;">
                <div class="dn-sidebar-user">
                    <div class="dn-sidebar-avatar"><%= (Session["Username"] != null ? Session["Username"].ToString().Substring(0,1).ToUpper() : "?") %></div>
                    <div>
                        <div class="dn-sidebar-name"><asp:Label ID="lblSidebarName" runat="server" Text="Admin" /></div>
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
                <span class="dn-page-title">Staff Profile</span>
                <span class="dn-page-sub">Your account details and session information</span>
            </div>
            <div class="dn-topbar-right">
                <a href="MainMenu.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">&#8592; Dashboard</a>
            </div>
        </div>

        <div class="dn-content">

            <!-- ── Profile overview card ─────────────────────────── -->
            <div class="profile-card">
                <div class="profile-avatar-lg">
                    <asp:Label ID="lblAvatarLetter" runat="server" Text="A" />
                </div>
                <div style="margin-bottom:1.5rem;">
                    <div style="font-size:1.3rem;font-weight:700;color:#fff;">
                        <asp:Label ID="lblFullName" runat="server" />
                    </div>
                    <div style="font-size:.85rem;color:#14b8a6;margin-top:.2rem;"><asp:Label ID="lblRoleDisplay" runat="server" Text="DriveNow Staff Member" /></div>
                </div>

                <div class="profile-grid">
                    <div class="profile-field">
                        <label>Username</label>
                        <div class="pf-value"><asp:Label ID="lblUsername" runat="server" /></div>
                    </div>
                    <div class="profile-field">
                        <label>Role</label>
                        <div class="pf-value"><asp:Label ID="lblRole" runat="server" Text="Staff" /></div>
                    </div>
                    <div class="profile-field">
                        <label>Email</label>
                        <div class="pf-value"><asp:Label ID="lblCurrentEmail" runat="server" Text="—" /></div>
                    </div>
                    <div class="profile-field">
                        <label>Phone</label>
                        <div class="pf-value"><asp:Label ID="lblCurrentPhone" runat="server" Text="—" /></div>
                    </div>
                    <div class="profile-field">
                        <label>Session Started</label>
                        <div class="pf-value"><asp:Label ID="lblSessionDate" runat="server" /></div>
                    </div>
                    <div class="profile-field">
                        <label>Institution</label>
                        <div class="pf-value">Niels Brock Copenhagen</div>
                    </div>
                    <div class="profile-field">
                        <label>Module</label>
                        <div class="pf-value">CTEC2713N</div>
                    </div>
                    <div class="profile-field">
                        <label>System</label>
                        <div class="pf-value">DriveNow Admin Portal</div>
                    </div>
                </div>
            </div>

            <!-- ── Edit profile card ─────────────────────────────── -->
            <div class="edit-card">
                <div class="edit-card-title">Edit My Details</div>

                <asp:Label ID="lblProfileMsg" runat="server" Visible="false" />

                <div class="section-label">Personal Information</div>
                <div class="edit-row">
                    <div class="edit-field">
                        <label>Display Name</label>
                        <asp:TextBox ID="txtEditFullName" runat="server" MaxLength="100" placeholder="Your full name" />
                    </div>
                    <div class="edit-field">
                        <label>Username (cannot change)</label>
                        <asp:TextBox ID="txtEditUsername" runat="server" ReadOnly="true" />
                    </div>
                </div>
                <div class="edit-row">
                    <div class="edit-field">
                        <label>Email Address</label>
                        <asp:TextBox ID="txtEditEmail" runat="server" TextMode="Email" MaxLength="150" placeholder="you@drivenow.dk" />
                        <asp:RegularExpressionValidator ID="revEditEmail" runat="server"
                            ControlToValidate="txtEditEmail" CssClass="val-hint" Display="Dynamic"
                            ErrorMessage="Enter a valid email address."
                            ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" />
                    </div>
                    <div class="edit-field">
                        <label>Phone Number</label>
                        <asp:TextBox ID="txtEditPhone" runat="server" MaxLength="20" placeholder="+45 70 00 00 00" />
                    </div>
                </div>

                <hr class="divider-thin" />

                <div class="section-label">Change Password (leave blank to keep current)</div>
                <div class="edit-row">
                    <div class="edit-field">
                        <label>New Password</label>
                        <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" MaxLength="100" placeholder="New password" />
                    </div>
                    <div class="edit-field">
                        <label>Confirm New Password</label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" MaxLength="100" placeholder="Repeat new password" />
                    </div>
                </div>

                <hr class="divider-thin" />

                <!-- Ethical / GDPR consent -->
                <div class="consent-box">
                    <strong>Data Protection Notice</strong><br />
                    By updating your profile, you consent to DriveNow storing the revised personal details (name, email address, phone number) in our staff database. This information is used solely for system access, internal communication and audit purposes, in accordance with GDPR Article 6(1)(b) — processing necessary for the performance of a contract.
                    <div class="consent-check">
                        <asp:CheckBox ID="chkProfileConsent" runat="server" />
                        <span>I confirm these changes are accurate and I consent to DriveNow updating and storing my personal data as described above. *</span>
                    </div>
                    <asp:Label ID="lblConsentError" runat="server" CssClass="val-hint" Visible="false" Text="You must confirm your consent before saving changes." />
                </div>

                <asp:Button ID="btnSaveProfile" runat="server" Text="Save Changes"
                    CssClass="dn-btn dn-btn-primary"
                    OnClick="btnSaveProfile_Click"
                    CausesValidation="false" />
            </div>

            <!-- ── System overview stats ─────────────────────────── -->
            <div class="dn-section-head">
                <div class="dn-section-title">System Overview</div>
            </div>
            <div style="display:grid;grid-template-columns:repeat(5,1fr);gap:1rem;margin-bottom:1.5rem;">
                <div class="stat-box">
                    <div class="sb-num"><asp:Label ID="lblTripCount"        runat="server" Text="–" /></div>
                    <div class="sb-lbl">Trips</div>
                </div>
                <div class="stat-box">
                    <div class="sb-num"><asp:Label ID="lblTripTypeCount"    runat="server" Text="–" /></div>
                    <div class="sb-lbl">Trip Types</div>
                </div>
                <div class="stat-box">
                    <div class="sb-num"><asp:Label ID="lblCustomerCount"    runat="server" Text="–" /></div>
                    <div class="sb-lbl">Customers</div>
                </div>
                <div class="stat-box">
                    <div class="sb-num"><asp:Label ID="lblDriverCount"      runat="server" Text="–" /></div>
                    <div class="sb-lbl">Drivers</div>
                </div>
                <div class="stat-box">
                    <div class="sb-num"><asp:Label ID="lblContributorCount" runat="server" Text="–" /></div>
                    <div class="sb-lbl">Contributors</div>
                </div>
            </div>

            <!-- ── Quick actions ─────────────────────────────────── -->
            <div class="dn-section-head">
                <div class="dn-section-title">Quick Actions</div>
            </div>
            <div style="display:flex;gap:.75rem;flex-wrap:wrap;">
                <a href="MainMenu.aspx"     class="dn-btn dn-btn-primary dn-btn-sm">Go to Dashboard</a>
                <a href="TripAdd.aspx"      class="dn-btn dn-btn-secondary dn-btn-sm">+ New Trip</a>
                <a href="CustomerList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">View Customers</a>
                <a href="DriverList.aspx"   class="dn-btn dn-btn-secondary dn-btn-sm">View Drivers</a>
                <a href="Logout.aspx"       class="dn-btn dn-btn-secondary dn-btn-sm" style="color:#f87171;">Sign Out</a>
            </div>

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


