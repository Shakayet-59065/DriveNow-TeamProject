<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripTypeFind.aspx.cs" Inherits="DriveNow.TripTypeFind" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DriveNow — Find Trip Type</title>
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
<form id="frmTripTypeFind" runat="server">
<div class="dn-shell">

    <div class="dn-sidebar">
        <div class="dn-sidebar-logo"><img src="Content/logo.png" alt="DriveNow" /></div>
        <div class="dn-sidebar-module">
            <div class="dn-sidebar-module-label">Current Module</div>
            <div class="dn-sidebar-module-title">Find Trip Type</div>
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
                <div><div class="dn-sidebar-name">Admin</div><div class="dn-sidebar-role">Staff Portal</div></div>
            </div>
            <a href="Logout.aspx" class="dn-sidebar-logout">Sign Out</a>
        </div>
    </div>

    <div class="dn-main">
        <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
            <div class="dn-topbar-left">
                <span class="dn-page-title">Find Trip Type</span>
                <span class="dn-page-sub">Search by name or ID</span>
            </div>
            <div class="dn-topbar-right">
                <a href="TripTypeList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">&#8592; Back to List</a>
            </div>
        </div>

        <div class="dn-content">
            <div class="dn-section-head">
                <div class="dn-section-title">Search Trip Types</div>
            </div>

            <div style="background:#1e293b;border-radius:12px;padding:1.5rem;max-width:520px;">
                <div class="dn-field" style="margin-bottom:1rem;">
                    <label class="dn-label">Trip Type ID</label>
                    <asp:TextBox ID="txtID" runat="server" CssClass="dn-input" placeholder="e.g. 3" />
                </div>
                <div class="dn-field" style="margin-bottom:1rem;">
                    <label class="dn-label">Type Name (contains)</label>
                    <asp:TextBox ID="txtName" runat="server" CssClass="dn-input" placeholder="e.g. Chauffeured" />
                </div>
                <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="dn-btn dn-btn-primary" OnClick="btnSearch_Click" CausesValidation="false" />
            </div>

            <asp:Label ID="lblMessage" runat="server" Visible="false" style="display:block;margin-top:1rem;color:#f87171;" />

            <div class="dn-table-wrap" style="margin-top:1.5rem;">
                <asp:GridView ID="gvResults" runat="server"
                    AutoGenerateColumns="false"
                    CssClass="dn-table"
                    GridLines="None"
                    EmptyDataText="No trip types match your search."
                    Visible="false">
                    <Columns>
                        <asp:BoundField DataField="TripTypeID"  HeaderText="ID" />
                        <asp:BoundField DataField="TypeName"    HeaderText="Type Name" />
                        <asp:BoundField DataField="Description" HeaderText="Description" />
                        <asp:BoundField DataField="BaseRate"    HeaderText="Base Rate" DataFormatString="{0:F2}" />
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <a href='TripTypeEdit.aspx?id=<%# Eval("TripTypeID") %>' class="dn-action-edit">Edit</a>
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


