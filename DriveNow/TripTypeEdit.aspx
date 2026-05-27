<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripTypeEdit.aspx.cs" Inherits="DriveNow.TripTypeEdit" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Edit Trip Type</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="frmTripTypeEdit" runat="server">
<div class="dn-shell">

    <!-- SIDEBAR -->
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo"><img src="Content/logo.png" alt="DriveNow" /></div>
        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">Main</div>
            <a href="MainMenu.aspx"     class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">dashboard</span> Dashboard</a>
            <a href="TripList.aspx"     class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">route</span> Trips</a>
            <a href="TripTypeList.aspx" class="dn-nav-item active"><span class="material-symbols-outlined" style="font-size:17px;">category</span> Trip Types</a>
            <div class="dn-nav-label">Team</div>
            <a href="CustomerList.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">group</span> Customers</a>
            <a href="DriverList.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">person</span> Drivers</a>
            <a href="VehicleList.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">directions_car</span> Vehicles</a>
            <a href="ContributorList.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">handshake</span> Contributors</a>
            <div class="dn-nav-label">ADMIN</div>
            <a href="TempPasswords.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">key</span> Temp Passwords</a>
            <a href="StaffList.aspx"       class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">badge</span> Staff</a>
        </nav>
        <div class="dn-sidebar-footer">
            <div class="dn-sidebar-user">
                <div class="dn-sidebar-avatar"><%= (Session["Username"] != null ? Session["Username"].ToString().Substring(0,1).ToUpper() : "?") %></div>
                <div><div class="dn-sidebar-name">Admin</div><div class="dn-sidebar-role">Staff Portal</div></div>
            </div>
            <a href="Logout.aspx" class="dn-sidebar-logout">↩ Log out</a>
        </div>
    </div>

    <!-- MAIN -->
    <div class="dn-main">
        <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
            <div class="dn-topbar-title">Edit Trip Type</div>
            <div class="dn-topbar-right">
                <a href="TripTypeList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">← Trip Type List</a>
            </div>
        </div>

        <div class="dn-content">
            <div class="dn-page-header">
                <div>
                    <div class="dn-page-title">Edit Trip Type</div>
                    <div class="dn-page-sub">Update the details for this service type</div>
                </div>
            </div>

            <div class="dn-form-card">
                <!-- Error and success messages -->
                <asp:Label ID="lblError"   runat="server" CssClass="dn-alert-error"   Visible="false" />
                <asp:Label ID="lblSuccess" runat="server" CssClass="dn-alert-success" Visible="false" />

                <!-- Hidden field to store TripTypeID across postbacks -->
                <asp:HiddenField ID="hdnTripTypeID" runat="server" />

                <!-- Type Name -->
                <div class="dn-field">
                    <label class="dn-label">Type Name <span class="required">*</span></label>
                    <asp:TextBox ID="txtTypeName" runat="server" CssClass="dn-input" MaxLength="50" />
                </div>

                <!-- Description -->
                <div class="dn-field">
                    <label class="dn-label">Description</label>
                    <asp:TextBox ID="txtDescription" runat="server" CssClass="dn-textarea" TextMode="MultiLine" MaxLength="200" />
                </div>

                <!-- Base Rate -->
                <div class="dn-field">
                    <label class="dn-label">Base Rate <span class="required">*</span></label>
                    <asp:TextBox ID="txtBaseRate" runat="server" CssClass="dn-input" />
                </div>

                <!-- Action buttons -->
                <div class="dn-form-actions">
                    <asp:Button ID="btnSave" runat="server" Text="Save Changes"
                        CssClass="dn-btn dn-btn-primary" OnClick="btnSave_Click" />
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel"
                        CssClass="dn-btn dn-btn-secondary" OnClick="btnCancel_Click"
                        CausesValidation="false" />
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



