<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripFind.aspx.cs" Inherits="DriveNow.TripFind" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Find Trip</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="frmTripFind" runat="server">
<div class="dn-shell">

    <!-- SIDEBAR -->
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo"><img src="Content/logo.png" alt="DriveNow" /></div>
        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">Main</div>
            <a href="MainMenu.aspx"     class="dn-nav-item"><span class="dn-nav-icon">⬛</span>Dashboard</a>
            <a href="TripList.aspx"     class="dn-nav-item active"><span class="dn-nav-icon">🛣</span>Trips</a>
            <a href="TripTypeList.aspx" class="dn-nav-item"><span class="dn-nav-icon">🏷</span>Trip Types</a>
            <div class="dn-nav-label">Team</div>
            <a href="#" class="dn-nav-item"><span class="dn-nav-icon">👤</span>Users</a>
            <a href="#" class="dn-nav-item"><span class="dn-nav-icon">🚗</span>Drivers</a>
            <a href="#" class="dn-nav-item"><span class="dn-nav-icon">🚙</span>Vehicles</a>
            <a href="#" class="dn-nav-item"><span class="dn-nav-icon">📝</span>Contributors</a>
        </nav>
        <div class="dn-sidebar-footer">
            <div class="dn-sidebar-user">
                <div class="dn-sidebar-avatar">A</div>
                <div><div class="dn-sidebar-name">Admin</div><div class="dn-sidebar-role">Staff Portal</div></div>
            </div>
            <a href="Logout.aspx" class="dn-sidebar-logout">↩ Log out</a>
        </div>
    </div>

    <!-- MAIN -->
    <div class="dn-main">
        <div class="dn-topbar">
            <div class="dn-topbar-title">Find Trip</div>
            <div class="dn-topbar-right">
                <a href="TripList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">← Trip List</a>
            </div>
        </div>

        <div class="dn-content">
            <div class="dn-page-header">
                <div>
                    <div class="dn-page-title">Find a Trip</div>
                    <div class="dn-page-sub">Search for a specific trip record by its ID</div>
                </div>
            </div>

            <!-- Search input -->
            <div class="dn-form-card" style="margin-bottom:16px">
                <div class="dn-search-row">
                    <asp:TextBox ID="txtTripID" runat="server" CssClass="dn-input" placeholder="Enter Trip ID e.g. 1" />
                    <asp:Button ID="btnFind" runat="server" Text="Find Trip"
                        CssClass="dn-btn dn-btn-primary" OnClick="btnFind_Click" />
                </div>
            </div>

            <!-- Error message -->
            <asp:Label ID="lblError" runat="server" CssClass="dn-alert-error" Visible="false" />

            <!-- Result panel — shown when trip is found -->
            <asp:Panel ID="pnlResult" runat="server" Visible="false">
                <div class="dn-result-card">
                    <div class="dn-result-row">
                        <div class="dn-result-field">
                            <div class="dn-result-label">Trip ID</div>
                            <div class="dn-result-value"><asp:Label ID="lblTripID" runat="server" /></div>
                        </div>
                        <div class="dn-result-field">
                            <div class="dn-result-label">Trip Type</div>
                            <div class="dn-result-value"><asp:Label ID="lblTypeName" runat="server" /></div>
                        </div>
                        <div class="dn-result-field">
                            <div class="dn-result-label">Trip Date</div>
                            <div class="dn-result-value"><asp:Label ID="lblTripDate" runat="server" /></div>
                        </div>
                        <div class="dn-result-field">
                            <div class="dn-result-label">Status</div>
                            <div class="dn-result-value"><asp:Label ID="lblStatus" runat="server" /></div>
                        </div>
                    </div>
                    <div class="dn-result-row">
                        <div class="dn-result-field">
                            <div class="dn-result-label">Customer ID</div>
                            <div class="dn-result-value"><asp:Label ID="lblCustomerID" runat="server" /></div>
                        </div>
                        <div class="dn-result-field">
                            <div class="dn-result-label">Vehicle ID</div>
                            <div class="dn-result-value"><asp:Label ID="lblVehicleID" runat="server" /></div>
                        </div>
                        <div class="dn-result-field">
                            <div class="dn-result-label">Driver ID</div>
                            <div class="dn-result-value"><asp:Label ID="lblDriverID" runat="server" /></div>
                        </div>
                    </div>
                </div>
            </asp:Panel>
        </div>
        <div class="dn-footer">DriveNow Admin System &nbsp;·&nbsp; CTEC2713N &nbsp;·&nbsp; Niels Brock Copenhagen</div>
    </div>

</div>
</form>
</body>
</html>
