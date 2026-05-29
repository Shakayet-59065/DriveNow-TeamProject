<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DriverEdit.aspx.cs" Inherits="DriveNow.DriverEdit" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Edit Driver</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <link rel="stylesheet" href="Content/Site.css"/>
    <style>
        .form-row { display:grid; grid-template-columns:1fr 1fr; gap:1rem; }
        .form-section-head { font-size:.7rem; font-weight:700; letter-spacing:.09em; text-transform:uppercase;
            color:#14b8a6; margin:1.4rem 0 .7rem; padding-bottom:.4rem;
            border-bottom:1px solid rgba(255,255,255,.07); }
        .licence-alert { background:rgba(251,191,36,.08); border:1px solid rgba(251,191,36,.25);
            border-radius:10px; padding:.8rem 1rem; font-size:.78rem; color:#fbbf24;
            margin-bottom:1rem; line-height:1.6; }
        .gdpr-notice { background:#0f172a; border:1px solid rgba(20,184,166,.2); border-radius:8px;
            padding:.9rem 1rem; margin-bottom:1.1rem; font-size:.78rem; color:#5eead4; line-height:1.65; }
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
                <span class="dn-page-title">Edit Driver</span>
                <span class="dn-page-sub">Update driver details and licence information</span>
            </div>
            <div class="dn-topbar-right">
                <a href="DriverList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">&#8592; Driver List</a>
            </div>
        </div>

        <div class="dn-content">
            <asp:Label ID="lblMessage" runat="server" CssClass="dn-alert-success" Visible="false"/>
            <asp:Label ID="lblError"   runat="server" CssClass="dn-alert-error"   Visible="false"/>
            <asp:HiddenField ID="hdnDriverID" runat="server"/>

            <div class="dn-form-card">

                <!-- PERSONAL DETAILS -->
                <div class="form-section-head">Personal Details</div>
                <div class="form-row">
                    <div class="dn-field">
                        <label class="dn-label">Full Name <span class="required">*</span></label>
                        <asp:TextBox ID="txtFullName" runat="server" CssClass="dn-input"/>
                    </div>
                    <div class="dn-field">
                        <label class="dn-label">Phone <span class="required">*</span></label>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="dn-input"/>
                    </div>
                </div>
                <div class="form-row">
                    <div class="dn-field">
                        <label class="dn-label">Date of Birth <span class="required">*</span></label>
                        <asp:TextBox ID="txtDateOfBirth" runat="server" CssClass="dn-input" TextMode="Date"/>
                        <div class="dn-hint">Must be 18 or older.</div>
                    </div>
                    <div class="dn-field">
                        <label class="dn-label">Join Date <span class="required">*</span></label>
                        <asp:TextBox ID="txtJoinDate" runat="server" CssClass="dn-input" TextMode="Date"/>
                    </div>
                </div>

                <!-- DRIVING LICENCE -->
                <div class="form-section-head">Driving Licence</div>
                <div class="licence-alert">
                    &#9888; Driving licence details are legally sensitive. Ensure the information matches the physical licence. Staff are responsible for verifying licence validity before assigning a driver to any trip.
                </div>
                <div class="dn-field">
                    <label class="dn-label">Licence Number <span class="required">*</span></label>
                    <asp:TextBox ID="txtLicenceNumber" runat="server" CssClass="dn-input" placeholder="e.g. ANDE9901157JA9"/>
                </div>
                <div class="form-row">
                    <div class="dn-field">
                        <label class="dn-label">Licence Issue Date</label>
                        <asp:TextBox ID="txtLicenceIssueDate" runat="server" CssClass="dn-input" TextMode="Date"/>
                        <div class="dn-hint">Date the driving licence was issued.</div>
                    </div>
                    <div class="dn-field">
                        <label class="dn-label">Licence Expiry Date</label>
                        <asp:TextBox ID="txtLicenceExpiryDate" runat="server" CssClass="dn-input" TextMode="Date"/>
                        <div class="dn-hint">Date the driving licence expires. System flags expired licences.</div>
                    </div>
                </div>

                <!-- PROFILE -->
                <div class="form-section-head">Driver Profile (visible to customers)</div>
                <div class="form-row">
                    <div class="dn-field">
                        <label class="dn-label">Gender</label>
                        <asp:DropDownList ID="ddlGender" runat="server" CssClass="dn-select">
                            <asp:ListItem Value=""  Text="-- Not specified --"/>
                            <asp:ListItem Value="M" Text="Male"/>
                            <asp:ListItem Value="F" Text="Female"/>
                            <asp:ListItem Value="X" Text="Non-binary / Other"/>
                        </asp:DropDownList>
                    </div>
                    <div class="dn-field">
                        <label class="dn-label">Specialty</label>
                        <asp:TextBox ID="txtSpecialty" runat="server" CssClass="dn-input" placeholder="e.g. Airport Transfers, VIP Service" MaxLength="100"/>
                        <div class="dn-hint">Shown as a badge on the driver card.</div>
                    </div>
                </div>
                <div class="dn-field">
                    <label class="dn-label">Short Bio</label>
                    <asp:TextBox ID="txtBio" runat="server" CssClass="dn-input" TextMode="MultiLine" Rows="3"
                        placeholder="e.g. Experienced driver with 8 years in the industry, specialising in airport transfers." MaxLength="300"/>
                    <div class="dn-hint">Up to 300 characters. Visible to customers when selecting a driver.</div>
                </div>
                <div class="dn-field">
                    <label class="dn-label">Photo URL <span style="font-weight:400;color:#64748b;">(optional)</span></label>
                    <asp:TextBox ID="txtPhotoUrl" runat="server" CssClass="dn-input" placeholder="https://example.com/photo.jpg" MaxLength="500"/>
                    <div class="dn-hint">Direct URL to a profile photo. Leave blank to use initials avatar.</div>
                </div>

                <!-- PERFORMANCE -->
                <div class="form-section-head">Performance Rating</div>
                <div class="dn-field">
                    <label class="dn-label">Star Rating <span style="font-weight:400;color:#64748b;">(0.0 – 5.0)</span></label>
                    <asp:DropDownList ID="ddlRating" runat="server" CssClass="dn-select">
                        <asp:ListItem Value=""    Text="-- Not yet rated --"/>
                        <asp:ListItem Value="5.0" Text="5.0 — Excellent"/>
                        <asp:ListItem Value="4.5" Text="4.5 — Very Good"/>
                        <asp:ListItem Value="4.0" Text="4.0 — Good"/>
                        <asp:ListItem Value="3.5" Text="3.5 — Above Average"/>
                        <asp:ListItem Value="3.0" Text="3.0 — Average"/>
                        <asp:ListItem Value="2.5" Text="2.5 — Below Average"/>
                        <asp:ListItem Value="2.0" Text="2.0 — Poor"/>
                        <asp:ListItem Value="1.0" Text="1.0 — Very Poor"/>
                    </asp:DropDownList>
                    <div class="dn-hint">Shown as stars on the public driver profile and in the booking panel.</div>
                </div>

                <div class="gdpr-notice">
                    <strong>&#9888; Data Protection Reminder</strong><br />
                    You are editing personal data (name, phone, date of birth, and driving licence) belonging to a third party. Ensure changes reflect the driver's actual verified documents. Processed under GDPR Article 6(1)(b). Access is logged for audit purposes.
                </div>

                <div class="dn-form-actions">
                    <asp:Button ID="btnSave" runat="server" Text="Save Changes"
                        CssClass="dn-btn dn-btn-primary" OnClick="btnSave_Click" CausesValidation="false"/>
                    <asp:Button ID="btnBack" runat="server" Text="Cancel"
                        CssClass="dn-btn dn-btn-secondary" OnClick="btnBack_Click" CausesValidation="false"/>
                </div>
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
