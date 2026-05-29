<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StaffEdit.aspx.cs" Inherits="DriveNow.StaffEdit" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Edit Staff Member</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <link rel="stylesheet" href="Content/Site.css"/>
    <style>
        .form-row { display:grid; grid-template-columns:1fr 1fr; gap:1rem; }
        .form-section-head { font-size:.7rem; font-weight:700; letter-spacing:.09em; text-transform:uppercase;
            color:#14b8a6; margin:1.4rem 0 .7rem; padding-bottom:.4rem;
            border-bottom:1px solid rgba(255,255,255,.07); }
        .danger-zone { background:rgba(239,68,68,.07); border:1px solid rgba(239,68,68,.2);
            border-radius:12px; padding:1.2rem 1.4rem; margin-top:.5rem; }
        .danger-title { font-size:.75rem; font-weight:700; text-transform:uppercase; letter-spacing:.08em;
            color:#fca5a5; margin-bottom:.7rem; }
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
            <a href="DriverList.aspx"      class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">person</span> Drivers</a>
            <a href="VehicleList.aspx"     class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">directions_car</span> Vehicles</a>
            <a href="ContributorList.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">handshake</span> Contributors</a>
            <div class="dn-nav-label">ADMIN</div>
            <a href="TempPasswords.aspx"   class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">key</span> Temp Passwords</a>
            <a href="StaffList.aspx"       class="dn-nav-item active"><span class="material-symbols-outlined" style="font-size:17px;">badge</span> Staff</a>
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
                <span class="dn-page-title">Edit Staff Member</span>
                <span class="dn-page-sub">Admin — update staff account details</span>
            </div>
            <div class="dn-topbar-right">
                <a href="StaffList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">&#8592; Staff List</a>
            </div>
        </div>

        <div class="dn-content">
            <asp:Label ID="lblMessage" runat="server" CssClass="dn-alert-success" Visible="false"/>
            <asp:Label ID="lblError"   runat="server" CssClass="dn-alert-error"   Visible="false"/>
            <asp:HiddenField ID="hdnStaffID" runat="server"/>

            <div class="dn-form-card">

                <!-- Personal Details -->
                <div class="form-section-head">Personal Details</div>
                <div class="form-row">
                    <div class="dn-field">
                        <label class="dn-label">Full Name <span class="required">*</span></label>
                        <asp:TextBox ID="txtFullName" runat="server" CssClass="dn-input" MaxLength="100"/>
                    </div>
                    <div class="dn-field">
                        <label class="dn-label">Username <span style="color:#64748b;font-weight:400;">(read-only)</span></label>
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="dn-input" ReadOnly="true"
                            style="opacity:.6;cursor:not-allowed;"/>
                    </div>
                </div>
                <div class="form-row">
                    <div class="dn-field">
                        <label class="dn-label">Email</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="dn-input" TextMode="Email" MaxLength="150"/>
                    </div>
                    <div class="dn-field">
                        <label class="dn-label">Phone</label>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="dn-input" MaxLength="30"/>
                    </div>
                </div>

                <!-- Role -->
                <div class="form-section-head">Role &amp; Permissions</div>
                <div class="dn-field" style="max-width:320px;">
                    <label class="dn-label">Role <span class="required">*</span></label>
                    <asp:DropDownList ID="ddlRole" runat="server" CssClass="dn-select">
                        <asp:ListItem Value="Staff">Staff</asp:ListItem>
                        <asp:ListItem Value="Admin">Admin</asp:ListItem>
                        <asp:ListItem Value="Manager">Manager</asp:ListItem>
                    </asp:DropDownList>
                    <div class="dn-hint">Admin can manage staff accounts, passwords, and system settings.</div>
                </div>

                <!-- Password Reset -->
                <div class="form-section-head">Reset Password <span style="font-weight:400;color:#64748b;text-transform:none;font-size:.78rem;">(leave blank to keep current)</span></div>
                <div class="form-row">
                    <div class="dn-field">
                        <label class="dn-label">New Password</label>
                        <asp:TextBox ID="txtNewPassword" runat="server" CssClass="dn-input" TextMode="Password" MaxLength="100"/>
                        <div class="dn-hint" id="pwdHint">Min 8 characters &nbsp;·&nbsp; 1 uppercase letter &nbsp;·&nbsp; 1 number (e.g. <em>Secure1!</em>)</div>
                        <asp:RegularExpressionValidator ID="revPassword" runat="server"
                            ControlToValidate="txtNewPassword"
                            ValidationExpression="^(?=.*[A-Z])(?=.*\d).{8,}$"
                            ErrorMessage="Password must be at least 8 characters with 1 uppercase and 1 number."
                            CssClass="dn-hint" Display="Dynamic" />
                    </div>
                    <div class="dn-field">
                        <label class="dn-label">Confirm New Password</label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="dn-input" TextMode="Password" MaxLength="100"/>
                        <asp:CompareValidator ID="cvPasswordMatch" runat="server"
                            ControlToValidate="txtConfirmPassword"
                            ControlToCompare="txtNewPassword"
                            Operator="Equal"
                            ErrorMessage="Passwords do not match."
                            CssClass="dn-hint" Display="Dynamic" />
                    </div>
                </div>

                <div class="dn-form-actions">
                    <asp:Button ID="btnSave" runat="server" Text="Save Changes"
                        CssClass="dn-btn dn-btn-primary" OnClick="btnSave_Click" CausesValidation="false"/>
                    <a href="StaffList.aspx" class="dn-btn dn-btn-secondary">Cancel</a>
                </div>

                <!-- Danger zone -->
                <div class="form-section-head" style="color:#fca5a5;border-color:rgba(239,68,68,.2);">Danger Zone</div>
                <div class="danger-zone">
                    <div class="danger-title">&#9888; Irreversible Actions</div>
                    <p style="font-size:.82rem;color:#94a3b8;margin-bottom:1rem;line-height:1.6;">
                        Deactivating a staff account prevents login. The record is retained for audit purposes.
                        Permanent deletion removes the account from the database entirely.
                    </p>
                    <div style="display:flex;gap:.7rem;flex-wrap:wrap;">
                        <asp:Button ID="btnToggleActive" runat="server" Text="Deactivate Account"
                            CssClass="dn-btn dn-btn-secondary" OnClick="btnToggleActive_Click"
                            CausesValidation="false"
                            OnClientClick="return confirm('Toggle the active status of this staff member?');"/>
                        <asp:Button ID="btnHardDelete" runat="server" Text="Permanently Delete"
                            CssClass="dn-action-perm-del" OnClick="btnHardDelete_Click"
                            CausesValidation="false"
                            OnClientClick="return confirm('PERMANENTLY delete this staff member? This cannot be undone.');"/>
                    </div>
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
