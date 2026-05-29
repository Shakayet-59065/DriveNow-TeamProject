<%-- 
    Page: ContributorList.aspx
    Developer: Ushna
    Component: Contributor Applications
    Purpose: Displays all contributor application records from tblContributor.
             Staff can edit, soft-delete, or view vehicles for any record.
             Vehicles button only shown for VehicleOwner contributors.
             Soft delete sets IsApproved = 0 — no hard deletes ever.
--%>

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContributorList.aspx.cs" Inherits="DriveNow.ListContributors" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Contributor Applications</title>
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
                    <div class="dn-topbar-title">Contributor Applications</div>
                    <div class="dn-topbar-right">
                        <span class="dn-topbar-date">
                            <asp:Label ID="lblDate" runat="server" />
                        </span>
                        <a href="ContributorAdd.aspx" class="dn-btn dn-btn-primary dn-btn-sm">+ Add Contributor</a>
                    </div>
                </div>

                <!-- CONTENT -->
                <div class="dn-content">

                    <!-- Stat cards -->
                    <div class="dn-stats">
                        <div class="dn-stat dn-stat-4">
                            <div class="dn-stat-num">
                                <asp:Label ID="lblTotalCount" runat="server" Text="0" />
                            </div>
                            <div class="dn-stat-label">Total Applications</div>
                        </div>
                        <div class="dn-stat dn-stat-4">
                            <div class="dn-stat-num">
                                <asp:Label ID="lblApprovedCount" runat="server" Text="0" />
                            </div>
                            <div class="dn-stat-label">Approved</div>
                        </div>
                        <div class="dn-stat dn-stat-4">
                            <div class="dn-stat-num">
                                <asp:Label ID="lblPendingCount" runat="server" Text="0" />
                            </div>
                            <div class="dn-stat-label">Pending</div>
                        </div>
                        <div class="dn-stat dn-stat-4">
                            <div class="dn-stat-num">
                                <asp:Label ID="lblDriverCount" runat="server" Text="0" />
                            </div>
                            <div class="dn-stat-label">Drivers</div>
                        </div>
                    </div>

                    <!-- Alert messages -->
                    <asp:Label ID="lblError" runat="server" Visible="false" />

                    <!-- Section header -->
                    <div class="dn-section-head">
                        <div class="dn-section-title">All Contributor Records</div>
                        <div>
                            <a href="ContributorFind.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">Find</a>
                            <a href="ContributorFilter.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">Filter</a>
                        </div>
                    </div>

                    <!-- Table -->
                    <div class="dn-table-wrap">
                        <asp:GridView ID="gvContributors" runat="server"
                            AutoGenerateColumns="false"
                            DataKeyNames="ContributorID"
                            EmptyDataText="No contributor records found."
                            CssClass="dn-table"
                            GridLines="None">
                            <Columns>
                                <asp:TemplateField HeaderText="ID">
                                    <ItemTemplate>
                                        <span class="dn-trip-id">#CON-<%# DataBinder.Eval(Container.DataItem, "ContributorID") %></span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="FullName"        HeaderText="Full Name" />
                                <asp:BoundField DataField="Email"           HeaderText="Email"     />
                                <asp:BoundField DataField="Phone"           HeaderText="Phone"     />
                                <asp:TemplateField HeaderText="Type">
                                    <ItemTemplate>
                                        <span class="dn-type-pill"><%# DataBinder.Eval(Container.DataItem, "ContributorType") %></span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="ApplicationDate" HeaderText="Date Applied"
                                    DataFormatString="{0:dd/MM/yyyy}" />
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <%# Convert.ToBoolean(DataBinder.Eval(Container.DataItem, "IsApproved"))
                                            ? "<span class='dn-status'><span class='dn-dot dn-dot-green'></span> Approved</span>"
                                            : "<span class='dn-status'><span class='dn-dot dn-dot-amber'></span> Pending</span>" %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Actions">
                                    <ItemTemplate>
                                        <asp:Button ID="btnEdit" runat="server" Text="Edit"
                                            CssClass="dn-action-edit"
                                            CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ContributorID") %>'
                                            OnClick="btnEdit_Click" />
                                        <asp:Button ID="btnDelete" runat="server" Text="Delete"
                                            CssClass="dn-action-del"
                                            CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ContributorID") %>'
                                            OnClick="btnDelete_Click"
                                            OnClientClick="return confirm('Delete this contributor?');" />
                                        <%-- Vehicles button — only visible for VehicleOwner contributors --%>
                                        <asp:Button ID="btnVehicles" runat="server" Text="Vehicles"
                                            CssClass="dn-action-edit"
                                            CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ContributorID") %>'
                                            OnClick="btnVehicles_Click"
                                            Visible='<%# DataBinder.Eval(Container.DataItem, "ContributorType").ToString() == "VehicleOwner" %>' />
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