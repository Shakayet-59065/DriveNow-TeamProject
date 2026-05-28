<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddStaff.aspx.cs" Inherits="DriveNow.AddStaff" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Add Staff Member</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="frmAddStaff" runat="server">
<div class="dn-shell">

    <!-- SIDEBAR -->
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo"><img src="Content/logo.png" alt="DriveNow" /></div>
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
            <div class="dn-sidebar-user">
                <div class="dn-sidebar-avatar"><%= (Session["Username"] != null ? Session["Username"].ToString().Substring(0,1).ToUpper() : "?") %></div>
                <div>
                    <div class="dn-sidebar-name">Admin</div>
                    <div class="dn-sidebar-role">Staff Portal</div>
                </div>
            </div>
            <a href="Logout.aspx" class="dn-sidebar-logout">Sign Out</a>
        </div>
    </div>

    <!-- MAIN -->
    <div class="dn-main">
        <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
            <div class="dn-topbar-title">Add Staff Member</div>
            <div class="dn-topbar-right">
                <a href="MainMenu.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">← Dashboard</a>
            </div>
        </div>

        <div class="dn-content">
            <div class="dn-page-header">
                <div>
                    <div class="dn-page-title">New Staff Member</div>
                    <div class="dn-page-sub">Create a staff login account. Passwords are stored as PBKDF2 hashes.</div>
                </div>
            </div>

            <div class="dn-form-card">
                <asp:Label ID="lblMsg" runat="server" Visible="false" />

                <!-- Username -->
                <div class="dn-field">
                    <label class="dn-label">Username <span class="required">*</span></label>
                    <asp:TextBox ID="txtUsername" runat="server" CssClass="dn-input" MaxLength="50" placeholder="e.g. jsmith" />
                    <div class="dn-hint">Maximum 50 characters. Must be unique.</div>
                </div>

                <!-- Full Name -->
                <div class="dn-field">
                    <label class="dn-label">Full Name <span class="required">*</span></label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="dn-input" MaxLength="100" placeholder="e.g. John Smith" />
                    <div class="dn-hint">Displayed in the staff portal header.</div>
                </div>

                <!-- Password -->
                <div class="dn-field">
                    <label class="dn-label">Password <span class="required">*</span></label>
                    <asp:TextBox ID="txtPassword" runat="server" CssClass="dn-input" TextMode="Password" placeholder="Min. 6 characters" />
                    <div class="dn-hint">Minimum 6 characters. Will be PBKDF2 hashed on save.</div>
                </div>

                <!-- Confirm Password -->
                <div class="dn-field">
                    <label class="dn-label">Confirm Password <span class="required">*</span></label>
                    <asp:TextBox ID="txtConfirmPw" runat="server" CssClass="dn-input" TextMode="Password" placeholder="Repeat password" />
                </div>

                <!-- Role -->
                <div class="dn-field">
                    <label class="dn-label">Staff Role <span class="required">*</span></label>
                    <asp:DropDownList ID="ddlRole" runat="server" CssClass="dn-input">
                        <asp:ListItem Text="Staff"   Value="Staff"   Selected="True" />
                        <asp:ListItem Text="Manager" Value="Manager" />
                        <asp:ListItem Text="Admin"   Value="Admin"   />
                    </asp:DropDownList>
                    <div class="dn-hint">Role determines the staff member's access level in the portal.</div>
                </div>

                <!-- Actions -->
                <div class="dn-form-actions">
                    <asp:Button ID="btnSave" runat="server" Text="Add Staff Member"
                        CssClass="dn-btn dn-btn-primary" OnClick="btnSave_Click" />
                    <a href="MainMenu.aspx" class="dn-btn dn-btn-secondary">Cancel</a>
                </div>
            </div>
        </div>

        <div class="dn-footer">DriveNow Admin System  ·  CTEC2713N  ·  Niels Brock Copenhagen</div>
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


