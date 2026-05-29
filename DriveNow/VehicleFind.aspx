<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VehicleFind.aspx.cs" Inherits="DriveNow.VehicleFind" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Find Vehicle — DriveNow Admin</title>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="form1" runat="server">
<div class="dn-shell">

    <div class="dn-sidebar">
        <div class="dn-sidebar-logo">
            <img src="Content/logo.png" alt="DriveNow" />
        </div>
        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">Main</div>
            <a href="MainMenu.aspx" class="dn-nav-item">■ Dashboard</a>
            <div class="dn-nav-label">Team</div>
            <a href="TripList.aspx"        class="dn-nav-item">■ Trips</a>
            <a href="TripTypeList.aspx"    class="dn-nav-item">■ Trip Types</a>
            <a href="CustomerList.aspx"    class="dn-nav-item">■ Customers</a>
            <a href="DriverList.aspx"      class="dn-nav-item">■ Drivers</a>
            <a href="VehicleList.aspx"     class="dn-nav-item active">■ Vehicles</a>
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
                <span class="dn-page-title">Find Vehicle</span>
                <span class="dn-page-sub">Search for a vehicle by its ID number</span>
            </div>
            <div class="dn-topbar-actions">
                <a href="VehicleList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">← Back to List</a>
            </div>
        </div>

        <div class="dn-content">
            <div class="dn-find-row">
                <asp:TextBox ID="txtVehicleID" runat="server" CssClass="dn-input" placeholder="Enter Vehicle ID e.g. 3" MaxLength="10" />
                <asp:Button  ID="btnFind"      runat="server" Text="Find Vehicle" CssClass="dn-btn dn-btn-primary"   OnClick="btnFind_Click" />
                <asp:Button  ID="btnClear"     runat="server" Text="Clear"        CssClass="dn-btn dn-btn-secondary" OnClick="btnClear_Click" />
            </div>

            <asp:Label ID="lblError" runat="server" Text="" Visible="false" CssClass="dn-alert-error" />

            <asp:Panel ID="pnlResult" runat="server" Visible="false">
                <div class="dn-result-card">
                    <div class="dn-result-row">
                        <span class="dn-result-label">Vehicle ID</span>
                        <span class="dn-result-value"><asp:Label ID="lblVehicleID" runat="server" /></span>
                    </div>
                    <div class="dn-result-row">
                        <span class="dn-result-label">Registration No</span>
                        <span class="dn-result-value"><asp:Label ID="lblRegistrationNo" runat="server" /></span>
                    </div>
                    <div class="dn-result-row">
                        <span class="dn-result-label">Make</span>
                        <span class="dn-result-value"><asp:Label ID="lblMake" runat="server" /></span>
                    </div>
                    <div class="dn-result-row">
                        <span class="dn-result-label">Model</span>
                        <span class="dn-result-value"><asp:Label ID="lblModel" runat="server" /></span>
                    </div>
                    <div class="dn-result-row">
                        <span class="dn-result-label">Daily Rate</span>
                        <span class="dn-result-value"><asp:Label ID="lblDailyRate" runat="server" /></span>
                    </div>
                    <div class="dn-result-row">
                        <span class="dn-result-label">Date Added</span>
                        <span class="dn-result-value"><asp:Label ID="lblDateAdded" runat="server" /></span>
                    </div>
                    <div class="dn-result-row">
                        <span class="dn-result-label">Status</span>
                        <span class="dn-result-value"><asp:Label ID="lblStatus" runat="server" /></span>
                    </div>
                    <div class="dn-form-actions">
                        <asp:HyperLink ID="lnkEdit" runat="server" CssClass="dn-btn dn-btn-primary">Edit this Vehicle</asp:HyperLink>
                        <a href="VehicleList.aspx" class="dn-btn dn-btn-secondary">Back to List</a>
                    </div>
                </div>
            </asp:Panel>
        </div>

        <div class="dn-footer">
            DriveNow Admin · CTEC2713N · Niels Brock Copenhagen · Prodip · Vehicle Inventory
        </div>
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

