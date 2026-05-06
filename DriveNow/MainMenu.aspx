<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MainMenu.aspx.cs" Inherits="DriveNow.MainMenu" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="frmMainMenu" runat="server">
<div class="dn-shell">

    <!-- ═══════════════════════════════════════
         SIDEBAR NAVIGATION
    ═══════════════════════════════════════ -->
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo">
            <img src="Content/logo.png" alt="DriveNow" />
        </div>
        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">Main</div>
            <a href="MainMenu.aspx"    class="dn-nav-item active"><span class="dn-nav-icon">⬛</span>Dashboard</a>
            <a href="TripList.aspx"    class="dn-nav-item"><span class="dn-nav-icon">🛣</span>Trips</a>
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
                <div>
                    <div class="dn-sidebar-name"><asp:Label ID="lblUsername" runat="server" /></div>
                    <div class="dn-sidebar-role">Staff Portal</div>
                </div>
            </div>
            <a href="Logout.aspx" class="dn-sidebar-logout">↩ Log out</a>
        </div>
    </div>

    <!-- ═══════════════════════════════════════
         MAIN CONTENT
    ═══════════════════════════════════════ -->
    <div class="dn-main">

        <!-- Top bar -->
        <div class="dn-topbar">
            <div class="dn-topbar-title">Dashboard</div>
            <div class="dn-topbar-right">
                <span class="dn-topbar-date"><asp:Label ID="lblDate" runat="server" /></span>
                <a href="TripAdd.aspx" class="dn-btn dn-btn-primary dn-btn-sm">+ New Trip</a>
            </div>
        </div>

        <div class="dn-content">

            <!-- Page header -->
            <div class="dn-page-header">
                <div>
                    <div class="dn-page-title">Good morning, Admin</div>
                    <div class="dn-page-sub">DriveNow Staff Portal — CTEC2713N — Niels Brock Copenhagen</div>
                </div>
            </div>

            <!-- ─────────────────────────────────
                 STAT CARDS — live counts from DB
            ───────────────────────────────── -->
            <div class="dn-stats">
                <div class="dn-stat dn-stat-1">
                    <div class="dn-stat-num"><asp:Label ID="lblTripCount"     runat="server">0</asp:Label></div>
                    <div class="dn-stat-label">Active Trips</div>
                </div>
                <div class="dn-stat dn-stat-2">
                    <div class="dn-stat-num"><asp:Label ID="lblTripTypeCount" runat="server">0</asp:Label></div>
                    <div class="dn-stat-label">Trip Types</div>
                </div>
                <div class="dn-stat dn-stat-3">
                    <div class="dn-stat-num"><asp:Label ID="lblCustomerCount" runat="server">0</asp:Label></div>
                    <div class="dn-stat-label">Users</div>
                </div>
                <div class="dn-stat dn-stat-4">
                    <div class="dn-stat-num"><asp:Label ID="lblDriverCount"   runat="server">0</asp:Label></div>
                    <div class="dn-stat-label">Drivers</div>
                </div>
            </div>

            <!-- ─────────────────────────────────
                 RECENT TRIPS TABLE
            ───────────────────────────────── -->
            <div class="dn-section-head">
                <div class="dn-section-title">Recent Trips</div>
                <div style="display:flex;gap:8px">
                    <a href="TripFilter.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">Filter</a>
                    <a href="TripFind.aspx"   class="dn-btn dn-btn-secondary dn-btn-sm">Find by ID</a>
                    <a href="TripList.aspx"   class="dn-btn dn-btn-secondary dn-btn-sm">View All →</a>
                </div>
            </div>

            <!-- Filter pills -->
            <div class="dn-pills">
                <span class="dn-pill active">All Trips</span>
                <a href="TripList.aspx"   class="dn-pill">Manage</a>
                <a href="TripAdd.aspx"    class="dn-pill">+ Add New</a>
                <a href="TripTypeList.aspx" class="dn-pill">Trip Types</a>
            </div>

            <!-- Recent trips GridView -->
            <div class="dn-table-wrap">
                <asp:GridView ID="gvRecentTrips" runat="server"
                    AutoGenerateColumns="false"
                    CssClass="dn-table"
                    GridLines="None"
                    EmptyDataText="No active trips found.">
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
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <a href='TripEdit.aspx?id=<%# Eval("TripID") %>' class="dn-action-edit">Edit</a>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <!-- ─────────────────────────────────
                 QUICK ACCESS CARDS
            ───────────────────────────────── -->
            <div class="dn-section-head" style="margin-top:24px">
                <div class="dn-section-title">Component Overview</div>
            </div>

            <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:10px">

                <!-- Trip Type Catalogue -->
                <a href="TripTypeList.aspx" style="text-decoration:none">
                    <div class="dn-stat dn-stat-1" style="cursor:pointer">
                        <div style="font-size:20px;margin-bottom:8px">🏷️</div>
                        <div class="dn-stat-num" style="font-size:18px">Trip Types</div>
                        <div class="dn-stat-label">Manage catalogue</div>
                    </div>
                </a>

                <!-- Users — Tahmid -->
                <div class="dn-stat dn-stat-3">
                    <div style="font-size:20px;margin-bottom:8px">👤</div>
                    <div class="dn-stat-num" style="font-size:18px">Users</div>
                    <div class="dn-stat-label">Tahmid</div>
                </div>

                <!-- Drivers — Redoy -->
                <div class="dn-stat dn-stat-4">
                    <div style="font-size:20px;margin-bottom:8px">🚗</div>
                    <div class="dn-stat-num" style="font-size:18px">Drivers</div>
                    <div class="dn-stat-label">Redoy</div>
                </div>

                <!-- Vehicles — Prodip -->
                <div class="dn-stat dn-stat-2">
                    <div style="font-size:20px;margin-bottom:8px">🚙</div>
                    <div class="dn-stat-num" style="font-size:18px">Vehicles</div>
                    <div class="dn-stat-label">Prodip</div>
                </div>

            </div>

        </div><!-- end dn-content -->

        <div class="dn-footer">
            DriveNow Admin System &nbsp;·&nbsp; CTEC2713N &nbsp;·&nbsp; Niels Brock Copenhagen
        </div>

    </div><!-- end dn-main -->

</div><!-- end dn-shell -->
</form>
</body>
</html>
