<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripList.aspx.cs" Inherits="DriveNow.TripList" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Trip List</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="frmTripList" runat="server">
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
            <div class="dn-topbar-title">Trip Records</div>
            <div class="dn-topbar-right">
                <a href="MainMenu.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">← Dashboard</a>
                <a href="TripAdd.aspx"  class="dn-btn dn-btn-primary   dn-btn-sm">+ Add Trip</a>
            </div>
        </div>

        <div class="dn-content">

            <!-- Error message -->
            <asp:Label ID="lblError" runat="server" CssClass="dn-alert-error" Visible="false" />

            <!-- Section header with Find and Filter links -->
            <div class="dn-section-head">
                <div class="dn-section-title">All Trips</div>
                <div style="display:flex;gap:8px">
                    <a href="TripFind.aspx"   class="dn-btn dn-btn-secondary dn-btn-sm">Find by ID</a>
                    <a href="TripFilter.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">Filter</a>
                </div>
            </div>

            <!-- Quick navigation pills -->
            <div class="dn-pills">
                <span class="dn-pill active">All Trips</span>
                <a href="TripAdd.aspx"    class="dn-pill">+ Add New</a>
                <a href="TripFind.aspx"   class="dn-pill">Find</a>
                <a href="TripFilter.aspx" class="dn-pill">Filter</a>
            </div>

            <!-- Trips GridView -->
            <div class="dn-table-wrap">
                <asp:GridView ID="gvTrips" runat="server"
                    AutoGenerateColumns="false"
                    DataKeyNames="TripID"
                    OnRowCommand="gvTrips_RowCommand"
                    CssClass="dn-table"
                    GridLines="None"
                    EmptyDataText="No active trips found.">
                    <Columns>
                        <asp:TemplateField HeaderText="Trip ID">
                            <ItemTemplate>
                                <span class="dn-trip-id">#TRP-00<%# Eval("TripID") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="CustomerId" HeaderText="Customer ID" />
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
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton runat="server" CommandName="EditTrip"
                                    CommandArgument='<%# Eval("TripID") %>'
                                    CssClass="dn-action-edit">Edit</asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="DeleteTrip"
                                    CommandArgument='<%# Eval("TripID") %>'
                                    CssClass="dn-action-del"
                                    OnClientClick="return confirm('Soft delete this trip?');">Delete</asp:LinkButton>
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
