<%-- DriveNow — Trip Type List Page (TripTypeList.aspx)
     Shows all trip types (e.g. Airport Transfer, City Tour) that can be assigned to bookings.
     Supports Add, Edit, Deactivate, Restore, and Hard Delete actions.
     Module: CTEC2713N | Developer: Musanna --%>
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripTypeList.aspx.cs" Inherits="DriveNow.TripTypeList" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Trip Type List</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <link rel="stylesheet" href="Content/Site.css" />
    <style>
        .dn-sidebar-module { padding:14px 20px 10px; border-bottom:1px solid rgba(255,255,255,.07); margin-bottom:6px; }
        .dn-sidebar-module-label { font-size:10px;letter-spacing:.1em;text-transform:uppercase;color:#14b8a6;margin-bottom:4px; }
        .dn-sidebar-module-title { font-size:15px;font-weight:700;color:#fff; }
    </style>
</head>
<body>
<form id="frmTripTypeList" runat="server">
<div class="dn-shell">

    <!-- SIDEBAR -->
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo"><img src="Content/logo.png" alt="DriveNow" /></div>

        <div class="dn-sidebar-module">
            <div class="dn-sidebar-module-label">Current Module</div>
            <div class="dn-sidebar-module-title">Trip Type Dashboard</div>
        </div>

        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">MAIN</div>
            <a href="MainMenu.aspx"        class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">dashboard</span> Dashboard</a>

            <div class="dn-nav-label">NAVIGATE</div>
            <a href="TripList.aspx"        class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">route</span> Trips</a>
            <a href="TripTypeList.aspx"    class="dn-nav-item active"><span class="material-symbols-outlined" style="font-size:17px;">category</span> Trip Types</a>
            <a href="CustomerList.aspx"    class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">group</span> Customers</a>
            <a href="DriverList.aspx"      class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">person</span> Drivers</a>
            <a href="VehicleList.aspx"     class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">directions_car</span> Vehicles</a>
            <a href="ContributorList.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">handshake</span> Contributors</a>
            <div class="dn-nav-label">ADMIN</div>
            <a href="TempPasswords.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">key</span> Temp Passwords</a>
            <a href="StaffList.aspx"       class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">badge</span> Staff</a>
        </nav>

        <div class="dn-sidebar-footer">
            <div class="dn-sidebar-user">
                <div class="dn-sidebar-avatar"><%= (Session["Username"] != null ? Session["Username"].ToString().Substring(0,1).ToUpper() : "?") %></div>
                <div>
                    <div class="dn-sidebar-name">Admin</div>
                    <div class="dn-sidebar-role">Staff Portal</div>
                </div>
            </div>
            <a href="Logout.aspx" class="dn-sidebar-logout">Sign Out</a>
        </div>
    </div>

    <!-- MAIN -->
    <div class="dn-main">
        <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
            <div class="dn-topbar-left">
                <span class="dn-page-title">Trip Type Catalogue</span>
                <span class="dn-page-sub">Manage all DriveNow service types</span>
            </div>
            <div class="dn-topbar-right">
                <a href="TripTypeAdd.aspx"    class="dn-btn dn-btn-primary dn-btn-sm">+ Add Trip Type</a>
                <a href="TripTypeFind.aspx"   class="dn-btn dn-btn-secondary dn-btn-sm">Find</a>
                <a href="TripTypeFilter.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">Filter</a>
            </div>
        </div>

        <div class="dn-content">

            <asp:Label ID="lblError" runat="server" CssClass="dn-alert-error" Visible="false" />

            <!-- Status tabs -->
            <div class="dn-pills" style="margin-bottom:14px;">
                <a href="TripTypeList.aspx"              class='<%= TabCss("active") %>'>Active</a>
                <a href="TripTypeList.aspx?tab=inactive" class='<%= TabCss("inactive") %>'>Inactive</a>
            </div>

            <!-- Section header — title only -->
            <div class="dn-section-head">
                <div class="dn-section-title">All Trip Types</div>
            </div>

            <!-- Trip Types GridView -->
            <div class="dn-table-wrap">
                <asp:GridView ID="gvTripTypes" runat="server"
                    AutoGenerateColumns="false"
                    DataKeyNames="TripTypeID"
                    OnRowCommand="gvTripTypes_RowCommand"
                    CssClass="dn-table"
                    GridLines="None"
                    EmptyDataText="No trip types found.">
                    <Columns>
                        <asp:BoundField DataField="TripTypeID"  HeaderText="ID" />
                        <asp:BoundField DataField="TypeName"    HeaderText="Type Name" />
                        <asp:BoundField DataField="Description" HeaderText="Description" />
                        <asp:BoundField DataField="BaseRate"    HeaderText="Base Rate" DataFormatString="{0:F2}" />
                        <asp:BoundField DataField="CreatedDate" HeaderText="Created"   DataFormatString="{0:dd/MM/yyyy}" />
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class="dn-status">
                                    <span class='dn-dot <%# (bool)Eval("IsActive") ? "dn-dot-green" : "dn-dot-red" %>'></span>
                                    <%# (bool)Eval("IsActive") ? "Active" : "Inactive" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <%-- Active row: Edit + Deactivate --%>
                                <asp:LinkButton runat="server" CommandName="EditType"
                                    CommandArgument='<%# Eval("TripTypeID") %>'
                                    CssClass="dn-action-edit"
                                    Visible='<%# Convert.ToBoolean(Eval("IsActive")) %>'>Edit</asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="DeleteType"
                                    CommandArgument='<%# Eval("TripTypeID") %>'
                                    CssClass="dn-action-del"
                                    Visible='<%# Convert.ToBoolean(Eval("IsActive")) %>'
                                    OnClientClick="return confirm('Deactivate this trip type?');">Deactivate</asp:LinkButton>
                                <%-- Inactive row: Restore + Hard Delete --%>
                                <asp:LinkButton runat="server" CommandName="RestoreType"
                                    CommandArgument='<%# Eval("TripTypeID") %>'
                                    CssClass="dn-action-edit"
                                    Visible='<%# !Convert.ToBoolean(Eval("IsActive")) %>'>Restore</asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="HardDeleteType"
                                    CommandArgument='<%# Eval("TripTypeID") %>'
                                    CssClass="dn-action-del"
                                    Visible='<%# !Convert.ToBoolean(Eval("IsActive")) %>'
                                    OnClientClick="return confirm('PERMANENTLY delete this trip type? This cannot be undone.');">Hard Delete</asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

        </div>
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


