<%-- DriveNow — Trip List Page
     Shows all trip bookings in a table with Active / Inactive tabs.
     Each row has Edit, Deactivate, Restore, Hard Delete, and Mark Car Returned actions.
     The code-behind file TripList.aspx.cs handles the logic for each button.
     Module: CTEC2713N | Developer: Musanna --%>
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripList.aspx.cs" Inherits="DriveNow.TripList" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Trip List</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <!-- Google Material Symbols icon font — needed for the sidebar navigation icons -->
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <!-- Main admin stylesheet — controls layout, colours, tables, and buttons -->
    <link rel="stylesheet" href="Content/Site.css" />
    <style>
        .dn-sidebar-module { padding:14px 20px 10px; border-bottom:1px solid rgba(255,255,255,.07); margin-bottom:6px; }
        .dn-sidebar-module-label { font-size:10px;letter-spacing:.1em;text-transform:uppercase;color:#14b8a6;margin-bottom:4px; }
        .dn-sidebar-module-title { font-size:15px;font-weight:700;color:#fff; }
        .dn-badge { display:inline-block; padding:.2rem .6rem; border-radius:99px; font-size:.72rem; font-weight:700; text-transform:uppercase; letter-spacing:.05em; }
        .dn-badge-green  { background:rgba(34,197,94,.15);  color:#22c55e; }
        .dn-badge-blue   { background:rgba(59,130,246,.15); color:#60a5fa; }
        .dn-badge-grey   { background:rgba(148,163,184,.15);color:#94a3b8; }
        .dn-badge-teal   { background:rgba(20,184,166,.15); color:#14b8a6; }
        .dn-badge-red    { background:rgba(239,68,68,.15);  color:#f87171; }
        .dn-badge-orange { background:rgba(249,115,22,.15); color:#fb923c; }
        .dn-btn-xs      { font-size:.7rem; padding:.15rem .5rem; border-radius:4px; margin-left:.4rem; }
    </style>
</head>
<body>
<form id="frmTripList" runat="server">
<div class="dn-shell">

    <!-- ═══ SIDEBAR — Fixed left-hand navigation panel visible on all admin pages ═══ -->
    <div class="dn-sidebar">
        <!-- DriveNow logo at the top of the sidebar -->
        <div class="dn-sidebar-logo"><img src="Content/logo.png" alt="DriveNow" /></div>

        <!-- Shows which section of the admin system the user is currently in -->
        <div class="dn-sidebar-module">
            <div class="dn-sidebar-module-label">Current Module</div>
            <div class="dn-sidebar-module-title">Trip Dashboard</div>
        </div>

        <!-- Navigation links — "active" class highlights the current page -->
        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">MAIN</div>
            <a href="MainMenu.aspx"        class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">dashboard</span> Dashboard</a>

            <div class="dn-nav-label">NAVIGATE</div>
            <a href="TripList.aspx"        class="dn-nav-item active"><span class="material-symbols-outlined" style="font-size:17px;">route</span> Trips</a>
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
            <!-- Shows the logged-in staff member's name from session -->
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

    <!-- ═══ MAIN CONTENT AREA ═══ -->
    <div class="dn-main">

        <!-- Top bar: page title on the left, action buttons on the right -->
        <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
            <div class="dn-topbar-left">
                <span class="dn-page-title">Trip Records</span>
                <span class="dn-page-sub">Manage all DriveNow trip bookings</span>
            </div>
            <div class="dn-topbar-right">
                <!-- Quick action buttons to add a new trip, search by ID, or filter results -->
                <a href="TripAdd.aspx"    class="dn-btn dn-btn-primary dn-btn-sm">+ Add Trip</a>
                <a href="TripFind.aspx"   class="dn-btn dn-btn-secondary dn-btn-sm">Find</a>
                <a href="TripFilter.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">Filter</a>
                <asp:Button ID="btnExportCsv" runat="server" Text="⬇ Export CSV"
                    CssClass="dn-btn dn-btn-secondary dn-btn-sm"
                    OnClick="btnExportCsv_Click" CausesValidation="false"
                    ToolTip="Download all trips as a CSV file (opens in Excel)" />
            </div>
        </div>

        <div class="dn-content">

            <!-- Success or error message shown after an action (e.g. trip deactivated) -->
            <asp:Label ID="lblError" runat="server" CssClass="dn-alert-error" Visible="false" />

            <!-- Tab pills: switch between Active trips and Inactive (deactivated) trips -->
            <div class="dn-pills" style="margin-bottom:14px;">
                <a href="TripList.aspx"              class='<%= TabCss("active") %>'>Active</a>
                <a href="TripList.aspx?tab=inactive" class='<%= TabCss("inactive") %>'>Inactive</a>
            </div>

            <!-- Section heading above the data table -->
            <div class="dn-section-head">
                <div class="dn-section-title">All Trips</div>
            </div>

            <!-- Trips data table — populated by gvTrips_RowCommand in the code-behind -->
            <div class="dn-table-wrap">
                <asp:GridView ID="gvTrips" runat="server"
                    AutoGenerateColumns="false"
                    DataKeyNames="TripID"
                    OnRowCommand="gvTrips_RowCommand"
                    CssClass="dn-table"
                    GridLines="None"
                    EmptyDataText="No trips found.">
                    <Columns>
                        <%-- Formatted Trip ID displayed as #TRP-001 style --%>
                        <asp:TemplateField HeaderText="Trip ID">
                            <ItemTemplate>
                                <span class="dn-trip-id">#TRP-00<%# Eval("TripID") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- Basic data columns — pulled directly from the database --%>
                        <asp:BoundField DataField="CustomerId" HeaderText="Customer ID" />
                        <asp:BoundField DataField="VehicleID"  HeaderText="Vehicle ID" />
                        <asp:BoundField DataField="DriverID"   HeaderText="Driver ID" NullDisplayText="Self-Drive" />

                        <%-- Trip type shown as a coloured pill badge --%>
                        <asp:TemplateField HeaderText="Trip Type">
                            <ItemTemplate>
                                <span class="dn-type-pill"><%# Eval("TypeName") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="TripDate" HeaderText="Pickup Date" DataFormatString="{0:dd MMM yyyy}" />

                        <%-- Drop-off date is optional — shows a dash if not set --%>
                        <asp:TemplateField HeaderText="Drop-off Date">
                            <ItemTemplate>
                                <%# Eval("DropoffDate") != null
                                    ? Convert.ToDateTime(Eval("DropoffDate")).ToString("dd MMM yyyy")
                                    : "<span style='color:#64748b;'>—</span>" %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- Status badge: colour changes based on trip state (Upcoming, In Progress, etc.) --%>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='<%# GetStatusCss(Eval("DisplayStatus").ToString()) %>'>
                                    <%# Eval("DisplayStatus") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- Car Returned: shows a tick if returned, or a "Mark Returned" button if not --%>
                        <asp:TemplateField HeaderText="Car Returned">
                            <ItemTemplate>
                                <asp:Label runat="server"
                                    Text='<%# Convert.ToBoolean(Eval("CarReturned")) ? "&#x2705; Returned" : "&#x2014;" %>'
                                    style='<%# "color: " + (Convert.ToBoolean(Eval("CarReturned")) ? "#14b8a6" : "#94A3B8") + ";" %>' />
                                <%-- Only show the button if the car has NOT been returned yet --%>
                                <asp:LinkButton runat="server" CommandName="MarkCarReturned"
                                    CommandArgument='<%# Eval("TripID") %>'
                                    Text="Mark Returned"
                                    Visible='<%# !Convert.ToBoolean(Eval("CarReturned")) %>'
                                    CssClass="dn-btn dn-btn-xs dn-btn-ghost"
                                    OnClientClick="return confirm('Mark this vehicle as returned?');" />
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- Action buttons change depending on whether the trip is active or inactive --%>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <%-- Active row buttons: Edit the trip or Deactivate (soft-delete) it --%>
                                <asp:LinkButton runat="server" CommandName="EditTrip"
                                    CommandArgument='<%# Eval("TripID") %>'
                                    CssClass="dn-action-edit"
                                    Visible='<%# Convert.ToBoolean(Eval("IsActive")) %>'>Edit</asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="DeleteTrip"
                                    CommandArgument='<%# Eval("TripID") %>'
                                    CssClass="dn-action-del"
                                    Visible='<%# Convert.ToBoolean(Eval("IsActive")) %>'
                                    OnClientClick="return confirm('Deactivate this trip?');">Deactivate</asp:LinkButton>
                                <%-- Inactive row buttons: Restore the trip or permanently Hard Delete it --%>
                                <asp:LinkButton runat="server" CommandName="RestoreTrip"
                                    CommandArgument='<%# Eval("TripID") %>'
                                    CssClass="dn-action-edit"
                                    Visible='<%# !Convert.ToBoolean(Eval("IsActive")) %>'>Restore</asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="HardDeleteTrip"
                                    CommandArgument='<%# Eval("TripID") %>'
                                    CssClass="dn-action-del"
                                    Visible='<%# !Convert.ToBoolean(Eval("IsActive")) %>'
                                    OnClientClick="return confirm('PERMANENTLY delete this trip? This cannot be undone.');">Hard Delete</asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

        </div>
        <!-- Footer bar at the bottom of every admin page -->
        <div class="dn-footer">DriveNow Admin &middot; CTEC2713N &middot; Niels Brock Copenhagen</div>
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


