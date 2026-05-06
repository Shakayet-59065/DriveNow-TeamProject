<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripTypeAdd.aspx.cs" Inherits="DriveNow.TripTypeAdd" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Add Trip Type</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="frmTripTypeAdd" runat="server">
<div class="dn-shell">

    <!-- SIDEBAR -->
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo"><img src="Content/logo.png" alt="DriveNow" /></div>
        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">Main</div>
            <a href="MainMenu.aspx"     class="dn-nav-item"><span class="dn-nav-icon">⬛</span>Dashboard</a>
            <a href="TripList.aspx"     class="dn-nav-item"><span class="dn-nav-icon">🛣</span>Trips</a>
            <a href="TripTypeList.aspx" class="dn-nav-item active"><span class="dn-nav-icon">🏷</span>Trip Types</a>
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
            <div class="dn-topbar-title">Add Trip Type</div>
            <div class="dn-topbar-right">
                <a href="TripTypeList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">← Trip Type List</a>
            </div>
        </div>

        <div class="dn-content">
            <div class="dn-page-header">
                <div>
                    <div class="dn-page-title">New Trip Type</div>
                    <div class="dn-page-sub">Add a new service type to the DriveNow catalogue</div>
                </div>
            </div>

            <div class="dn-form-card">
                <!-- Error and success messages -->
                <asp:Label ID="lblError"   runat="server" CssClass="dn-alert-error"   Visible="false" />
                <asp:Label ID="lblSuccess" runat="server" CssClass="dn-alert-success" Visible="false" />

                <!-- Type Name field -->
                <div class="dn-field">
                    <label class="dn-label">Type Name <span class="required">*</span></label>
                    <asp:TextBox ID="txtTypeName" runat="server" CssClass="dn-input" MaxLength="50" placeholder="e.g. Short Ride" />
                    <div class="dn-hint">Maximum 50 characters. Must be unique.</div>
                </div>

                <!-- Description field -->
                <div class="dn-field">
                    <label class="dn-label">Description</label>
                    <asp:TextBox ID="txtDescription" runat="server" CssClass="dn-textarea" TextMode="MultiLine" MaxLength="200" placeholder="Brief description of this service type" />
                    <div class="dn-hint">Optional. Maximum 200 characters.</div>
                </div>

                <!-- Base Rate field -->
                <div class="dn-field">
                    <label class="dn-label">Base Rate <span class="required">*</span></label>
                    <asp:TextBox ID="txtBaseRate" runat="server" CssClass="dn-input" placeholder="e.g. 5.99" />
                    <div class="dn-hint">Enter the starting rate for this service type.</div>
                </div>

                <!-- Form action buttons -->
                <div class="dn-form-actions">
                    <asp:Button ID="btnSave" runat="server" Text="Save Trip Type"
                        CssClass="dn-btn dn-btn-primary" OnClick="btnSave_Click" />
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel"
                        CssClass="dn-btn dn-btn-secondary" OnClick="btnCancel_Click"
                        CausesValidation="false" />
                </div>
            </div>
        </div>
        <div class="dn-footer">DriveNow Admin System &nbsp;·&nbsp; CTEC2713N &nbsp;·&nbsp; Niels Brock Copenhagen</div>
    </div>

</div>
</form>
</body>
</html>
