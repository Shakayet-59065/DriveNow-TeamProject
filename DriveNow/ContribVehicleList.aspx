<%-- 
    Page: ContribVehicleList.aspx
    Developer: Ushna
    Component: Contributor Applications
    Purpose: Displays all active vehicles linked to a specific
             contributor. ContributorID passed via query string (?id=).
             Staff can add, edit or soft-delete vehicle records.
--%>

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContribVehicleList.aspx.cs" Inherits="DriveNow.ListContribVehicles" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Contributor Vehicles</title>
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="dn-shell">

            <!-- SIDEBAR -->
            <div class="dn-sidebar">
                <div class="dn-sidebar-logo">
                    <img src="Content/logo.png" alt="DriveNow" />
                </div>
                <nav class="dn-sidebar-nav">
                    <div class="dn-nav-label">Main</div>
                    <a href="MainMenu.aspx" class="dn-nav-item">
                        <span class="dn-nav-icon">⌂</span> Main Menu
                    </a>
                    <div class="dn-nav-label">Contributors</div>
                    <a href="ContributorList.aspx" class="dn-nav-item active">
                        <span class="dn-nav-icon">☰</span> List Contributors
                    </a>
                    <a href="ContributorAdd.aspx" class="dn-nav-item">
                        <span class="dn-nav-icon">+</span> Add Contributor
                    </a>
                    <a href="ContributorFind.aspx" class="dn-nav-item">
                        <span class="dn-nav-icon">🔍</span> Find Contributor
                    </a>
                    <a href="ContributorFilter.aspx" class="dn-nav-item">
                        <span class="dn-nav-icon">⚡</span> Filter Contributors
                    </a>
                    <div class="dn-nav-label">Team</div>
                    <a href="#" class="dn-nav-item">
                        <span class="dn-nav-icon">🚗</span> Trip Records
                    </a>
                    <a href="#" class="dn-nav-item">
                        <span class="dn-nav-icon">👤</span> Customers
                    </a>
                    <a href="#" class="dn-nav-item">
                        <span class="dn-nav-icon">🚘</span> Vehicles
                    </a>
                    <a href="#" class="dn-nav-item">
                        <span class="dn-nav-icon">🧑</span> Drivers
                    </a>
                </nav>
                <div class="dn-sidebar-footer">
                    <div class="dn-sidebar-user">
                        <div class="dn-sidebar-avatar">U</div>
                        <div>
                            <div class="dn-sidebar-name">Ushna</div>
                            <div class="dn-sidebar-role">Contributor Applications</div>
                        </div>
                    </div>
                    <a href="Logout.aspx" class="dn-sidebar-logout">⏻ Logout</a>
                </div>
            </div>

            <!-- MAIN -->
            <div class="dn-main">

                <!-- TOPBAR -->
                <div class="dn-topbar">
                    <div class="dn-topbar-title">Contributor Vehicles</div>
                    <div class="dn-topbar-right">
                        <asp:HyperLink ID="hlAddVehicle" runat="server"
                            CssClass="dn-btn dn-btn-primary dn-btn-sm">
                            + Add Vehicle
                        </asp:HyperLink>
                        <a href="ContributorList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">← Back to Contributors</a>
                    </div>
                </div>

                <!-- CONTENT -->
                <div class="dn-content">

                    <div class="dn-page-header">
                        <div>
                            <div class="dn-page-title">Vehicles for Contributor</div>
                            <div class="dn-page-sub">
                                <asp:Label ID="lblContributorName" runat="server" />
                            </div>
                        </div>
                    </div>

                    <%-- Message label --%>
                    <asp:Label ID="lblMessage" runat="server" Visible="false" />

                    <%-- Vehicles table --%>
                    <div class="dn-table-wrap">
                        <asp:GridView ID="gvVehicles" runat="server"
                            AutoGenerateColumns="false"
                            DataKeyNames="ContribVehicleID"
                            EmptyDataText="No vehicles found for this contributor."
                            CssClass="dn-table"
                            GridLines="None">
                            <Columns>
                                <asp:TemplateField HeaderText="ID">
                                    <ItemTemplate>
                                        <span class="dn-trip-id">#VEH-<%# DataBinder.Eval(Container.DataItem, "ContribVehicleID") %></span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="Make"           HeaderText="Make"  />
                                <asp:BoundField DataField="Model"          HeaderText="Model" />
                                <asp:BoundField DataField="Year"           HeaderText="Year"  />
                                <asp:BoundField DataField="RegistrationNo" HeaderText="Registration" />
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <%# Convert.ToBoolean(DataBinder.Eval(Container.DataItem, "IsAvailable"))
                                            ? "<span class='dn-status'><span class='dn-dot dn-dot-green'></span> Active</span>"
                                            : "<span class='dn-status'><span class='dn-dot dn-dot-red'></span> Inactive</span>" %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Actions">
                                    <ItemTemplate>
                                        <asp:Button ID="btnEdit" runat="server" Text="Edit"
                                            CssClass="dn-action-edit"
                                            CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ContribVehicleID") %>'
                                            OnClick="btnEdit_Click" />
                                        <asp:Button ID="btnDelete" runat="server" Text="Delete"
                                            CssClass="dn-action-del"
                                            CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ContribVehicleID") %>'
                                            OnClick="btnDelete_Click"
                                            OnClientClick="return confirm('Delete this vehicle?');" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>

                </div>
                <div class="dn-footer">DriveNow Admin System · CTEC2713N · Niels Brock Copenhagen</div>
            </div>
        </div>
    </form>
</body>
</html>