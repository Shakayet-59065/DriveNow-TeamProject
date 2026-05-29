<%-- DriveNow — Admin Dashboard (Main Menu)
     The first page staff see after logging in.
     Shows live stat cards (trip count, customer count, etc.) and a table of active/upcoming trips.
     All data is loaded from the database by MainMenu.aspx.cs (code-behind).
     Module: CTEC2713N | Developer: Musanna --%>
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MainMenu.aspx.cs" Inherits="DriveNow.MainMenu" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <!-- Google Material Symbols icon font for navigation icons -->
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <!-- Main admin stylesheet -->
    <link rel="stylesheet" href="Content/Site.css" />
    <style>
        .dn-sidebar-module { padding:14px 20px 10px; border-bottom:1px solid rgba(255,255,255,.07); margin-bottom:6px; }
        .dn-sidebar-module-label { font-size:10px;letter-spacing:.1em;text-transform:uppercase;color:#14b8a6;margin-bottom:4px; }
        .dn-sidebar-module-title { font-size:15px;font-weight:700;color:#fff; }
    </style>
</head>
<body>
<form id="frmMainMenu" runat="server">
<div class="dn-shell">

    <!-- ═══════════════════════════════════════
         SIDEBAR NAVIGATION — Fixed left panel with all admin links
    ═══════════════════════════════════════ -->
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo">
            <img src="Content/logo.png" alt="DriveNow" />
        </div>
        <!-- Current module indicator -->
        <div class="dn-sidebar-module">
            <div class="dn-sidebar-module-label">Current Module</div>
            <div class="dn-sidebar-module-title">Admin Dashboard</div>
        </div>

        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">MAIN</div>
            <a href="MainMenu.aspx"     class="dn-nav-item active"><span class="material-symbols-outlined" style="font-size:17px;">dashboard</span> Dashboard</a>

            <div class="dn-nav-label">NAVIGATE</div>
            <a href="TripList.aspx"        class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">route</span> Trips</a>
            <a href="TripTypeList.aspx"    class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">category</span> Trip Types</a>
            <a href="CustomerList.aspx"    class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">group</span> Customers</a>
            <a href="DriverList.aspx"      class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">person</span> Drivers</a>
            <a href="VehicleList.aspx"     class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">directions_car</span> Vehicles</a>
            <a href="ContributorList.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">handshake</span> Contributors</a>
            <div class="dn-nav-label">ADMIN</div>
            <a href="TempPasswords.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">key</span> Temp Passwords</a>
            <a href="StaffList.aspx"       class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">badge</span> Staff</a>
        </nav>
        <div class="dn-sidebar-footer">
            <a href="StaffProfile.aspx" style="text-decoration:none;" title="View your profile">
                <div class="dn-sidebar-user">
                    <div class="dn-sidebar-avatar"><%= (Session["Username"] != null ? Session["Username"].ToString().Substring(0,1).ToUpper() : "?") %></div>
                    <div>
                        <div class="dn-sidebar-name"><asp:Label ID="lblUsername" runat="server" /></div>
                        <div class="dn-sidebar-role">Staff Portal &rsaquo;</div>
                    </div>
                </div>
            </a>
            <a href="Logout.aspx" class="dn-sidebar-logout">Sign Out</a>
        </div>
    </div>

    <!-- ═══════════════════════════════════════
         MAIN CONTENT — Dashboard body
    ═══════════════════════════════════════ -->
    <div class="dn-main">

        <!-- Top bar: page title, today's date, and quick action buttons -->
        <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
            <div class="dn-topbar-title">Dashboard</div>
            <div class="dn-topbar-right">
                <!-- Today's date — set dynamically in the code-behind -->
                <span class="dn-topbar-date"><asp:Label ID="lblDate" runat="server" /></span>
                <!-- Open the customer-facing website in a new tab for a quick preview -->
                <a href="Default.aspx" class="dn-btn dn-btn-sm dn-btn-secondary" target="_blank">&#127758; View Website</a>
                <a href="TripAdd.aspx" class="dn-btn dn-btn-primary dn-btn-sm">+ New Trip</a>
            </div>
        </div>

        <div class="dn-content">

            <!-- Page header: shows a time-of-day greeting and the logged-in staff member's name -->
            <div class="dn-page-header">
                <div>
                    <!-- lblGreeting shows e.g. "Good morning, Musanna" — set in the code-behind -->
                    <div class="dn-page-title"><asp:Label ID="lblGreeting" runat="server" /></div>
                    <div class="dn-page-sub">DriveNow Staff Portal — CTEC2713N — Niels Brock Copenhagen</div>
                </div>
            </div>

            <!-- ─────────────────────────────────
                 STAT CARDS — live counts from the database via spGetDashboardStats
            ───────────────────────────────── -->
            <div class="dn-stats">
                <!-- Each card shows a live count fetched from the database -->
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
                    <div class="dn-stat-label">Customers</div>
                </div>
                <div class="dn-stat dn-stat-4">
                    <div class="dn-stat-num"><asp:Label ID="lblDriverCount"   runat="server">0</asp:Label></div>
                    <div class="dn-stat-label">Drivers</div>
                </div>
                <div class="dn-stat dn-stat-4">
                    <div class="dn-stat-num"><asp:Label ID="lblContributorCount" runat="server">0</asp:Label></div>
                    <div class="dn-stat-label">Contributors</div>
                </div>
            </div>

            <!-- ─────────────────────────────────
                 RECENT TRIPS TABLE — shows only Upcoming and In-Progress trips (max 10 rows)
            ───────────────────────────────── -->
            <div class="dn-section-head">
                <div class="dn-section-title">Active &amp; Upcoming Trips</div>
                <div style="display:flex;gap:8px">
                    <!-- Quick links to filter, search, or view the full trip list -->
                    <a href="TripFilter.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">Filter</a>
                    <a href="TripFind.aspx"   class="dn-btn dn-btn-secondary dn-btn-sm">Find by ID</a>
                    <a href="TripList.aspx"   class="dn-btn dn-btn-secondary dn-btn-sm">View All →</a>
                </div>
            </div>

            <!-- Quick navigation pills for common trip management actions -->
            <div class="dn-pills">
                <span class="dn-pill active">All Trips</span>
                <a href="TripList.aspx"     class="dn-pill">Manage</a>
                <a href="TripAdd.aspx"      class="dn-pill">+ Add New</a>
                <a href="TripTypeList.aspx" class="dn-pill">Trip Types</a>
            </div>

            <!-- Dashboard trip table — filled by LoadRecentTrips() in the code-behind -->
            <div class="dn-table-wrap">
                <%-- Dashboard trip table: only shows Upcoming and In-Progress trips, ordered by date --%>
                <asp:GridView ID="gvRecentTrips" runat="server"
                    AutoGenerateColumns="false"
                    CssClass="dn-table"
                    GridLines="None"
                    EmptyDataText="No active or upcoming trips found."
                    OnRowCommand="gvRecentTrips_RowCommand">
                    <Columns>
                        <%-- Trip ID formatted as #TRP-001 for easy identification --%>
                        <asp:TemplateField HeaderText="Trip ID">
                            <ItemTemplate>
                                <span class="dn-trip-id">#TRP-00<%# Eval("TripID") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <%-- Core trip data columns --%>
                        <asp:BoundField DataField="CustomerId" HeaderText="Customer ID" />
                        <asp:BoundField DataField="VehicleID"  HeaderText="Vehicle ID" />
                        <asp:BoundField DataField="DriverID"   HeaderText="Driver ID" NullDisplayText="Self-Drive" />
                        <%-- Trip type shown as a coloured pill --%>
                        <asp:TemplateField HeaderText="Trip Type">
                            <ItemTemplate>
                                <span class="dn-type-pill"><%# Eval("TypeName") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="TripDate" HeaderText="Date" DataFormatString="{0:dd MMM yyyy}" />
                        <%-- Status badge: coloured dot + text e.g. "In Progress" or "Upcoming" --%>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <%# GetTripStatusBadge(Eval("TripStatus").ToString()) %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <%-- Actions: Edit opens the trip edit form; Mark Returned closes the trip --%>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <a href='TripEdit.aspx?id=<%# Eval("TripID") %>&from=dashboard' class="dn-action-edit">Edit</a>
                                <!-- "Mark Returned" button: closes the trip as completed when vehicle is back -->
                                <asp:Button runat="server" Text="&#10003; Returned" CommandName="MarkReturned"
                                    CommandArgument='<%# Eval("TripID") %>'
                                    CssClass="dn-action-return"
                                    OnClientClick="return confirm('Mark this trip as returned and completed?');" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
            <style>
                .dn-action-return { background:rgba(20,184,166,.15); color:#14b8a6; border:1px solid rgba(20,184,166,.3); border-radius:6px; padding:3px 10px; font-size:.78rem; cursor:pointer; margin-left:6px; }
                .dn-action-return:hover { background:rgba(20,184,166,.3); }
                .dn-status-upcoming { display:inline-flex;align-items:center;gap:5px; }
                .dn-status-upcoming .dn-dot { background:#3b82f6; }
                .dn-status-inprogress .dn-dot { background:#22c55e; }
            </style>


        </div><!-- end dn-content -->

        <div class="dn-footer">
            DriveNow Admin System  ·  CTEC2713N  ·  Niels Brock Copenhagen
        </div>

    </div><!-- end dn-main -->

</div><!-- end dn-shell -->
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


