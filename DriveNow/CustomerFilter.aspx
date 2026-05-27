<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerFilter.aspx.cs" Inherits="DriveNow.CustomerFilter" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Filter Customers — DriveNow Admin</title>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block" />
    <link rel="stylesheet" href="Content/Site.css" />
</head>
<body>
<form id="form1" runat="server">
<div class="dn-shell">
    <div class="dn-sidebar">
        <div class="dn-sidebar-logo"><img src="Content/logo.png" alt="DriveNow" /></div>
        <nav class="dn-sidebar-nav">
            <div class="dn-nav-label">Main</div>
            <a href="MainMenu.aspx"        class="dn-nav-item">■ Dashboard</a>
            <div class="dn-nav-label">Team</div>
            <a href="TripList.aspx"        class="dn-nav-item">■ Trips</a>
            <a href="TripTypeList.aspx"    class="dn-nav-item">■ Trip Types</a>
            <a href="CustomerList.aspx"    class="dn-nav-item active">■ Customers</a>
            <a href="DriverList.aspx"      class="dn-nav-item">■ Drivers</a>
            <a href="VehicleList.aspx"     class="dn-nav-item">■ Vehicles</a>
            <a href="ContributorList.aspx" class="dn-nav-item">■ Contributors</a>
            <div class="dn-nav-label">ADMIN</div>
            <a href="TempPasswords.aspx" class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">key</span> Temp Passwords</a>
            <a href="StaffList.aspx"       class="dn-nav-item"><span class="material-symbols-outlined" style="font-size:17px;">badge</span> Staff</a>
        </nav>
        <div class="dn-sidebar-footer">
            <div>CTEC2713N · Niels Brock</div>
            <a href="Logout.aspx" class="dn-sidebar-logout">&#x2192; Log out</a>
        </div>
    </div>
    <div class="dn-main">
        <div class="dn-topbar">
            <button type="button" class="dn-mobile-menu-btn" onclick="toggleSidebar()" aria-label="Toggle navigation">&#9776;</button>
            <div class="dn-topbar-left">
                <span class="dn-page-title">Filter Customers</span>
                <span class="dn-page-sub">Filter by registration date or status</span>
            </div>
            <div class="dn-topbar-actions">
                <a href="CustomerList.aspx" class="dn-btn dn-btn-secondary dn-btn-sm">Back to List</a>
            </div>
        </div>
        <div class="dn-content">
            <div class="dn-form-card">
                <div class="dn-field">
                    <label class="dn-label">Registered From</label>
                    <asp:TextBox ID="txtRegFrom" runat="server" CssClass="dn-input" TextMode="Date" />
                </div>
                <div class="dn-field">
                    <label class="dn-label">Status</label>
                    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="dn-select">
                        <asp:ListItem Text="All"      Value=""  />
                        <asp:ListItem Text="Active"   Value="1" />
                        <asp:ListItem Text="Inactive" Value="0" />
                    </asp:DropDownList>
                </div>
                <div class="dn-form-actions">
                    <asp:Button ID="btnFilter" runat="server" Text="Apply Filter" CssClass="dn-btn dn-btn-primary"   OnClick="btnFilter_Click" CausesValidation="false" />
                    <asp:Button ID="btnBack"   runat="server" Text="Back"         CssClass="dn-btn dn-btn-secondary" OnClick="btnBack_Click"   CausesValidation="false" />
                </div>
            </div>
            <asp:Label ID="lblMessage" runat="server" Visible="false" />
            <div class="dn-table-wrap">
                <asp:GridView ID="gvResults" runat="server"
                    AutoGenerateColumns="false"
                    CssClass="dn-table"
                    GridLines="None"
                    EmptyDataText="No customers match this filter.">
                    <Columns>
                        <asp:TemplateField HeaderText="ID">
                            <ItemTemplate><span class="dn-trip-id">#CUS-<%# string.Format("{0:D3}", Eval("CustomerID")) %></span></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="FullName"     HeaderText="Full Name" />
                        <asp:BoundField DataField="Email"        HeaderText="Email" />
                        <asp:BoundField DataField="RegisterDate" HeaderText="Registered" DataFormatString="{0:dd MMM yyyy}" />
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <%# Convert.ToBoolean(Eval("IsActive"))
                                    ? "<span class=\"dn-status\"><span class=\"dn-dot-green\"></span> Active</span>"
                                    : "<span class=\"dn-status\"><span class=\"dn-dot-red\"></span> Inactive</span>" %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate><a href='CustomerEdit.aspx?id=<%# Eval("CustomerID") %>' class="dn-action-edit">Edit</a></ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
        <div class="dn-footer">DriveNow Admin · CTEC2713N · Niels Brock Copenhagen</div>
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


