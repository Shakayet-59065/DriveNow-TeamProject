<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripFilter.aspx.cs" Inherits="DriveNow.TripFilter" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Filter Trips</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="frmTripFilter" runat="server">
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
            <div class="dn-topbar-title">Filter Trips</div>
            <div class="dn-topbar-right">
                <a href="TripList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">← Trip List</a>
            </div>
        </div>

        <div class="dn-content">
            <div class="dn-page-header">
                <div>
                    <div class="dn-page-title">Filter Trips</div>
                    <div class="dn-page-sub">Filter the trip records by service type and/or date</div>
                </div>
            </div>

            <!-- Filter controls -->
            <div class="dn-filter-row">
                <div class="dn-filter-field">
                    <label class="dn-label">Trip Type</label>
                    <asp:DropDownList ID="ddlTripType" runat="server" CssClass="dn-select" />
                </div>
                <div class="dn-filter-field">
                    <label class="dn-label">Trip Date (dd/MM/yyyy)</label>
                    <asp:TextBox ID="txtTripDate" runat="server" CssClass="dn-input" placeholder="Optional" />
                </div>
                <div style="display:flex;gap:8px;align-items:flex-end">
                    <asp:Button ID="btnFilter" runat="server" Text="Apply Filter"
                        CssClass="dn-btn dn-btn-primary" OnClick="btnFilter_Click" />
                    <asp:Button ID="btnClear" runat="server" Text="Clear"
                        CssClass="dn-btn dn-btn-secondary" OnClick="btnClear_Click"
                        CausesValidation="false" />
                </div>
            </div>

            <!-- Error message -->
            <asp:Label ID="lblError" runat="server" CssClass="dn-alert-error" Visible="false" />

            <!-- Filtered results GridView -->
            <div class="dn-table-wrap">
                <asp:GridView ID="gvTrips" runat="server"
                    AutoGenerateColumns="false"
                    CssClass="dn-table"
                    GridLines="None"
                    EmptyDataText="No trips match the selected filters.">
                    <Columns>
                        <asp:TemplateField HeaderText="Trip ID">
                            <ItemTemplate>
                                <span class="dn-trip-id">#TRP-00<%# Eval("TripID") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="CustomerID" HeaderText="Customer ID" />
                        <asp:BoundField DataField="VehicleID"  HeaderText="Vehicle ID" />
                        <asp:BoundField DataField="DriverID"   HeaderText="Driver ID" NullDisplayText="Self-Drive" />
                        <asp:TemplateField HeaderText="Trip Type">
                            <ItemTemplate>
                                <span class="dn-type-pill"><%# Eval("TypeName") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="TripDate" HeaderText="Date" DataFormatString="{0:dd MMM yyyy}" />
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class="dn-status">
                                    <span class="dn-dot dn-dot-green"></span>Active
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

        </div>
        <div class="dn-footer">DriveNow Admin System &nbsp;·&nbsp; CTEC2713N &nbsp;·&nbsp; Niels Brock Copenhagen</div>
    </div>

</div>
</form>
</body>
</html>
