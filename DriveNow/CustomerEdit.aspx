<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerEdit.aspx.cs" Inherits="DriveNow.CustomerEdit" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Edit Customer — DriveNow Admin</title>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="form1" runat="server">
<div class="dn-shell">
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo"><img src="Content/logo.png" alt="DriveNow" /></div>
        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">Main</div>
            <a href="MainMenu.aspx"        class="dn-nav-item">■ Dashboard</a>
            <div class="dn-nav-label">Team</div>
            <a href="TripList.aspx"        class="dn-nav-item">■ Trips</a>
            <a href="TripTypeList.aspx"    class="dn-nav-item">■ Trip Types</a>
            <a href="CustomerList.aspx"    class="dn-nav-item active">■ Customers</a>
            <a href="DriverList.aspx"      class="dn-nav-item">■ Drivers</a>
            <a href="VehicleList.aspx"     class="dn-nav-item">■ Vehicles</a>
            <a href="ContributorList.aspx" class="dn-nav-item">■ Contributors</a>
            <div class="dn-nav-label">ADMIN</div>
            <a href="TempPasswords.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">key</span> Temp Passwords</a>
            <a href="StaffList.aspx"       class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">badge</span> Staff</a>
        </nav>
        <div class="dn-sidebar-footer">
            <div>CTEC2713N · Niels Brock</div>
            <a href="Logout.aspx" class="dn-sidebar-logout">&#x2192; Log out</a>
        </div>
    </div>
    <div class="dn-main">
        <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
            <div class="dn-topbar-left">
                <span class="dn-page-title">Edit Customer</span>
                <span class="dn-page-sub">Update customer details</span>
            </div>
            <div class="dn-topbar-actions">
                <a href="CustomerList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">Back to List</a>
            </div>
        </div>
        <div class="dn-content">
            <asp:Label ID="lblMessage" runat="server" CssClass="dn-alert-success" Visible="false" />
            <asp:Label ID="lblError"   runat="server" CssClass="dn-alert-error"   Visible="false" />
            <asp:HiddenField ID="hdnCustomerID" runat="server" />
            <div class="dn-form-card">
                <div class="dn-field">
                    <label class="dn-label">Full Name <span style="color:red">*</span></label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="dn-input" />
                    <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName" ErrorMessage="Required." CssClass="dn-hint" Display="Dynamic" ForeColor="" />
                </div>
                <div class="dn-field">
                    <label class="dn-label">Email <span style="color:red">*</span></label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="dn-input" TextMode="Email" />
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Required." CssClass="dn-hint" Display="Dynamic" ForeColor="" />
                </div>
                <div class="dn-field">
                    <label class="dn-label">Phone <span style="color:red">*</span></label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="dn-input" />
                    <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone" ErrorMessage="Required." CssClass="dn-hint" Display="Dynamic" ForeColor="" />
                </div>
                <div class="dn-field">
                    <label class="dn-label">Status</label>
                    <asp:CheckBox ID="chkIsActive" runat="server" Text=" Active" />
                </div>
                <div class="dn-form-actions">
                    <asp:Button ID="btnSave" runat="server" Text="Save Changes" CssClass="dn-btn dn-btn-primary"   OnClick="btnSave_Click" />
                    <asp:Button ID="btnBack" runat="server" Text="Cancel"       CssClass="dn-btn dn-btn-secondary" OnClick="btnBack_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
        <div class="dn-footer">DriveNow Admin · CTEC2713N · Niels Brock Copenhagen · Customer Management</div>
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


