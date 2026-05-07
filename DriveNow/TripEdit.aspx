<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripEdit.aspx.cs" Inherits="DriveNow.TripEdit" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Edit Trip</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="frmTripEdit" runat="server">
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
            <a href="#" class="dn-nav-item"><span class="dn-nav-icon">👤</span>Customers</a>
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
            <div class="dn-topbar-title">Edit Trip</div>
            <div class="dn-topbar-right">
                <a href="TripList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">← Trip List</a>
            </div>
        </div>

        <div class="dn-content">
            <div class="dn-page-header">
                <div>
                    <div class="dn-page-title">Edit Trip</div>
                    <div class="dn-page-sub">Update the details for this trip record</div>
                </div>
            </div>

            <div class="dn-form-card">
                <asp:Label ID="lblError"   runat="server" CssClass="dn-alert-error"   Visible="false" />
                <asp:Label ID="lblSuccess" runat="server" CssClass="dn-alert-success" Visible="false" />
                <asp:HiddenField ID="hdnTripID" runat="server" />

                <div class="dn-field">
                    <label class="dn-label">Customer ID <span class="required">*</span></label>
                    <asp:TextBox ID="txtCustomerId" runat="server" CssClass="dn-input" />
                </div>
                <div class="dn-field">
                    <label class="dn-label">Vehicle ID <span class="required">*</span></label>
                    <asp:TextBox ID="txtVehicleID" runat="server" CssClass="dn-input" />
                </div>
                <div class="dn-field">
                    <label class="dn-label">Driver ID</label>
                    <asp:TextBox ID="txtDriverID" runat="server" CssClass="dn-input" />
                    <div class="dn-hint">Leave blank for self-drive rentals.</div>
                </div>
                <div class="dn-field">
                    <label class="dn-label">Trip Type <span class="required">*</span></label>
                    <asp:DropDownList ID="ddlTripType" runat="server" CssClass="dn-select" />
                </div>
                <div class="dn-field">
                    <label class="dn-label">Trip Date <span class="required">*</span></label>
                    <asp:TextBox ID="txtTripDate" runat="server" CssClass="dn-input" placeholder="dd/MM/yyyy" />
                </div>

                <div class="dn-form-actions">
                    <asp:Button ID="btnSave" runat="server" Text="Save Changes"
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
